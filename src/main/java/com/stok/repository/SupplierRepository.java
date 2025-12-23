package com.stok.repository;

import com.stok.model.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SupplierRepository extends JpaRepository<Supplier, Long> {
    List<Supplier> findByActiveTrue();
    List<Supplier> findByNameContainingIgnoreCase(String name);
}
