package com.petcare.user.service;

import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.user.domain.Role;
import com.petcare.user.domain.User;
import com.petcare.user.dto.UpdateProfileRequest;
import com.petcare.user.dto.UserResponse;
import com.petcare.user.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Set;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserResponse getById(String id) {
        return UserResponse.from(findOrThrow(id));
    }

    @Override
    public UserResponse updateProfile(String userId, UpdateProfileRequest request) {
        User user = findOrThrow(userId);
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setPhone(request.phone());
        return UserResponse.from(userRepository.save(user));
    }

    @Override
    public Page<UserResponse> list(Pageable pageable) {
        return userRepository.findAll(pageable).map(UserResponse::from);
    }

    @Override
    public UserResponse updateRoles(String userId, Set<Role> roles) {
        User user = findOrThrow(userId);
        user.setRoles(roles);
        return UserResponse.from(userRepository.save(user));
    }

    @Override
    public UserResponse updateStatus(String userId, boolean enabled) {
        User user = findOrThrow(userId);
        user.setEnabled(enabled);
        return UserResponse.from(userRepository.save(user));
    }

    private User findOrThrow(String id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }
}
