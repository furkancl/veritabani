package com.stok.controller;

import com.stok.model.MovementType;
import com.stok.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Controller
@RequestMapping("/reports")
public class ReportController {

    @Autowired
    private ProductService productService;

    @Autowired
    private StockMovementService stockMovementService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String reports(Model model) {
        model.addAttribute("activePage", "reports");
        
        // Genel istatistikler
        model.addAttribute("totalProducts", productService.countActive());
        model.addAttribute("totalCategories", categoryService.count());
        model.addAttribute("totalSuppliers", supplierService.count());
        model.addAttribute("totalStockValue", productService.getTotalStockValue());
        
        // Stok hareketleri
        model.addAttribute("totalInQuantity", stockMovementService.sumQuantityByMovementType(MovementType.IN));
        model.addAttribute("totalOutQuantity", stockMovementService.sumQuantityByMovementType(MovementType.OUT));
        model.addAttribute("totalInMovements", stockMovementService.countByMovementType(MovementType.IN));
        model.addAttribute("totalOutMovements", stockMovementService.countByMovementType(MovementType.OUT));
        
        // Düşük stoklu ürünler
        model.addAttribute("lowStockProducts", productService.findLowStockProducts());
        
        // Tüm ürünler (stok sıralı)
        model.addAttribute("allProducts", productService.findAllOrderByStockQuantity());
        
        return "reports/index";
    }

    @GetMapping("/stock-movements")
    public String stockMovementReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Model model) {
        
        if (startDate != null && endDate != null) {
            LocalDateTime start = startDate.atStartOfDay();
            LocalDateTime end = endDate.atTime(LocalTime.MAX);
            model.addAttribute("movements", stockMovementService.findByDateRange(start, end));
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);
        } else {
            model.addAttribute("movements", stockMovementService.findAll());
        }
        
        return "reports/stock-movements";
    }

    @GetMapping("/low-stock")
    public String lowStockReport(Model model) {
        model.addAttribute("products", productService.findLowStockProducts());
        return "reports/low-stock";
    }
}
