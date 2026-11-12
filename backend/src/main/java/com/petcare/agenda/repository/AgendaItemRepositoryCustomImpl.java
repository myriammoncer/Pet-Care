package com.petcare.agenda.repository;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

import java.time.Instant;
import java.util.List;

public class AgendaItemRepositoryCustomImpl implements AgendaItemRepositoryCustom {

    private final MongoTemplate mongoTemplate;

    public AgendaItemRepositoryCustomImpl(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    @Override
    public Page<AgendaItem> search(String ownerId, String petId, AgendaItemType type,
                                   Instant from, Instant to, Pageable pageable) {
        Query query = new Query();

        // Toujours : on ne voit que ses propres éléments.
        query.addCriteria(Criteria.where("ownerId").is(ownerId));

        // Filtres optionnels : on n'ajoute un critère que si la valeur est fournie.
        if (petId != null && !petId.isBlank()) {
            query.addCriteria(Criteria.where("petId").is(petId));
        }
        if (type != null) {
            query.addCriteria(Criteria.where("type").is(type));
        }
        if (from != null || to != null) {
            Criteria scheduled = Criteria.where("scheduledAt");
            if (from != null) scheduled = scheduled.gte(from); // >= from
            if (to != null) scheduled = scheduled.lte(to);     // <= to
            query.addCriteria(scheduled);
        }

        // Pagination correcte : on compte AVANT d'appliquer skip/limit.
        long total = mongoTemplate.count(query, AgendaItem.class);
        query.with(pageable);
        List<AgendaItem> items = mongoTemplate.find(query, AgendaItem.class);

        return new PageImpl<>(items, pageable, total);
    }
}