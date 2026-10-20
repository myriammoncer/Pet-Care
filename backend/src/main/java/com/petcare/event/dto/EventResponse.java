package com.petcare.event.dto;

import com.petcare.event.domain.Event;
import com.petcare.event.domain.EventType;

import java.time.Instant;

public record EventResponse(
        String id,
        String title,
        String description,
        EventType type,
        Instant startAt,
        Instant endAt,
        String location,
        int capacity,
        int registeredCount,
        boolean full
) {
    public static EventResponse from(Event e) {
        return new EventResponse(e.getId(), e.getTitle(), e.getDescription(), e.getType(),
                e.getStartAt(), e.getEndAt(), e.getLocation(), e.getCapacity(),
                e.getParticipants().size(), e.isFull());
    }
}
