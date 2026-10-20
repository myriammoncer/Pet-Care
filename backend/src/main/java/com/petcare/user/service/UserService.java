package com.petcare.user.service;

import com.petcare.user.domain.Role;
import com.petcare.user.dto.UpdateProfileRequest;
import com.petcare.user.dto.UserResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Set;

/**
 * Gestion des comptes utilisateurs et des rôles.
 */
public interface UserService {

    UserResponse getById(String id);

    UserResponse updateProfile(String userId, UpdateProfileRequest request);

    Page<UserResponse> list(Pageable pageable);

    UserResponse updateRoles(String userId, Set<Role> roles);

    UserResponse updateStatus(String userId, boolean enabled);
}
