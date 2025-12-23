-- ============================================
-- STOK YÖNETİM SİSTEMİ - ÖRNEK VERİLER
-- ============================================
-- Bu script'i uygulama çalıştırıldıktan sonra
-- isteğe bağlı olarak çalıştırabilirsiniz

-- Windows ortamında Türkçe karakterler için istemci kodlaması
SET client_encoding TO 'WIN1254';

-- ============================================
-- EK KATEGORİLER
-- ============================================
INSERT INTO categories (name, description, created_at, updated_at) VALUES
('Bilgisayar', 'Bilgisayar ve laptop ürünleri', NOW(), NOW()),
('Telefon', 'Cep telefonu ve aksesuarları', NOW(), NOW()),
('Ev Aletleri', 'Ev tipi elektrikli aletler', NOW(), NOW()),
('Kırtasiye', 'Kırtasiye malzemeleri', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- EK TEDARİKÇİLER
-- ============================================
INSERT INTO suppliers (name, contact_person, phone, email, address, active, created_at, updated_at) VALUES
('Tech Elektronik', 'Ali Veli', '0216-333-4455', 'info@techelektronik.com', 'İstanbul, Kadıköy', true, NOW(), NOW()),
('Global Dağıtım', 'Fatma Kaya', '0312-222-3344', 'satis@globaldagitim.com', 'Ankara, Çankaya', true, NOW(), NOW()),
('Mega Tedarik', 'Hasan Öz', '0232-111-2233', 'info@megatedarik.com', 'İzmir, Konak', true, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- ÖRNEK ÜRÜNLER
-- ============================================
-- NOT: category_id ve supplier_id değerlerini kendi veritabanınıza göre ayarlayın

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD001', 'Laptop Dell', '15.6 inç, Intel i7, 16GB RAM', 25000.00, 15, 5, 'Adet',
    (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'Tech Elektronik' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD001');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD002', 'iPhone 15', 'Apple iPhone 15 128GB', 45000.00, 8, 3, 'Adet',
    (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'Tech Elektronik' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD002');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD003', 'Samsung Galaxy S24', 'Samsung Galaxy S24 Ultra 256GB', 52000.00, 12, 5, 'Adet',
    (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'Global Dağıtım' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD003');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD004', 'Kablosuz Mouse', 'Logitech MX Master 3', 2500.00, 50, 10, 'Adet',
    (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD004');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD005', 'Mekanik Klavye', 'RGB Mekanik Gaming Klavye', 1800.00, 3, 10, 'Adet',
    (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD005');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD006', 'Monitör 27"', 'LG 27 inç 4K IPS Monitör', 8500.00, 20, 5, 'Adet',
    (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD006');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD007', 'Kulaklık Bluetooth', 'Sony WH-1000XM5', 9000.00, 25, 8, 'Adet',
    (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'Tech Elektronik' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD007');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 
    'PRD008', 'USB Hub', '7 Port USB 3.0 Hub', 350.00, 2, 15, 'Adet',
    (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
    (SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1),
    true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PRD008');

-- ============================================
-- EK KULLANICI
-- ============================================
-- NOT: Şifre BCrypt ile hashlenmiş olmalı
-- Aşağıdaki kullanıcıyı uygulama üzerinden ekleyin

-- ============================================
-- VERİ KONTROLÜ
-- ============================================
-- Eklenen verileri kontrol edin:
-- SELECT * FROM categories;
-- SELECT * FROM suppliers;
-- SELECT * FROM products;
-- SELECT * FROM sp_get_low_stock_products();

-- ============================================
-- KATEGORİ BAŞINA 5 ÖRNEK ÜRÜN EKLEME
-- Notlar:
-- - supplier_id olarak öncelikle 'ABC Ticaret' seçilir; yoksa ilk aktif tedarikçi kullanılır.
-- - Her ürün kodu benzersizdir; varsa eklenmez.
-- - Fiyat ve stok değerleri örnek amaçlıdır.
-- ============================================

-- Yardımcı: tedarikçi id (öncelik ABC Ticaret, yoksa herhangi biri)
-- PostgreSQL SELECT içinde COALESCE kullanıyoruz.

-- Elektronik
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EL-101', 'Laptop', 'Elektronik - 13.3" 8GB RAM', 20000.00, 10, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EL-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EL-102', 'Mouse', 'Elektronik - Kablosuz', 450.00, 50, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EL-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EL-103', 'Klavye', 'Elektronik - Mekanik', 1200.00, 30, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EL-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EL-104', 'Monitör', 'Elektronik - 27" IPS', 7800.00, 15, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EL-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EL-105', 'Kulaklık', 'Elektronik - Bluetooth', 950.00, 25, 8, 'Adet',
       (SELECT id FROM categories WHERE name = 'Elektronik' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EL-105');

-- Giyim
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GY-101', 'T-Shirt', 'Giyim - Pamuklu', 150.00, 100, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Giyim' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GY-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GY-102', 'Pantolon', 'Giyim - Kot', 600.00, 60, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Giyim' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GY-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GY-103', 'Ceket', 'Giyim - Mevsimlik', 950.00, 25, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Giyim' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GY-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GY-104', 'Ayakkabı', 'Giyim - Spor', 1200.00, 40, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Giyim' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GY-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GY-105', 'Sapka', 'Giyim - Siyah', 180.00, 80, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Giyim' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GY-105');

-- Gıda
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GD-101', 'Makarna', 'Gida - 500g', 25.00, 200, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Gıda' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GD-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GD-102', 'Pirinc', 'Gida - 1kg', 40.00, 150, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Gıda' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GD-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GD-103', 'Zeytinyagi', 'Gida - 1L', 220.00, 60, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Gıda' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GD-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GD-104', 'Seker', 'Gida - 1kg', 35.00, 180, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Gıda' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GD-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'GD-105', 'Kahve', 'Gida - 250g', 140.00, 70, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Gıda' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'GD-105');

-- Mobilya
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'MB-101', 'Sandalye', 'Mobilya - Ahşap', 850.00, 40, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Mobilya' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'MB-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'MB-102', 'Masa', 'Mobilya - Çalışma', 2200.00, 15, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Mobilya' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'MB-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'MB-103', 'Dolap', 'Mobilya - 2 kapaklı', 4200.00, 10, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Mobilya' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'MB-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'MB-104', 'Koltuk', 'Mobilya - Tekli', 3200.00, 12, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Mobilya' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'MB-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'MB-105', 'Raf', 'Mobilya - Duvar', 400.00, 50, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Mobilya' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'MB-105');

-- Diğer
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'DG-101', 'Diğer Ürün 1', 'Genel', 100.00, 20, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Diğer' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'DG-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'DG-102', 'Diğer Ürün 2', 'Genel', 200.00, 20, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Diğer' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'DG-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'DG-103', 'Diğer Ürün 3', 'Genel', 300.00, 20, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Diğer' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'DG-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'DG-104', 'Diğer Ürün 4', 'Genel', 400.00, 20, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Diğer' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'DG-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'DG-105', 'Diğer Ürün 5', 'Genel', 500.00, 20, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Diğer' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'DG-105');

-- Bilgisayar
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PC-101', 'Laptop Dell', 'Bilgisayar - i7/16GB', 25000.00, 15, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Tech Elektronik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PC-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PC-102', 'Monitör 27"', 'Bilgisayar - 4K IPS', 8500.00, 20, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PC-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PC-103', 'Klavye Mekanik', 'Bilgisayar - RGB', 1800.00, 30, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PC-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PC-104', 'Mouse Kablosuz', 'Bilgisayar - Logitech', 2500.00, 50, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PC-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PC-105', 'USB Hub', 'Bilgisayar - 7 Port USB 3.0', 350.00, 60, 15, 'Adet',
       (SELECT id FROM categories WHERE name = 'Bilgisayar' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'ABC Ticaret' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PC-105');

-- Telefon
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PH-101', 'iPhone 15', 'Telefon - 128GB', 45000.00, 8, 3, 'Adet',
       (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Tech Elektronik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PH-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PH-102', 'Samsung S24', 'Telefon - Ultra 256GB', 52000.00, 12, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Global Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PH-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PH-103', 'Kulaklık BT', 'Telefon - Sony WH-1000XM5', 9000.00, 25, 8, 'Adet',
       (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Tech Elektronik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PH-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PH-104', 'Kilif', 'Telefon - Silikon', 200.00, 100, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Global Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PH-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'PH-105', 'Sarj Aleti', 'Telefon - Hizli Sarj', 450.00, 120, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Telefon' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Global Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'PH-105');

-- Ev Aletleri
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EA-101', 'Blender', 'Ev Aletleri - 600W', 850.00, 40, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Ev Aletleri' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EA-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EA-102', 'Supurge', 'Ev Aletleri - HEPA', 3200.00, 20, 5, 'Adet',
       (SELECT id FROM categories WHERE name = 'Ev Aletleri' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EA-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EA-103', 'Mikser', 'Ev Aletleri - 300W', 650.00, 35, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Ev Aletleri' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EA-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EA-104', 'Ütü', 'Ev Aletleri - Buharlı', 1200.00, 25, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Ev Aletleri' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EA-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'EA-105', 'Kahve Makinesi', 'Ev Aletleri - Filtre', 1800.00, 15, 10, 'Adet',
       (SELECT id FROM categories WHERE name = 'Ev Aletleri' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'Mega Tedarik' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'EA-105');

-- Kırtasiye
INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'KR-101', 'Defter', 'Kırtasiye - Kareli', 45.00, 200, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Kırtasiye' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'KR-101');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'KR-102', 'Kalem Seti', 'Kırtasiye - 10' || 'lu', 60.00, 300, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Kırtasiye' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'KR-102');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'KR-103', 'Silgi', 'Kırtasiye - Yumuşak', 15.00, 400, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Kırtasiye' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'KR-103');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'KR-104', 'Zımba', 'Kırtasiye - Metal', 95.00, 120, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Kırtasiye' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'KR-104');

INSERT INTO products (code, name, description, price, stock_quantity, min_stock_level, unit, category_id, supplier_id, active, created_at, updated_at)
SELECT 'KR-105', 'Ataş', 'Kırtasiye - 100' || 'lü', 20.00, 500, 20, 'Adet',
       (SELECT id FROM categories WHERE name = 'Kırtasiye' LIMIT 1),
       COALESCE((SELECT id FROM suppliers WHERE name = 'XYZ Dağıtım' LIMIT 1), (SELECT id FROM suppliers LIMIT 1)),
       true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE code = 'KR-105');
