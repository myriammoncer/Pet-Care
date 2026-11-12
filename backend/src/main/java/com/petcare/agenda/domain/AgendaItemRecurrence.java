package com.petcare.agenda.domain;

import java.time.Instant;
import java.time.Period;
import java.time.ZoneOffset;

/**
 * Règles de récurrence possibles pour un rappel. Chaque valeur connaît la
 * durée à ajouter pour obtenir la prochaine occurrence.
 */
public enum AgendaItemRecurrence {
    EVERY_WEEK(Period.ofWeeks(1)),
    EVERY_MONTH(Period.ofMonths(1)),
    EVERY_3_MONTHS(Period.ofMonths(3)),
    EVERY_6_MONTHS(Period.ofMonths(6)),
    EVERY_YEAR(Period.ofYears(1));

    private final Period period;

    AgendaItemRecurrence(Period period) {
        this.period = period;
    }

    /** Instant de la prochaine occurrence, à partir d'un instant donné. */
    public Instant next(Instant from) {
        return from.atZone(ZoneOffset.UTC).plus(period).toInstant();
    }
}