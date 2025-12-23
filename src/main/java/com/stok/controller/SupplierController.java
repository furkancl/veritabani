package com.stok.controller;

import com.stok.model.Supplier;
import com.stok.service.SupplierService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/suppliers")
public class SupplierController {

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activePage", "suppliers");
        model.addAttribute("suppliers", supplierService.findAll());
        return "suppliers/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("activePage", "suppliers");
        model.addAttribute("supplier", new Supplier());
        return "suppliers/form";
    }

    @PostMapping("/save")
    public String save(@Valid @ModelAttribute Supplier supplier, BindingResult result, 
                       Model model, RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            return "suppliers/form";
        }

        try {
            if (supplier.getId() == null) {
                supplierService.save(supplier);
                redirectAttributes.addFlashAttribute("successMessage", "Tedarikçi başarıyla oluşturuldu.");
            } else {
                supplierService.update(supplier);
                redirectAttributes.addFlashAttribute("successMessage", "Tedarikçi başarıyla güncellendi.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bir hata oluştu: " + e.getMessage());
        }

        return "redirect:/suppliers";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        return supplierService.findById(id)
                .map(supplier -> {
                    model.addAttribute("supplier", supplier);
                    return "suppliers/form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("errorMessage", "Tedarikçi bulunamadı.");
                    return "redirect:/suppliers";
                });
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            supplierService.deleteById(id);
            redirectAttributes.addFlashAttribute("successMessage", "Tedarikçi başarıyla silindi.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Tedarikçi silinemedi. Bu tedarikçiye bağlı ürünler olabilir.");
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/deactivate/{id}")
    public String deactivate(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            supplierService.deactivate(id);
            redirectAttributes.addFlashAttribute("successMessage", "Tedarikçi devre dışı bırakıldı.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "İşlem başarısız: " + e.getMessage());
        }
        return "redirect:/suppliers";
    }
}
