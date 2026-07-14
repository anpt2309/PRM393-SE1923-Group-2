package com.example.japanese_learning.features.account.controller;

import com.example.japanese_learning.dto.request.FirebaseRegisterRequest;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.features.account.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin("*")
public class UserController {

    private final UserService userService;

    @PostMapping("/register-firebase")
    public User registerFirebase(
            @RequestBody FirebaseRegisterRequest request) {

        return userService.registerFirebase(request);
    }

}