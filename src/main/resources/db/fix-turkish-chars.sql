-- Türkçe karakter düzeltme scripti
-- Bozuk karakterleri düzelt

UPDATE products SET name = 'Şapka' WHERE code = 'GY-105';
UPDATE products SET name = 'Pirinç' WHERE code = 'GD-102';
UPDATE products SET name = 'Zeytinyağı' WHERE code = 'GD-103';
UPDATE products SET name = 'Şeker' WHERE code = 'GD-104';
UPDATE products SET name = 'Kılıf' WHERE code = 'PH-104';
UPDATE products SET name = 'Şarj Aleti' WHERE code = 'PH-105';
UPDATE products SET name = 'Süpürge' WHERE code = 'EA-102';

-- Açıklamaları da düzelt
UPDATE products SET description = 'Gıda - 500g' WHERE code = 'GD-101';
UPDATE products SET description = 'Gıda - 1kg' WHERE code = 'GD-102';
UPDATE products SET description = 'Gıda - 1L' WHERE code = 'GD-103';
UPDATE products SET description = 'Gıda - 1kg' WHERE code = 'GD-104';
UPDATE products SET description = 'Gıda - 250g' WHERE code = 'GD-105';
UPDATE products SET description = 'Telefon - Hızlı Şarj' WHERE code = 'PH-105';

SELECT code, name, description FROM products WHERE code IN ('GY-105', 'GD-102', 'GD-103', 'GD-104', 'PH-104', 'PH-105', 'EA-102') ORDER BY code;
