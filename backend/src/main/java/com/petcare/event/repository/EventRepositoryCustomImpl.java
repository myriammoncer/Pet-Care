package com.petcare.event.repository;

import com.petcare.event.domain.Event;
import com.petcare.event.domain.EventType;
import org.bson.Document;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;

import java.time.Instant;
import java.util.List;

public class EventRepositoryCustomImpl implements EventRepositoryCustom {

    private final MongoTemplate mongoTemplate;

    public EventRepositoryCustomImpl(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    @Override
    public Page<Event> search(EventType type, Instant from, Instant to, Pageable pageable) {
        Query query = new Query();
        if (type != null) {
            query.addCriteria(Criteria.where("type").is(type));
        }
        if (from != null || to != null) {
            Criteria start = Criteria.where("startAt");
            if (from != null) start = start.gte(from);
            if (to != null) start = start.lte(to);
            query.addCriteria(start);
        }

        // On compte AVANT d'appliquer skip/limit pour une pagination correcte.
        long total = mongoTemplate.count(query, Event.class);
        query.with(pageable);
        List<Event> events = mongoTemplate.find(query, Event.class);
        return new PageImpl<>(events, pageable, total);
    }

    @Override
    public boolean addParticipant(String eventId, int expectedCapacity, Event.Participant participant) {
        if (expectedCapacity <= 0) {
            return false;
        }
        // "participants.<capacity-1>" absent  <=>  moins de `capacity` participants.
        Query query = new Query(new Criteria().andOperator(
                Criteria.where("_id").is(eventId),
                Criteria.where("capacity").is(expectedCapacity),
                Criteria.where("participants.userId").ne(participant.getUserId()),
                Criteria.where("participants." + (expectedCapacity - 1)).exists(false)
        ));
        Update update = new Update()
                .push("participants", participant)
                .set("updatedAt", Instant.now());
        return mongoTemplate.updateFirst(query, update, Event.class).getModifiedCount() > 0;
    }

    @Override
    public boolean removeParticipant(String eventId, String userId) {
        Query query = new Query(Criteria.where("_id").is(eventId).and("participants.userId").is(userId));
        Update update = new Update()
                .pull("participants", new Document("userId", userId))
                .set("updatedAt", Instant.now());
        return mongoTemplate.updateFirst(query, update, Event.class).getModifiedCount() > 0;
    }
}
