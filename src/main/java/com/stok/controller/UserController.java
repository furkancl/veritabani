package com.stok.controller;

import com.stok.model.User;
import com.stok.model.Role;
import com.stok.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/users")
@PreAuthorize("hasRole('ADMIN')")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activePage", "users");
        model.addAttribute("users", userService.findAll());
        return "users/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("activePage", "users");
        model.addAttribute("user", new User());
        model.addAttribute("roles", Role.values());
        return "users/form";
    }

    @PostMapping("/save")
    public String save(@Valid @ModelAttribute User user, BindingResult result, 
                       Model model, RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("roles", Role.values());
            return "users/form";
        }

        if (user.getId() == null && userService.existsByUsername(user.getUsername())) {
            result.rejectValue("username", "error.user", "Bu kullanıcı adı zaten kullanılıyor");
            model.addAttribute("roles", Role.values());
            return "users/form";
        }

        try {
            if (user.getId() == null) {
                userService.save(user);
                redirectAttributes.addFlashAttribute("successMessage", "Kullanıcı başarıyla oluşturuldu.");
            } else {
                userService.update(user);
                redirectAttributes.addFlashAttribute("successMessage", "Kullanıcı başarıyla güncellendi.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bir hata oluştu: " + e.getMessage());
        }

        return "redirect:/users";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        return userService.findById(id)
                .map(user -> {
                    user.setPassword(""); // Şifreyi gösterme
                    model.addAttribute("user", user);
                    model.addAttribute("roles", Role.values());
                    return "users/form";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("errorMessage", "Kullanıcı bulunamadı.");
                    return "redirect:/users";
                });
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            userService.deleteById(id);
            redirectAttributes.addFlashAttribute("successMessage", "Kullanıcı başarıyla silindi.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Kullanıcı silinemedi: " + e.getMessage());
        }
        return "redirect:/users";
    }

    @GetMapping("/deactivate/{id}")
    public String deactivate(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            userService.deactivate(id);
            redirectAttributes.addFlashAttribute("successMessage", "Kullanıcı hesabı devre dışı bırakıldı.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "İşlem başarısız: " + e.getMessage());
        }
        return "redirect:/users";
    }
}
