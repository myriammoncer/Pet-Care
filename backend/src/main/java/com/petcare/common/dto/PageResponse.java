package com.petcare.common.dto;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Représentation paginée renvoyée par les endpoints de liste.
 */
public record PageResponse<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages
) {
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getContent(),
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages()
        );
    }
}
