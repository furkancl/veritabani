package com.stok.controller;

import com.stok.model.MovementType;
import com.stok.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    @Autowired
    private ProductService productService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private SupplierService supplierService;

    @Autowired
    private StockMovementService stockMovementService;

    @Autowired
    private UserService userService;

    @GetMapping({"/", "/dashboard"})
    public String dashboard(Model model) {
        model.addAttribute("activePage", "dashboard");
        
        // İstatistikler
        model.addAttribute("totalProducts", productService.countActive());
        model.addAttribute("totalCategories", categoryService.count());
        model.addAttribute("totalSuppliers", supplierService.count());
        model.addAttribute("totalUsers", userService.count());
        model.addAttribute("totalStockValue", productService.getTotalStockValue());
        
        // Stok hareketleri sayısı
        model.addAttribute("totalInMovements", stockMovementService.countByMovementType(MovementType.IN));
        model.addAttribute("totalOutMovements", stockMovementService.countByMovementType(MovementType.OUT));
        
        // Düşük stoklu ürünler
        model.addAttribute("lowStockProducts", productService.findLowStockProducts());
        
        // Son stok hareketleri
        model.addAttribute("recentMovements", stockMovementService.findAll().stream().limit(10).toList());
        
        return "dashboard";
    }
}
