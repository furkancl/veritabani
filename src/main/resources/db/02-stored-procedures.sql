-- ============================================
-- STOK YÖNETİM SİSTEMİ - STORED PROCEDURES
-- ============================================
-- Bu dosyayı PostgreSQL'de veritabanı oluştuktan sonra çalıştırın

-- ============================================
-- 1. STOK GÜNCELLEME STORED PROCEDURE
-- ============================================
-- Ürün stokunu güvenli şekilde günceller
-- Parametre: product_id, quantity, movement_type ('IN' veya 'OUT')

CREATE OR REPLACE FUNCTION sp_update_stock(
    p_product_id BIGINT,
    p_quantity INTEGER,
    p_movement_type VARCHAR(10)
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR(255),
    new_stock INTEGER
) AS $$
DECLARE
    v_current_stock INTEGER;
    v_new_stock INTEGER;
    v_product_name VARCHAR(255);
BEGIN
    -- Ürünü kilitle ve mevcut stoğu al
    SELECT stock_quantity, name INTO v_current_stock, v_product_name
    FROM products 
    WHERE id = p_product_id
    FOR UPDATE;
    
    -- Ürün kontrolü
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Ürün bulunamadı'::VARCHAR(255), 0;
        RETURN;
    END IF;
    
    -- Stok hesaplama
    IF p_movement_type = 'IN' THEN
        v_new_stock := v_current_stock + p_quantity;
    ELSIF p_movement_type = 'OUT' THEN
        IF v_current_stock < p_quantity THEN
            RETURN QUERY SELECT FALSE, 
                ('Yetersiz stok! Mevcut: ' || v_current_stock)::VARCHAR(255), 
                v_current_stock;
            RETURN;
        END IF;
        v_new_stock := v_current_stock - p_quantity;
    ELSE
        RETURN QUERY SELECT FALSE, 'Geçersiz hareket tipi'::VARCHAR(255), v_current_stock;
        RETURN;
    END IF;
    
    -- Stok güncelleme
    UPDATE products SET stock_quantity = v_new_stock, updated_at = NOW()
    WHERE id = p_product_id;
    
    RETURN QUERY SELECT TRUE, 
        (v_product_name || ' stoğu güncellendi: ' || v_new_stock)::VARCHAR(255), 
        v_new_stock;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2. DÜŞÜK STOKLU ÜRÜNLERİ GETİRME
-- ============================================
-- Minimum stok seviyesinin altındaki aktif ürünleri listeler

CREATE OR REPLACE FUNCTION sp_get_low_stock_products()
RETURNS TABLE(
    product_id BIGINT,
    product_code VARCHAR(255),
    product_name VARCHAR(255),
    category_name VARCHAR(255),
    current_stock INTEGER,
    min_stock INTEGER,
    shortage INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.code,
        p.name,
        c.name,
        p.stock_quantity,
        p.min_stock_level,
        (p.min_stock_level - p.stock_quantity)
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    WHERE p.active = TRUE 
      AND p.stock_quantity <= p.min_stock_level
    ORDER BY (p.min_stock_level - p.stock_quantity) DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. AYLIK STOK RAPORU
-- ============================================
-- Belirtilen ay için stok hareketlerinin özetini döndürür

CREATE OR REPLACE FUNCTION sp_monthly_stock_report(
    p_year INTEGER,
    p_month INTEGER
)
RETURNS TABLE(
    product_id BIGINT,
    product_name VARCHAR(255),
    total_in INTEGER,
    total_out INTEGER,
    net_change INTEGER,
    movement_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        COALESCE(SUM(CASE WHEN sm.movement_type = 'IN' THEN sm.quantity ELSE 0 END), 0)::INTEGER,
        COALESCE(SUM(CASE WHEN sm.movement_type = 'OUT' THEN sm.quantity ELSE 0 END), 0)::INTEGER,
        COALESCE(SUM(CASE 
            WHEN sm.movement_type = 'IN' THEN sm.quantity 
            WHEN sm.movement_type = 'OUT' THEN -sm.quantity 
            ELSE 0 
        END), 0)::INTEGER,
        COUNT(sm.id)
    FROM products p
    LEFT JOIN stock_movements sm ON p.id = sm.product_id
        AND EXTRACT(YEAR FROM sm.created_at) = p_year
        AND EXTRACT(MONTH FROM sm.created_at) = p_month
    WHERE p.active = TRUE
    GROUP BY p.id, p.name
    ORDER BY COUNT(sm.id) DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. STOK DEĞERİ HESAPLAMA
-- ============================================
-- Kategori bazında veya genel stok değerini hesaplar

CREATE OR REPLACE FUNCTION sp_calculate_stock_value(
    p_category_id BIGINT DEFAULT NULL
)
RETURNS TABLE(
    category_name VARCHAR(255),
    product_count BIGINT,
    total_quantity BIGINT,
    total_value NUMERIC(15,2)
) AS $$
BEGIN
    IF p_category_id IS NOT NULL THEN
        -- Belirli kategori için
        RETURN QUERY
        SELECT 
            c.name,
            COUNT(p.id),
            COALESCE(SUM(p.stock_quantity), 0)::BIGINT,
            COALESCE(SUM(p.stock_quantity * p.price), 0)::NUMERIC(15,2)
        FROM categories c
        LEFT JOIN products p ON c.id = p.category_id AND p.active = TRUE
        WHERE c.id = p_category_id
        GROUP BY c.id, c.name;
    ELSE
        -- Tüm kategoriler için
        RETURN QUERY
        SELECT 
            COALESCE(c.name, 'Kategorisiz')::VARCHAR(255),
            COUNT(p.id),
            COALESCE(SUM(p.stock_quantity), 0)::BIGINT,
            COALESCE(SUM(p.stock_quantity * p.price), 0)::NUMERIC(15,2)
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.active = TRUE
        GROUP BY c.id, c.name
        ORDER BY SUM(p.stock_quantity * p.price) DESC NULLS LAST;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. ÜRÜN ARAMA
-- ============================================
-- Ürün adı veya koduna göre arama yapar

CREATE OR REPLACE FUNCTION sp_search_products(
    p_search_term VARCHAR(255)
)
RETURNS TABLE(
    product_id BIGINT,
    product_code VARCHAR(255),
    product_name VARCHAR(255),
    category_name VARCHAR(255),
    supplier_name VARCHAR(255),
    price NUMERIC(10,2),
    stock_quantity INTEGER,
    is_low_stock BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.code,
        p.name,
        c.name,
        s.name,
        p.price,
        p.stock_quantity,
        (p.stock_quantity <= p.min_stock_level)
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN suppliers s ON p.supplier_id = s.id
    WHERE p.active = TRUE
      AND (
          LOWER(p.name) LIKE LOWER('%' || p_search_term || '%')
          OR LOWER(p.code) LIKE LOWER('%' || p_search_term || '%')
      )
    ORDER BY p.name;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- KULLANIM ÖRNEKLERİ
-- ============================================

-- Stok güncelleme
-- SELECT * FROM sp_update_stock(1, 50, 'IN');
-- SELECT * FROM sp_update_stock(1, 10, 'OUT');

-- Düşük stoklu ürünler
-- SELECT * FROM sp_get_low_stock_products();

-- Aylık rapor (Aralık 2024)
-- SELECT * FROM sp_monthly_stock_report(2024, 12);

-- Stok değeri (tüm kategoriler)
-- SELECT * FROM sp_calculate_stock_value();

-- Stok değeri (belirli kategori)
-- SELECT * FROM sp_calculate_stock_value(1);

-- Ürün arama
-- SELECT * FROM sp_search_products('laptop');
