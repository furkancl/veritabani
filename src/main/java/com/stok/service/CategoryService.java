package com.stok.service;

import com.stok.model.Category;
import com.stok.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CategoryService {

    @Autowired
    private CategoryRepository categoryRepository;

    public List<Category> findAll() {
        return categoryRepository.findAll();
    }

    public Optional<Category> findById(Long id) {
        return categoryRepository.findById(id);
    }

    public Optional<Category> findByName(String name) {
        return categoryRepository.findByName(name);
    }

    public Category save(Category category) {
        return categoryRepository.save(category);
    }

    public Category update(Category category) {
        Category existingCategory = categoryRepository.findById(category.getId())
                .orElseThrow(() -> new RuntimeException("Kategori bulunamadı"));
        
        existingCategory.setName(category.getName());
        existingCategory.setDescription(category.getDescription());
        
        return categoryRepository.save(existingCategory);
    }

    public void deleteById(Long id) {
        categoryRepository.deleteById(id);
    }

    public boolean existsByName(String name) {
        return categoryRepository.existsByName(name);
    }

    public long count() {
        return categoryRepository.count();
    }

    public void createDefaultCategories() {
        if (categoryRepository.count() == 0) {
            save(new Category("Elektronik", "Elektronik ürünler"));
            save(new Category("Giyim", "Giyim ürünleri"));
            save(new Category("Gıda", "Gıda ürünleri"));
            save(new Category("Mobilya", "Mobilya ürünleri"));
            save(new Category("Diğer", "Diğer ürünler"));
        }
    }
}
