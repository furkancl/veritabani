# Stok Yönetim Sistemi

Java Spring Boot ile geliştirilmiş, PostgreSQL veritabanı kullanan web tabanlı stok yönetim uygulaması.

## 📋 Proje Özellikleri

### İsterler Karşılama Durumu

| İster | Durum | Açıklama |
|-------|-------|----------|
| PostgreSQL veritabanı | ✅ | PostgreSQL 12+ desteklenir |
| Java dili | ✅ | Java 17 + Spring Boot 3.2 |
| En az 3 nesne için CRUD | ✅ | 5 nesne: User, Product, Category, Supplier, StockMovement |
| Web tabanlı uygulama | ✅ | Thymeleaf + Bootstrap 5 |
| Stored Procedure | ✅ | 5 adet SP tanımlı |
| Trigger | ✅ | 4 adet Trigger tanımlı |
| Normalizasyon | ✅ | 3NF uygulandı |
| Kullanıcı giriş paneli | ✅ | Spring Security |
| En az 2 kullanıcı tipi | ✅ | ADMIN ve STAFF rolleri |
| Sorgu arayüzleri | ✅ | Raporlar ve arama sayfaları |

## 🛠️ Teknolojiler

- **Backend:** Java 17, Spring Boot 3.2
- **Frontend:** Thymeleaf, Bootstrap 5, Bootstrap Icons
- **Veritabanı:** PostgreSQL
- **Güvenlik:** Spring Security
- **ORM:** Spring Data JPA / Hibernate

## 📁 Proje Yapısı

```
stok-yonetimi/
├── src/main/java/com/stok/
│   ├── config/           # Güvenlik ve başlangıç ayarları
│   ├── controller/       # Web controller'lar
│   ├── model/            # Entity sınıfları
│   ├── repository/       # JPA repository'ler
│   └── service/          # İş mantığı servisleri
├── src/main/resources/
│   ├── templates/        # Thymeleaf HTML şablonları
│   ├── db/               # SQL scriptleri
│   └── application.properties
└── pom.xml
```

## 🚀 Kurulum

### 1. Gereksinimler

- Java 17+
- Maven 3.6+
- PostgreSQL 12+

### 2. Veritabanı Oluşturma

PostgreSQL'de veritabanını oluşturun:

```sql
CREATE DATABASE stok_yonetimi;
```

### 3. Uygulama Ayarları

`src/main/resources/application.properties` dosyasını kontrol edin:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/stok_yonetimi
spring.datasource.username=postgres
spring.datasource.password=Furkan.1773
```

### 4. Projeyi Çalıştırma

```bash
cd stok-yonetimi
mvn spring-boot:run
```

### 5. Stored Procedure ve Trigger'ları Yükleme

Uygulama çalıştıktan sonra (tablolar oluşturulduktan sonra):

```bash
psql -U postgres -d stok_yonetimi -f src/main/resources/db/02-stored-procedures.sql
psql -U postgres -d stok_yonetimi -f src/main/resources/db/03-triggers.sql
psql -U postgres -d stok_yonetimi -f src/main/resources/db/04-normalization.sql
```

### 6. Uygulamaya Erişim

Tarayıcıda açın: **http://localhost:8080**

Varsayılan giriş bilgileri:
- **Kullanıcı Adı:** admin
- **Şifre:** admin123

## 📊 Veritabanı Şeması

### Tablolar

| Tablo | Açıklama |
|-------|----------|
| users | Kullanıcı bilgileri |
| categories | Ürün kategorileri |
| suppliers | Tedarikçi bilgileri |
| products | Ürün bilgileri |
| stock_movements | Stok giriş/çıkış hareketleri |
| audit_logs | Değişiklik kayıtları |

### Stored Procedures

1. **sp_update_stock** - Stok güncelleme
2. **sp_get_low_stock_products** - Düşük stoklu ürünleri getir
3. **sp_monthly_stock_report** - Aylık stok raporu
4. **sp_calculate_stock_value** - Stok değeri hesaplama
5. **sp_search_products** - Ürün arama

### Triggers

1. **trg_product_audit** - Ürün değişikliklerini kaydet
2. **trg_user_audit** - Kullanıcı değişikliklerini kaydet
3. **trg_low_stock_alert** - Düşük stok uyarısı
4. **trg_prevent_product_delete** - Stok hareketi olan ürün silmeyi engelle

## 👥 Kullanıcı Rolleri

| Rol | Yetkiler |
|-----|----------|
| ADMIN | Tüm işlemler + Kullanıcı yönetimi |
| STAFF | Stok işlemleri (kullanıcı yönetimi hariç) |

## 📱 Sayfalar

| Sayfa | URL | Açıklama |
|-------|-----|----------|
| Giriş | /login | Kullanıcı girişi |
| Dashboard | /dashboard | Ana panel, istatistikler |
| Ürünler | /products | Ürün CRUD işlemleri |
| Kategoriler | /categories | Kategori yönetimi |
| Tedarikçiler | /suppliers | Tedarikçi yönetimi |
| Stok Hareketleri | /stock-movements | Giriş/çıkış işlemleri |
| Raporlar | /reports | Stok raporları |
| Kullanıcılar | /users | Kullanıcı yönetimi (sadece Admin) |

## 📈 Özellikler

- ✅ Ürün ekleme, düzenleme, silme
- ✅ Kategori yönetimi
- ✅ Tedarikçi yönetimi
- ✅ Stok giriş/çıkış işlemleri
- ✅ Düşük stok uyarıları
- ✅ Tarih bazlı stok raporları
- ✅ Ürün arama
- ✅ Kullanıcı yetkilendirme
- ✅ Audit log (değişiklik takibi)

## 🔒 Güvenlik

- BCrypt ile şifre hashleme
- Role-based access control (RBAC)
- CSRF koruması
- Session yönetimi

## 📝 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.
