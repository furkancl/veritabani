package com.stok.service;

import com.stok.model.StockMovement;
import com.stok.model.Product;
import com.stok.model.MovementType;
import com.stok.model.User;
import com.stok.repository.StockMovementRepository;
import com.stok.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
@SuppressWarnings("null")
public class StockMovementService {

    @Autowired
    private StockMovementRepository stockMovementRepository;

    @Autowired
    private ProductRepository productRepository;

    public List<StockMovement> findAll() {
        return stockMovementRepository.findAllOrderByCreatedAtDesc();
    }

    public Optional<StockMovement> findById(Long id) {
        return stockMovementRepository.findById(id);
    }

    public List<StockMovement> findByProduct(Product product) {
        return stockMovementRepository.findByProductOrderByCreatedAtDesc(product);
    }

    public List<StockMovement> findByMovementType(MovementType type) {
        return stockMovementRepository.findByMovementType(type);
    }

    public List<StockMovement> findByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return stockMovementRepository.findByDateRange(startDate, endDate);
    }

    public StockMovement createMovement(Long productId, MovementType movementType, 
                                         Integer quantity, String description, User user) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Ürün bulunamadı"));
        
        int previousQuantity = product.getStockQuantity();
        int newQuantity;
        
        if (movementType == MovementType.IN) {
            newQuantity = previousQuantity + quantity;
        } else {
            if (previousQuantity < quantity) {
                throw new RuntimeException("Yetersiz stok miktarı! Mevcut stok: " + previousQuantity);
            }
            newQuantity = previousQuantity - quantity;
        }
        
        product.setStockQuantity(newQuantity);
        productRepository.save(product);
        
        StockMovement movement = new StockMovement();
        movement.setProduct(product);
        movement.setMovementType(movementType);
        movement.setQuantity(quantity);
        movement.setPreviousQuantity(previousQuantity);
        movement.setNewQuantity(newQuantity);
        movement.setDescription(description);
        movement.setReferenceNo(generateReferenceNo());
        movement.setUser(user);
        
        return stockMovementRepository.save(movement);
    }

    public void deleteById(Long id) {
        stockMovementRepository.deleteById(id);
    }

    public long count() {
        return stockMovementRepository.count();
    }

    public long countByMovementType(MovementType type) {
        return stockMovementRepository.countByMovementType(type);
    }

    public Long sumQuantityByMovementType(MovementType type) {
        Long sum = stockMovementRepository.sumQuantityByMovementType(type);
        return sum != null ? sum : 0L;
    }

    private String generateReferenceNo() {
        return "STK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
