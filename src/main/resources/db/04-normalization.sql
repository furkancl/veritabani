-- ============================================
-- STOK YÖNETİM SİSTEMİ - NORMALİZASYON DOKÜMANTASYONU
-- ============================================

-- ============================================
-- VERİTABANI NORMALİZASYONU (3NF)
-- ============================================

/*
Bu veritabanı tasarımı 3. Normal Form (3NF) kurallarına uygun olarak tasarlanmıştır.

=============================================
1. BİRİNCİ NORMAL FORM (1NF)
=============================================
- Tüm tablolarda atomik (bölünemez) değerler kullanılmıştır
- Her sütun tek bir değer içerir (tekrarlayan gruplar yok)
- Her tablo için benzersiz primary key tanımlanmıştır

Örnek:
- users tablosunda her kullanıcı bilgisi ayrı sütunlarda
- Telefon, email gibi bilgiler ayrı alanlarda tutulur
- Adres bilgisi tek bir metin alanında (suppliers tablosu)

=============================================
2. İKİNCİ NORMAL FORM (2NF)
=============================================
- 1NF sağlanmıştır
- Tüm non-key sütunlar primary key'e TAM BAĞIMLIDIR
- Kısmi bağımlılıklar ayrı tablolara çıkarılmıştır

Örnek:
- products tablosunda category_id foreign key olarak tutulur
- Kategori bilgileri (name, description) ayrı categories tablosunda
- Tedarikçi bilgileri ayrı suppliers tablosunda

=============================================
3. ÜÇÜNCÜ NORMAL FORM (3NF)
=============================================
- 2NF sağlanmıştır  
- Geçişli bağımlılıklar (transitive dependencies) yoktur
- Non-key sütunlar sadece primary key'e bağımlıdır

Örnek:
- Supplier adresi suppliers tablosunda, products tablosunda değil
- Kategori açıklaması categories tablosunda
- Kullanıcı rolü users tablosunda enum olarak

=============================================
TABLO YAPILARI ve NORMALİZASYON
=============================================

1. USERS (Kullanıcılar)
   -----------------------
   PK: id
   Sütunlar: username, password, full_name, email, role, active, created_at, updated_at
   
   Normalizasyon:
   - Tüm alanlar atomik (1NF ✓)
   - Tüm alanlar id'ye tam bağımlı (2NF ✓)
   - Geçişli bağımlılık yok (3NF ✓)

2. CATEGORIES (Kategoriler)
   -----------------------
   PK: id
   Sütunlar: name, description, created_at, updated_at
   
   Normalizasyon:
   - Kategori bilgileri products tablosundan ayrılmış (2NF)
   - Tek sorumluluk: sadece kategori bilgisi

3. SUPPLIERS (Tedarikçiler)
   -----------------------
   PK: id
   Sütunlar: name, contact_person, phone, email, address, active, created_at, updated_at
   
   Normalizasyon:
   - Tedarikçi bilgileri products tablosundan ayrılmış (2NF)
   - İletişim bilgileri atomik alanlar olarak (1NF)

4. PRODUCTS (Ürünler)
   -----------------------
   PK: id
   FK: category_id -> categories(id)
   FK: supplier_id -> suppliers(id)
   Sütunlar: code, name, description, price, stock_quantity, min_stock_level, unit, active, created_at, updated_at
   
   Normalizasyon:
   - Kategori ve tedarikçi bilgileri FK ile referans (2NF, 3NF)
   - Tekrarlayan bilgiler (kategori adı, tedarikçi adı) referans ile

5. STOCK_MOVEMENTS (Stok Hareketleri)
   -----------------------
   PK: id
   FK: product_id -> products(id)
   FK: user_id -> users(id)
   Sütunlar: movement_type, quantity, previous_quantity, new_quantity, description, reference_no, created_at
   
   Normalizasyon:
   - Ürün bilgileri FK ile (2NF)
   - Kullanıcı bilgileri FK ile (2NF)
   - Hareket detayları bu tabloda (doğru yerleşim)

6. AUDIT_LOGS (Denetim Kayıtları)
   -----------------------
   PK: id
   Sütunlar: table_name, record_id, action, old_values, new_values, changed_by, changed_at
   
   Normalizasyon:
   - Log bilgileri bağımsız tablo (3NF)
   - JSON olarak eski/yeni değerler (esneklik)

=============================================
İLİŞKİ DİYAGRAMI
=============================================

users ─────────────┐
                   │ (1:N)
                   ▼
              stock_movements
                   ▲
                   │ (1:N)
products ──────────┘
    │
    ├── (N:1) ──► categories
    │
    └── (N:1) ──► suppliers

audit_logs (bağımsız log tablosu)

=============================================
NORMALİZASYON FAYDALARI
=============================================

1. VERİ BÜTÜNLÜĞÜ
   - Veri tekrarı minimuma indirilmiş
   - Güncelleme anomalileri önlenmiş
   - Silme anomalileri önlenmiş

2. VERİ TUTARLILIĞI
   - Foreign key kısıtlamaları
   - Referans bütünlüğü sağlanmış

3. DEPOLAMA OPTİMİZASYONU
   - Tekrarlayan veriler azaltılmış
   - Disk alanı verimli kullanılmış

4. BAKIM KOLAYLIĞI
   - Değişiklikler tek noktada yapılır
   - Kod tekrarı önlenmiş

=============================================
FOREIGN KEY KISITLAMALARI
=============================================
*/

-- Foreign key kısıtlamalarını kontrol et
-- SELECT 
--     tc.table_name, 
--     kcu.column_name,
--     ccu.table_name AS foreign_table_name,
--     ccu.column_name AS foreign_column_name
-- FROM information_schema.table_constraints AS tc
-- JOIN information_schema.key_column_usage AS kcu
--     ON tc.constraint_name = kcu.constraint_name
-- JOIN information_schema.constraint_column_usage AS ccu
--     ON ccu.constraint_name = tc.constraint_name
-- WHERE tc.constraint_type = 'FOREIGN KEY';

-- ============================================
-- INDEX YAPILARI (Performans için)
-- ============================================

-- Sık kullanılan aramalar için index'ler
CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier ON products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(active);

CREATE INDEX IF NOT EXISTS idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_created ON stock_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_stock_movements_type ON stock_movements(movement_type);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_record ON audit_logs(record_id);
