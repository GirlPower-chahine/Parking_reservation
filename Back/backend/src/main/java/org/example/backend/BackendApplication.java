package org.example.backend;

import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EntityScan("org.example.backend.entity")
@EnableJpaRepositories("org.example.backend.repository")
@EnableRabbit          // ← 🆕 AJOUT pour activer RabbitMQ listeners
@EnableScheduling      // ← 🆕 AJOUT pour vos tâches planifiées (expire reservations, etc.)
public class BackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(BackendApplication.class, args);
	}

}