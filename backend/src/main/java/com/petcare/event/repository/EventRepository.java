package com.petcare.event.repository;

import com.petcare.event.domain.Event;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface EventRepository extends MongoRepository<Event, String>, EventRepositoryCustom {

    /** Événements auxquels l'utilisateur est inscrit. */
    @Query("{ 'participants.userId': ?0 }")
    List<Event> findRegisteredBy(String userId, Sort sort);
}
