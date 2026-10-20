package com.petcare.event.repository;

import com.petcare.event.domain.Event;
import com.petcare.event.domain.EventType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.time.Instant;

public interface EventRepository extends MongoRepository<Event, String> {

    Page<Event> findByStartAtAfter(Instant from, Pageable pageable);

    Page<Event> findByTypeAndStartAtAfter(EventType type, Instant from, Pageable pageable);
}
