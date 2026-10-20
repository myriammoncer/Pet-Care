package com.petcare.user.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.common.dto.PageResponse;
import com.petcare.common.security.SecurityUtils;
import com.petcare.user.dto.UpdateProfileRequest;
import com.petcare.user.dto.UpdateRolesRequest;
import com.petcare.user.dto.UserResponse;
import com.petcare.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Gestion du profil courant et administration des comptes (/users).
 */
@RestController
@RequestMapping("/users")
@Tag(name = "Users", description = "Profil et administration des utilisateurs")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    @Operation(summary = "Profil de l'utilisateur courant")
    public ApiResponse<UserResponse> me() {
        return ApiResponse.ok(userService.getById(SecurityUtils.currentUserId()));
    }

    @PutMapping("/me")
    @Operation(summary = "Mise à jour du profil courant")
    public ApiResponse<UserResponse> updateMe(@Valid @RequestBody UpdateProfileRequest request) {
        return ApiResponse.ok(userService.updateProfile(SecurityUtils.currentUserId(), request));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Liste paginée des utilisateurs (admin)")
    public ApiResponse<PageResponse<UserResponse>> list(Pageable pageable) {
        return ApiResponse.ok(PageResponse.from(userService.list(pageable)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Détail d'un utilisateur (admin)")
    public ApiResponse<UserResponse> getById(@PathVariable String id) {
        return ApiResponse.ok(userService.getById(id));
    }

    @PatchMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Modifier les rôles d'un utilisateur (admin)")
    public ApiResponse<UserResponse> updateRoles(@PathVariable String id,
                                                 @Valid @RequestBody UpdateRolesRequest request) {
        return ApiResponse.ok(userService.updateRoles(id, request.roles()));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Activer / désactiver un compte (admin)")
    public ApiResponse<UserResponse> updateStatus(@PathVariable String id, @RequestParam boolean enabled) {
        return ApiResponse.ok(userService.updateStatus(id, enabled));
    }
}
