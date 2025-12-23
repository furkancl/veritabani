package com.stok.repository;

import com.stok.model.Product;
import com.stok.model.Category;
import com.stok.model.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findByCode(String code);
    boolean existsByCode(String code);
    List<Product> findByActiveTrue();
    List<Product> findByCategory(Category category);
    List<Product> findBySupplier(Supplier supplier);
    List<Product> findByNameContainingIgnoreCase(String name);
    
    @Query("SELECT p FROM Product p WHERE p.stockQuantity <= p.minStockLevel AND p.active = true")
    List<Product> findLowStockProducts();
    
    @Query("SELECT p FROM Product p WHERE p.active = true ORDER BY p.stockQuantity ASC")
    List<Product> findAllOrderByStockQuantity();
    
    @Query("SELECT COUNT(p) FROM Product p WHERE p.active = true")
    long countActiveProducts();
    
    @Query("SELECT SUM(p.stockQuantity * p.price) FROM Product p WHERE p.active = true")
    Double getTotalStockValue();
    
    // Stored Procedure çağrısı
    @Procedure(name = "sp_update_stock")
    void updateStock(@Param("p_product_id") Long productId, 
                     @Param("p_quantity") Integer quantity, 
                     @Param("p_movement_type") String movementType);
}
