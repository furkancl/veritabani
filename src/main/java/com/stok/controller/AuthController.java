package com.stok.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AuthController {

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/access-denied")
    public String accessDenied(Model model) {
        model.addAttribute("message", "Bu sayfaya erişim yetkiniz bulunmamaktadır.");
        return "access-denied";
    }
}
