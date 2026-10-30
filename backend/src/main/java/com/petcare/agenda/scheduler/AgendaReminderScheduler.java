package com.petcare.agenda.scheduler;

import com.petcare.agenda.domain.AgendaItem;
import com.petcare.agenda.domain.AgendaItemStatus;
import com.petcare.agenda.repository.AgendaItemRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;

/**
 * Tâche planifiée : marque en MISSED les rappels dont la date prévue est
 * passée sans avoir été réalisés (statut encore SCHEDULED).
 */
@Component
public class AgendaReminderScheduler {

    private static final Logger log = LoggerFactory.getLogger(AgendaReminderScheduler.class);

    private final AgendaItemRepository repository;

    public AgendaReminderScheduler(AgendaItemRepository repository) {
        this.repository = repository;
    }

    /** Toutes les heures (pile) ; configurable via petcare.agenda.reminder-cron. */
    @Scheduled(cron = "${petcare.agenda.reminder-cron:0 0 * * * *}")
    public void markOverdueItemsAsMissed() {
        Instant now = Instant.now();
        List<AgendaItem> overdue =
                repository.findByStatusAndScheduledAtBefore(AgendaItemStatus.SCHEDULED, now);
        if (overdue.isEmpty()) {
            return;
        }
        overdue.forEach(item -> item.setStatus(AgendaItemStatus.MISSED));
        repository.saveAll(overdue);
        log.info("Agenda: {} rappel(s) passe(s) en MISSED", overdue.size());
    }
}