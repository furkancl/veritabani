-- ============================================
-- STOK YÖNETİM SİSTEMİ - VERİTABANI OLUŞTURMA
-- ============================================

-- Veritabanını oluştur (psql ile çalıştırın)
-- CREATE DATABASE stok_yonetimi;

-- Veritabanına bağlan
-- \c stok_yonetimi;

-- ============================================
-- TABLOLAR (JPA tarafından otomatik oluşturulur)
-- Aşağıdaki tablolar Spring Boot JPA ile oluşturulur
-- Bu script sadece referans amaçlıdır
-- ============================================

-- Not: Aşağıdaki tablolar spring.jpa.hibernate.ddl-auto=update 
-- ayarı sayesinde otomatik oluşturulacaktır.

-- users (Kullanıcılar)
-- categories (Kategoriler)  
-- suppliers (Tedarikçiler)
-- products (Ürünler)
-- stock_movements (Stok Hareketleri)
-- audit_logs (Denetim Kayıtları)
