package com.stok.repository;

import com.stok.model.StockMovement;
import com.stok.model.Product;
import com.stok.model.MovementType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    List<StockMovement> findByProduct(Product product);
    List<StockMovement> findByMovementType(MovementType movementType);
    List<StockMovement> findByProductOrderByCreatedAtDesc(Product product);
    
    @Query("SELECT sm FROM StockMovement sm ORDER BY sm.createdAt DESC")
    List<StockMovement> findAllOrderByCreatedAtDesc();
    
    @Query("SELECT sm FROM StockMovement sm WHERE sm.createdAt BETWEEN :startDate AND :endDate ORDER BY sm.createdAt DESC")
    List<StockMovement> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                         @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT COUNT(sm) FROM StockMovement sm WHERE sm.movementType = :type")
    long countByMovementType(@Param("type") MovementType type);
    
    @Query("SELECT SUM(sm.quantity) FROM StockMovement sm WHERE sm.movementType = :type")
    Long sumQuantityByMovementType(@Param("type") MovementType type);
}
