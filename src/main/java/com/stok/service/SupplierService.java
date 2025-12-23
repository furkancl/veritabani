package com.stok.service;

import com.stok.model.Supplier;
import com.stok.repository.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
@SuppressWarnings("null")
public class SupplierService {

    @Autowired
    private SupplierRepository supplierRepository;

    public List<Supplier> findAll() {
        return supplierRepository.findAll();
    }

    public List<Supplier> findAllActive() {
        return supplierRepository.findByActiveTrue();
    }

    public Optional<Supplier> findById(Long id) {
        return supplierRepository.findById(id);
    }

    public List<Supplier> searchByName(String name) {
        return supplierRepository.findByNameContainingIgnoreCase(name);
    }

    public Supplier save(Supplier supplier) {
        return supplierRepository.save(supplier);
    }

    public Supplier update(Supplier supplier) {
        Supplier existingSupplier = supplierRepository.findById(supplier.getId())
                .orElseThrow(() -> new RuntimeException("Tedarikçi bulunamadı"));
        
        existingSupplier.setName(supplier.getName());
        existingSupplier.setContactPerson(supplier.getContactPerson());
        existingSupplier.setPhone(supplier.getPhone());
        existingSupplier.setEmail(supplier.getEmail());
        existingSupplier.setAddress(supplier.getAddress());
        existingSupplier.setActive(supplier.isActive());
        
        return supplierRepository.save(existingSupplier);
    }

    public void deleteById(Long id) {
        supplierRepository.deleteById(id);
    }

    public void deactivate(Long id) {
        Supplier supplier = supplierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tedarikçi bulunamadı"));
        supplier.setActive(false);
        supplierRepository.save(supplier);
    }

    public long count() {
        return supplierRepository.count();
    }

    public void createDefaultSuppliers() {
        if (supplierRepository.count() == 0) {
            Supplier s1 = new Supplier("ABC Ticaret", "Ahmet Yılmaz", "0212-555-1234", 
                                       "info@abcticaret.com", "İstanbul, Türkiye");
            save(s1);
            
            Supplier s2 = new Supplier("XYZ Dağıtım", "Mehmet Demir", "0312-444-5678", 
                                       "info@xyzdagitim.com", "Ankara, Türkiye");
            save(s2);
        }
    }
}
