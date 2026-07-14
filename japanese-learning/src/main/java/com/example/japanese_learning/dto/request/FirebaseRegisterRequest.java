package com.example.japanese_learning.dto.request;

import lombok.Data;

@Data
public class FirebaseRegisterRequest {

    private String firebaseUid;

    private String email;

    private String username;

    private String avatar;

}