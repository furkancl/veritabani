package com.stok.controller;

import com.stok.model.Category;
import com.stok.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/categories")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activePage", "categories");
        model.addAttribute("categories", categoryService.findAll());
        return "categories/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("activePage", "categories");
        model.addAttribute("category", new Category());
        return "categories/form";
    }

    @PostMapping("/save")
    public String save(@Valid @ModelAttribute Category category, BindingResult result, 
                       Model model, RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            return "categories/form";
        }

        if (category.getId() == null && categoryService.existsByName(category.getName())) {
            result.rejectValue("name", "error.category", "Bu kategori adı zaten mevcut");
            return "categories/form";
        }

        try {
            if (category.getId() == null) {
                categoryService.save(category);
                redirectAttributes.addFlashAttribute("successMessage", "Kategori başarıyla oluşturuldu.");
            } else {
                categoryService.update(category);
                redirectAttributes.addFlashAttribute("successMessage", "Kategori başarıyla güncellendi.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bir hata oluştu: " + e.getMessage());
        }

        return "redirect:/categories";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        return categoryService.findById(id)
                .map(category -> {
                    model.addAttribute("category", category);
                    return "categories/form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("errorMessage", "Kategori bulunamadı.");
                    return "redirect:/categories";
                });
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            categoryService.deleteById(id);
            redirectAttributes.addFlashAttribute("successMessage", "Kategori başarıyla silindi.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Kategori silinemedi. Bu kategoriye bağlı ürünler olabilir.");
        }
        return "redirect:/categories";
    }
}
