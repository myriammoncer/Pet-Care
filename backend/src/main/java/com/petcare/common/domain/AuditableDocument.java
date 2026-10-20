package com.petcare.common.domain;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;

import java.time.Instant;

/**
 * Classe de base des documents MongoDB : identifiant + champs d'audit
 * (gérés automatiquement grâce à {@code @EnableMongoAuditing}).
 */
@Getter
@Setter
public abstract class AuditableDocument {

    @Id
    private String id;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
