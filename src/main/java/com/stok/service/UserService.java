package com.stok.service;

import com.stok.model.User;
import com.stok.model.Role;
import com.stok.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${app.default-admin.password:admin123456}")
    private String defaultAdminPassword;

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public List<User> findAllActive() {
        return userRepository.findByActiveTrue();
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public User save(User user) {
        if (user.getId() == null) {
            // Yeni kullanıcı - şifreyi encode et
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        return userRepository.save(user);
    }

    public User update(User user) {
        User existingUser = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        
        existingUser.setUsername(user.getUsername());
        existingUser.setFullName(user.getFullName());
        existingUser.setEmail(user.getEmail());
        existingUser.setRole(user.getRole());
        existingUser.setActive(user.isActive());
        
        // Şifre değiştirilmişse
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            existingUser.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        
        return userRepository.save(existingUser);
    }

    public void deleteById(Long id) {
        userRepository.deleteById(id);
    }

    public void deactivate(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        user.setActive(false);
        userRepository.save(user);
    }

    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public long count() {
        return userRepository.count();
    }

    public void createDefaultAdmin() {
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(defaultAdminPassword);
            admin.setFullName("Sistem Yöneticisi");
            admin.setEmail("admin@stok.com");
            admin.setRole(Role.ADMIN);
            admin.setActive(true);
            save(admin);
        }
    }

    public void createDefaultStaff() {
        if (!userRepository.existsByUsername("sorumlu")) {
            User staff = new User();
            staff.setUsername("sorumlu");
            staff.setPassword("sorumlu123");
            staff.setFullName("Depo Sorumlusu");
            staff.setEmail("sorumlu@stok.com");
            staff.setRole(Role.STAFF);
            staff.setActive(true);
            save(staff);
        }
    }
}
