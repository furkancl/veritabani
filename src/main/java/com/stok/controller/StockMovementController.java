package com.stok.controller;

import com.stok.model.StockMovement;
import com.stok.model.MovementType;
import com.stok.model.User;
import com.stok.service.StockMovementService;
import com.stok.service.ProductService;
import com.stok.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/stock-movements")
public class StockMovementController {

    @Autowired
    private StockMovementService stockMovementService;

    @Autowired
    private ProductService productService;

    @Autowired
    private UserService userService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activePage", "stock-movements");
        model.addAttribute("movements", stockMovementService.findAll());
        return "stock-movements/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("activePage", "stock-movements");
        model.addAttribute("movement", new StockMovement());
        model.addAttribute("products", productService.findAllActive());
        model.addAttribute("movementTypes", MovementType.values());
        return "stock-movements/form";
    }

    @PostMapping("/save")
    public String save(@RequestParam Long productId,
                       @RequestParam MovementType movementType,
                       @RequestParam Integer quantity,
                       @RequestParam(required = false) String description,
                       Authentication authentication,
                       RedirectAttributes redirectAttributes) {
        try {
            User user = userService.findByUsername(authentication.getName()).orElse(null);
            stockMovementService.createMovement(productId, movementType, quantity, description, user);
            
            String message = movementType == MovementType.IN ? 
                    "Stok girişi başarıyla kaydedildi." : 
                    "Stok çıkışı başarıyla kaydedildi.";
            redirectAttributes.addFlashAttribute("successMessage", message);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }

        return "redirect:/stock-movements";
    }

    @GetMapping("/product/{id}")
    public String productMovements(@PathVariable Long id, Model model, RedirectAttributes redirectAttributes) {
        return productService.findById(id)
                .map(product -> {
                    model.addAttribute("movements", stockMovementService.findByProduct(product));
                    model.addAttribute("product", product);
                    return "stock-movements/product-movements";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("errorMessage", "Ürün bulunamadı.");
                    return "redirect:/stock-movements";
                });
    }

    @GetMapping("/in")
    public String inMovements(Model model) {
        model.addAttribute("movements", stockMovementService.findByMovementType(MovementType.IN));
        model.addAttribute("filterType", "Stok Girişleri");
        return "stock-movements/list";
    }

    @GetMapping("/out")
    public String outMovements(Model model) {
        model.addAttribute("movements", stockMovementService.findByMovementType(MovementType.OUT));
        model.addAttribute("filterType", "Stok Çıkışları");
        return "stock-movements/list";
    }
}
