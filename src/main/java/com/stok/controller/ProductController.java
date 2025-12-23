package com.stok.controller;

import com.stok.model.Product;
import com.stok.service.ProductService;
import com.stok.service.CategoryService;
import com.stok.service.SupplierService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activePage", "products");
        model.addAttribute("products", productService.findAll());
        return "products/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("activePage", "products");
        model.addAttribute("product", new Product());
        model.addAttribute("categories", categoryService.findAll());
        model.addAttribute("suppliers", supplierService.findAllActive());
        return "products/form";
    }

    @PostMapping("/save")
    public String save(@Valid @ModelAttribute Product product, BindingResult result, 
                       Model model, RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("categories", categoryService.findAll());
            model.addAttribute("suppliers", supplierService.findAllActive());
            return "products/form";
        }

        if (product.getId() == null && productService.existsByCode(product.getCode())) {
            result.rejectValue("code", "error.product", "Bu ürün kodu zaten mevcut");
            model.addAttribute("categories", categoryService.findAll());
            model.addAttribute("suppliers", supplierService.findAllActive());
            return "products/form";
        }

        try {
            if (product.getId() == null) {
                productService.save(product);
                redirectAttributes.addFlashAttribute("successMessage", "Ürün başarıyla oluşturuldu.");
            } else {
                productService.update(product);
                redirectAttributes.addFlashAttribute("successMessage", "Ürün başarıyla güncellendi.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bir hata oluştu: " + e.getMessage());
        }

        return "redirect:/products";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        return productService.findById(id)
                .map(product -> {
                    model.addAttribute("product", product);
                    model.addAttribute("categories", categoryService.findAll());
                    model.addAttribute("suppliers", supplierService.findAllActive());
                    return "products/form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("errorMessage", "Ürün bulunamadı.");
                    return "redirect:/products";
                });
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            productService.deleteById(id);
            redirectAttributes.addFlashAttribute("successMessage", "Ürün başarıyla silindi.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Ürün silinemedi: " + e.getMessage());
        }
        return "redirect:/products";
    }

    @GetMapping("/deactivate/{id}")
    public String deactivate(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            productService.deactivate(id);
            redirectAttributes.addFlashAttribute("successMessage", "Ürün devre dışı bırakıldı.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "İşlem başarısız: " + e.getMessage());
        }
        return "redirect:/products";
    }

    @GetMapping("/low-stock")
    public String lowStock(Model model) {
        model.addAttribute("products", productService.findLowStockProducts());
        model.addAttribute("isLowStockView", true);
        return "products/list";
    }

    @GetMapping("/search")
    public String search(@RequestParam String query, Model model) {
        model.addAttribute("products", productService.searchByName(query));
        model.addAttribute("searchQuery", query);
        return "products/list";
    }
}
