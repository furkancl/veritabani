package com.stok.service;

import com.stok.model.Product;
import com.stok.model.Category;
import com.stok.model.Supplier;
import com.stok.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@SuppressWarnings("null")
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    public List<Product> findAll() {
        return productRepository.findAll();
    }

    public List<Product> findAllActive() {
        return productRepository.findByActiveTrue();
    }

    public Optional<Product> findById(Long id) {
        return productRepository.findById(id);
    }

    public Optional<Product> findByCode(String code) {
        return productRepository.findByCode(code);
    }

    public List<Product> findByCategory(Category category) {
        return productRepository.findByCategory(category);
    }

    public List<Product> findBySupplier(Supplier supplier) {
        return productRepository.findBySupplier(supplier);
    }

    public List<Product> searchByName(String name) {
        return productRepository.findByNameContainingIgnoreCase(name);
    }

    public List<Product> findLowStockProducts() {
        return productRepository.findLowStockProducts();
    }

    public List<Product> findAllOrderByStockQuantity() {
        return productRepository.findAllOrderByStockQuantity();
    }

    public Product save(Product product) {
        return productRepository.save(product);
    }

    public Product update(Product product) {
        Product existingProduct = productRepository.findById(product.getId())
                .orElseThrow(() -> new RuntimeException("Ürün bulunamadı"));
        
        existingProduct.setCode(product.getCode());
        existingProduct.setName(product.getName());
        existingProduct.setDescription(product.getDescription());
        existingProduct.setPrice(product.getPrice());
        existingProduct.setMinStockLevel(product.getMinStockLevel());
        existingProduct.setUnit(product.getUnit());
        existingProduct.setCategory(product.getCategory());
        existingProduct.setSupplier(product.getSupplier());
        existingProduct.setActive(product.isActive());
        
        return productRepository.save(existingProduct);
    }

    public void deleteById(Long id) {
        productRepository.deleteById(id);
    }

    public void deactivate(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ürün bulunamadı"));
        product.setActive(false);
        productRepository.save(product);
    }

    public boolean existsByCode(String code) {
        return productRepository.existsByCode(code);
    }

    public long countActive() {
        return productRepository.countActiveProducts();
    }

    public Double getTotalStockValue() {
        Double value = productRepository.getTotalStockValue();
        return value != null ? value : 0.0;
    }

    public long count() {
        return productRepository.count();
    }

    // Stok güncelleme (manuel)
    public void updateStock(Long productId, int quantity, boolean isIncoming) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Ürün bulunamadı"));
        
        int currentStock = product.getStockQuantity();
        int newStock;
        
        if (isIncoming) {
            newStock = currentStock + quantity;
        } else {
            if (currentStock < quantity) {
                throw new RuntimeException("Yetersiz stok miktarı!");
            }
            newStock = currentStock - quantity;
        }
        
        product.setStockQuantity(newStock);
        productRepository.save(product);
    }
}
