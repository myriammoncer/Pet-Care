package com.petcare.agenda.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/** Active la planification (@Scheduled) pour le module agenda. */
@Configuration
@EnableScheduling
public class AgendaSchedulingConfig {
}