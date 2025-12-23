-- ============================================
-- STOK YÖNETİM SİSTEMİ - TRIGGERS
-- ============================================
-- Bu dosyayı PostgreSQL'de veritabanı oluştuktan sonra çalıştırın

-- ============================================
-- 1. STOK HAREKETİ TRIGGER
-- ============================================
-- Stok hareketi eklendiğinde otomatik olarak ürün stokunu günceller
-- NOT: Bu işlem uygulama tarafında da yapılıyor, 
-- bu trigger ekstra güvenlik sağlar

CREATE OR REPLACE FUNCTION trg_stock_movement_update()
RETURNS TRIGGER AS $$
DECLARE
    v_current_stock INTEGER;
BEGIN
    -- Mevcut stok bilgisini al
    SELECT stock_quantity INTO v_current_stock
    FROM products WHERE id = NEW.product_id;
    
    -- Önceki stok değerini kaydet
    NEW.previous_quantity := v_current_stock;
    
    -- Yeni stok değerini hesapla
    IF NEW.movement_type = 'IN' THEN
        NEW.new_quantity := v_current_stock + NEW.quantity;
    ELSIF NEW.movement_type = 'OUT' THEN
        -- Stok kontrolü
        IF v_current_stock < NEW.quantity THEN
            RAISE EXCEPTION 'Yetersiz stok! Mevcut stok: %, İstenen: %', 
                v_current_stock, NEW.quantity;
        END IF;
        NEW.new_quantity := v_current_stock - NEW.quantity;
    END IF;
    
    -- Ürün stoğunu güncelle
    UPDATE products 
    SET stock_quantity = NEW.new_quantity,
        updated_at = NOW()
    WHERE id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger'ı oluştur (devre dışı - uygulama tarafında yapılıyor)
-- Eğer trigger ile yapmak isterseniz aşağıdaki satırı açın
-- DROP TRIGGER IF EXISTS trg_stock_movement ON stock_movements;
-- CREATE TRIGGER trg_stock_movement
--     BEFORE INSERT ON stock_movements
--     FOR EACH ROW
--     EXECUTE FUNCTION trg_stock_movement_update();

-- ============================================
-- 2. ÜRÜN DEĞİŞİKLİK AUDIT LOG TRIGGER
-- ============================================
-- Ürün tablosundaki değişiklikleri audit_logs tablosuna kaydeder

CREATE OR REPLACE FUNCTION trg_product_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_values, changed_at)
        VALUES (
            'products',
            NEW.id,
            'INSERT',
            json_build_object(
                'code', NEW.code,
                'name', NEW.name,
                'price', NEW.price,
                'stock_quantity', NEW.stock_quantity
            )::TEXT,
            NOW()
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- Sadece önemli alanlar değiştiyse kaydet
        IF OLD.price != NEW.price 
           OR OLD.stock_quantity != NEW.stock_quantity 
           OR OLD.name != NEW.name 
           OR OLD.active != NEW.active THEN
            INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, changed_at)
            VALUES (
                'products',
                NEW.id,
                'UPDATE',
                json_build_object(
                    'name', OLD.name,
                    'price', OLD.price,
                    'stock_quantity', OLD.stock_quantity,
                    'active', OLD.active
                )::TEXT,
                json_build_object(
                    'name', NEW.name,
                    'price', NEW.price,
                    'stock_quantity', NEW.stock_quantity,
                    'active', NEW.active
                )::TEXT,
                NOW()
            );
        END IF;
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, changed_at)
        VALUES (
            'products',
            OLD.id,
            'DELETE',
            json_build_object(
                'code', OLD.code,
                'name', OLD.name,
                'price', OLD.price,
                'stock_quantity', OLD.stock_quantity
            )::TEXT,
            NOW()
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger'ı oluştur
DROP TRIGGER IF EXISTS trg_product_audit ON products;
CREATE TRIGGER trg_product_audit
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW
    EXECUTE FUNCTION trg_product_audit();

-- ============================================
-- 3. KULLANICI DEĞİŞİKLİK AUDIT LOG TRIGGER
-- ============================================
-- Kullanıcı tablosundaki değişiklikleri kaydeder

CREATE OR REPLACE FUNCTION trg_user_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_values, changed_at)
        VALUES (
            'users',
            NEW.id,
            'INSERT',
            json_build_object(
                'username', NEW.username,
                'full_name', NEW.full_name,
                'role', NEW.role,
                'active', NEW.active
            )::TEXT,
            NOW()
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, new_values, changed_at)
        VALUES (
            'users',
            NEW.id,
            'UPDATE',
            json_build_object(
                'username', OLD.username,
                'full_name', OLD.full_name,
                'role', OLD.role,
                'active', OLD.active
            )::TEXT,
            json_build_object(
                'username', NEW.username,
                'full_name', NEW.full_name,
                'role', NEW.role,
                'active', NEW.active
            )::TEXT,
            NOW()
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (table_name, record_id, action, old_values, changed_at)
        VALUES (
            'users',
            OLD.id,
            'DELETE',
            json_build_object(
                'username', OLD.username,
                'full_name', OLD.full_name
            )::TEXT,
            NOW()
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger'ı oluştur
DROP TRIGGER IF EXISTS trg_user_audit ON users;
CREATE TRIGGER trg_user_audit
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trg_user_audit();

-- ============================================
-- 4. DÜŞÜK STOK BİLDİRİM TRIGGER
-- ============================================
-- Stok minimum seviyenin altına düştüğünde log oluşturur

CREATE OR REPLACE FUNCTION trg_low_stock_alert()
RETURNS TRIGGER AS $$
BEGIN
    -- Stok minimum seviyenin altına düştüyse
    IF NEW.stock_quantity <= NEW.min_stock_level 
       AND (OLD.stock_quantity IS NULL OR OLD.stock_quantity > OLD.min_stock_level) THEN
        INSERT INTO audit_logs (table_name, record_id, action, new_values, changed_at)
        VALUES (
            'products',
            NEW.id,
            'LOW_STOCK_ALERT',
            json_build_object(
                'product_name', NEW.name,
                'product_code', NEW.code,
                'current_stock', NEW.stock_quantity,
                'min_stock_level', NEW.min_stock_level,
                'alert', 'Düşük stok uyarısı!'
            )::TEXT,
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger'ı oluştur
DROP TRIGGER IF EXISTS trg_low_stock_alert ON products;
CREATE TRIGGER trg_low_stock_alert
    AFTER UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION trg_low_stock_alert();

-- ============================================
-- 5. ÜRÜN SİLME KONTROLÜ TRIGGER
-- ============================================
-- Stok hareketi olan ürünün silinmesini engeller

CREATE OR REPLACE FUNCTION trg_prevent_product_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_movement_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_movement_count
    FROM stock_movements
    WHERE product_id = OLD.id;
    
    IF v_movement_count > 0 THEN
        RAISE EXCEPTION 'Bu ürün silinemez! % adet stok hareketi kaydı bulunmaktadır. Ürünü pasif hale getirin.', v_movement_count;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger'ı oluştur
DROP TRIGGER IF EXISTS trg_prevent_product_delete ON products;
CREATE TRIGGER trg_prevent_product_delete
    BEFORE DELETE ON products
    FOR EACH ROW
    EXECUTE FUNCTION trg_prevent_product_delete();

-- ============================================
-- TRİGGER LİSTESİ
-- ============================================
-- Aktif trigger'ları görmek için:
-- SELECT * FROM pg_trigger WHERE tgrelid IN (
--     SELECT oid FROM pg_class WHERE relname IN ('products', 'users', 'stock_movements')
-- );
