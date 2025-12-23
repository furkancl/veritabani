package com.stok.config;

import com.stok.model.Category;
import com.stok.model.Product;
import com.stok.model.Supplier;
import com.stok.model.MovementType;
import com.stok.model.User;
import com.stok.service.UserService;
import com.stok.service.CategoryService;
import com.stok.service.SupplierService;
import com.stok.service.ProductService;
import com.stok.service.StockMovementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserService userService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private SupplierService supplierService;

    @Autowired
    private ProductService productService;

    @Autowired
    private StockMovementService stockMovementService;

    @Value("${app.seed.products.enabled:true}")
    private boolean seedProductsEnabled;

    @Override
    public void run(String... args) throws Exception {
        userService.createDefaultAdmin();
        userService.createDefaultStaff();
        categoryService.createDefaultCategories();
        supplierService.createDefaultSuppliers();

        if (seedProductsEnabled) {
            createDefaultProducts();
        }

        System.out.println("Veriler yüklendi.");
    }

    private void createDefaultProducts() {
        Supplier supplier = null;
        List<Supplier> abc = supplierService.searchByName("ABC Ticaret");
        if (!abc.isEmpty()) {
            supplier = abc.get(0);
        } else {
            List<Supplier> actives = supplierService.findAllActive();
            if (!actives.isEmpty()) {
                supplier = actives.get(0);
            }
        }

        if (supplier == null) {
            return;
        }

        User adminUser = userService.findByUsername("admin").orElse(null);

        List<Category> categories = categoryService.findAll();
        for (Category category : categories) {
            int existingCount = productService.findByCategory(category).size();
            int toCreate = Math.max(0, 5 - existingCount);
            if (toCreate == 0) {
                continue;
            }

            List<Product> samples = sampleProductsForCategory(category, supplier);
            for (int i = 0; i < toCreate && i < samples.size(); i++) {
                Product p = samples.get(i);
                if (productService.existsByCode(p.getCode())) {
                    continue;
                }
                
                int initialStock = p.getStockQuantity();
                p.setStockQuantity(0);
                Product savedProduct = productService.save(p);
                
                if (initialStock > 0 && savedProduct != null) {
                    try {
                        stockMovementService.createMovement(
                            savedProduct.getId(),
                            MovementType.IN,
                            initialStock,
                            "İlk stok girişi",
                            adminUser
                        );
                    } catch (Exception e) {
                        // Hata durumunda devam et
                    }
                }
            }
        }
    }

    private List<Product> sampleProductsForCategory(Category category, Supplier supplier) {
        String name = category.getName();
        List<Product> list = new ArrayList<>();

        switch (name) {
            case "Elektronik":
                list.add(new Product("EL-001", "Laptop", "13.3" + " inç, 8GB RAM", new BigDecimal("22000"), 10, category, supplier));
                list.add(new Product("EL-002", "Mouse", "Kablosuz optik mouse", new BigDecimal("450"), 50, category, supplier));
                list.add(new Product("EL-003", "Klavye", "Mekanik klavye", new BigDecimal("1200"), 30, category, supplier));
                list.add(new Product("EL-004", "Monitör", "27 inç IPS", new BigDecimal("7800"), 15, category, supplier));
                list.add(new Product("EL-005", "Kulaklık", "Bluetooth kulak üstü", new BigDecimal("950"), 25, category, supplier));
                break;
            case "Giyim":
                list.add(new Product("GY-001", "T-Shirt", "Pamuklu beyaz T-shirt", new BigDecimal("150"), 100, category, supplier));
                list.add(new Product("GY-002", "Pantolon", "Kot pantolon", new BigDecimal("600"), 60, category, supplier));
                list.add(new Product("GY-003", "Ceket", "Mevsimlik ceket", new BigDecimal("950"), 25, category, supplier));
                list.add(new Product("GY-004", "Ayakkabı", "Spor ayakkabı", new BigDecimal("1200"), 40, category, supplier));
                list.add(new Product("GY-005", "Şapka", "Şapka - siyah", new BigDecimal("180"), 80, category, supplier));
                break;
            case "Gıda":
                list.add(new Product("GD-001", "Makarna", "Duru 500g", new BigDecimal("25"), 200, category, supplier));
                list.add(new Product("GD-002", "Pirinç", "Osmancık 1kg", new BigDecimal("40"), 150, category, supplier));
                list.add(new Product("GD-003", "Zeytinyağı", "Naturel sızma 1L", new BigDecimal("220"), 60, category, supplier));
                list.add(new Product("GD-004", "Şeker", "Kristal 1kg", new BigDecimal("35"), 180, category, supplier));
                list.add(new Product("GD-005", "Kahve", "Filtre kahve 250g", new BigDecimal("140"), 70, category, supplier));
                break;
            case "Mobilya":
                list.add(new Product("MB-001", "Sandalye", "Ahşap sandalye", new BigDecimal("850"), 40, category, supplier));
                list.add(new Product("MB-002", "Masa", "Çalışma masası", new BigDecimal("2200"), 15, category, supplier));
                list.add(new Product("MB-003", "Dolap", "2 kapaklı dolap", new BigDecimal("4200"), 10, category, supplier));
                list.add(new Product("MB-004", "Koltuk", "Tekli koltuk", new BigDecimal("3200"), 12, category, supplier));
                list.add(new Product("MB-005", "Raf", "Duvar rafı", new BigDecimal("400"), 50, category, supplier));
                break;
            default:
                String prefix = codePrefixForCategory(name);
                list.add(new Product(prefix + "-001", name + " Ürün 1", "Örnek ürün", new BigDecimal("100"), 20, category, supplier));
                list.add(new Product(prefix + "-002", name + " Ürün 2", "Örnek ürün", new BigDecimal("200"), 20, category, supplier));
                list.add(new Product(prefix + "-003", name + " Ürün 3", "Örnek ürün", new BigDecimal("300"), 20, category, supplier));
                list.add(new Product(prefix + "-004", name + " Ürün 4", "Örnek ürün", new BigDecimal("400"), 20, category, supplier));
                list.add(new Product(prefix + "-005", name + " Ürün 5", "Örnek ürün", new BigDecimal("500"), 20, category, supplier));
                break;
        }
        return list;
    }

    private String codePrefixForCategory(String categoryName) {
        if (categoryName == null || categoryName.isEmpty()) {
            return "CTG";
        }
        String normalized = categoryName
                .replace("ç", "c").replace("Ç", "C")
                .replace("ğ", "g").replace("Ğ", "G")
                .replace("ı", "i").replace("İ", "I")
                .replace("ö", "o").replace("Ö", "O")
                .replace("ş", "s").replace("Ş", "S")
                .replace("ü", "u").replace("Ü", "U")
                .replaceAll("[^A-Za-z]", "")
                .toUpperCase();
        if (normalized.length() < 2) {
            return "CTG";
        }
        return normalized.substring(0, Math.min(2, normalized.length()));
    }
}
