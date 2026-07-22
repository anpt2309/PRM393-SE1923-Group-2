package com.example.japanese_learning;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.web.config.EnableSpringDataWebSupport;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
//@EnableSpringDataWebSupport(pageSerializationMode = VIA_DTO)
@EnableSpringDataWebSupport
@EnableScheduling
public class JapaneseLearningApplication {
	public static void main(String[] args) {
		SpringApplication.run(JapaneseLearningApplication.class, args);
	}
}
