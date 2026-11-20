import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/pet_event.dart';
import 'event_detail_page.dart';
import 'event_form_page.dart';
import 'event_registration.dart';
import 'event_ui.dart';
import 'events_colors.dart';
import 'events_controller.dart';
import 'my_events_page.dart';

/// Écran principal « Événements & Communauté » (maquette Figma) :
/// filtres par type, événement à la une, prochains rendez-vous.
/// L'admin dispose du bouton « Proposer une sortie ou un événement ».
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(authControllerProvider).state.user?.isAdmin ?? false;
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      backgroundColor: EventsColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isAdmin ? const _ProposeEventButton() : null,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: EventsColors.primary,
          onRefresh: () => ref.refresh(upcomingEventsProvider.future),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _TopBar()),
              const SliverToBoxAdapter(child: _SectionHeader()),
              const SliverToBoxAdapter(child: _CategoryFilters()),
              ...eventsAsync.when<List<Widget>>(
                loading: () => [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: EventsColors.primary)),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AsyncView<List<PetEvent>>(
                      value: eventsAsync,
                      onRetry: () => ref.invalidate(upcomingEventsProvider),
                      data: (_) => const SizedBox.shrink(),
                    ),
                  ),
                ],
                data: (events) => _content(context, events, isAdmin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, List<PetEvent> events, bool isAdmin) {
    final bottomPadding = isAdmin ? 96.0 : 24.0;
    if (events.isEmpty) {
      return [
        const SliverToBoxAdapter(child: _UpcomingHeader()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(32, 40, 32, bottomPadding),
            child: const Column(
              children: [
                Icon(Icons.event_busy, size: 56, color: EventsColors.textMuted),
                SizedBox(height: 12),
                Text(
                  'Aucun événement à venir pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: EventsColors.textMuted, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    final featured = events.first;
    final others = events.skip(1).toList();
    return [
      SliverToBoxAdapter(child: _FeaturedEvent(event: featured)),
      const SliverToBoxAdapter(child: _UpcomingHeader()),
      if (others.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              "Pas d'autre rendez-vous pour l'instant.",
              style: TextStyle(color: EventsColors.textMuted, fontSize: 13),
            ),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
        sliver: SliverList.separated(
          itemCount: others.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => EventListCard(event: others[i]),
        ),
      ),
    ];
  }
}

/// En-tête de page : « PETCARE / Événements ».
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: EventsColors.mint,
            child: Icon(Icons.pets, size: 18, color: EventsColors.primary),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PETCARE',
                style: TextStyle(
                  color: EventsColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Événements',
                style: TextStyle(
                  color: EventsColors.textStrong,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// « VIE LOCALE & PARTAGE » + titre + accroche.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventPill(
            icon: Icons.groups_outlined,
            label: 'Vie locale & partage',
            uppercase: true,
            background: EventsColors.mint,
            foreground: EventsColors.onMint,
          ),
          SizedBox(height: 6),
          Text(
            'Événements &\nCommunauté',
            style: TextStyle(
              color: EventsColors.textStrong,
              fontSize: 28,
              height: 36 / 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.42,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Rejoignez les passionnés et faites de belles rencontres pour vous et vos compagnons.',
            style: TextStyle(color: EventsColors.textMuted, fontSize: 14, height: 20 / 14),
          ),
        ],
      ),
    );
  }
}

/// Puces de catégories (filtre par type).
class _CategoryFilters extends ConsumerWidget {
  const _CategoryFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(eventTypeFilterProvider);
    void select(String? type) => ref.read(eventTypeFilterProvider.notifier).state = type;

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        children: [
          _CategoryChip(label: 'Tous', selected: selected == null, onTap: () => select(null)),
          for (final entry in eventTypeShortLabels.entries)
            _CategoryChip(
              label: entry.value,
              selected: selected == entry.key,
              onTap: () => select(entry.key),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? EventsColors.primary : EventsColors.chip,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : EventsColors.textMuted,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte « À la une cette semaine » (prochain événement).
class _FeaturedEvent extends StatelessWidget {
  const _FeaturedEvent({required this.event});
  final PetEvent event;

  void _openDetail(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailPage(eventId: event.id)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, size: 15, color: Color(0xFFE8705A)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'À la une cette semaine',
                  style: TextStyle(
                    color: EventsColors.textStrong,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.14,
                  ),
                ),
              ),
              Text(
                'COUP DE CŒUR',
                style: TextStyle(
                  color: EventsColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: EventsColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: EventsColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => _openDetail(context),
                  child: SizedBox(
                    height: 208,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(eventTypeImage(event.type), fit: BoxFit.cover),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xCC000000), Color(0x40000000), Color(0x00000000)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: EventPill(
                            icon: eventTypeIcon(event.type),
                            label: eventTypeLabel(event.type),
                            background: const Color(0xE6FFFFFF),
                            foreground: EventsColors.primary,
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EventPill(
                                icon: Icons.schedule,
                                label: formatEventShort(event),
                                background: const Color(0xCC2E7D5B),
                                foreground: const Color(0xFFD0FFE3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 24.75 / 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: EventsColors.mint,
                            child: Icon(Icons.pets, size: 17, color: EventsColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lieu',
                                  style: TextStyle(
                                    color: EventsColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                Text(
                                  event.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: EventsColors.textStrong,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ParticipantsPill(count: event.registeredCount),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FeaturedAction(event: event, onOpen: () => _openDetail(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton principal de la carte à la une, selon l'état d'inscription.
class _FeaturedAction extends ConsumerWidget {
  const _FeaturedAction({required this.event, required this.onOpen});
  final PetEvent event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = FilledButton.styleFrom(
      backgroundColor: EventsColors.primary,
      disabledBackgroundColor: EventsColors.chip,
      disabledForegroundColor: EventsColors.textMuted,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.14),
    );
    if (event.registered) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: EventsColors.primary,
          side: const BorderSide(color: EventsColors.primary),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onOpen,
        icon: const Icon(Icons.check_circle, size: 18),
        label: const Text('Vous participez · voir le détail'),
      );
    }
    if (event.canRegister) {
      return FilledButton.icon(
        style: style,
        onPressed: () => registerWithPet(context, ref, event),
        icon: const Icon(Icons.check_circle_outline, size: 18),
        label: const Text('Participer avec mon animal'),
      );
    }
    return FilledButton(
      style: style,
      onPressed: null,
      child: Text(event.full ? 'Complet' : 'Inscriptions closes'),
    );
  }
}

/// « 18 inscrits » avec pastilles empilées (maquette).
class _ParticipantsPill extends StatelessWidget {
  const _ParticipantsPill({required this.count});
  final int count;

  static const _dots = [Color(0xFFA4F3CA), Color(0xFFA1F4C5), Color(0xFFFFDAD2)];

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: EventsColors.chipAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shown > 0)
            SizedBox(
              width: 20.0 + (shown - 1) * 12,
              height: 20,
              child: Stack(
                children: [
                  for (var i = 0; i < shown; i++)
                    Positioned(
                      left: i * 12.0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: _dots[i],
                        child: const Icon(Icons.pets, size: 10, color: EventsColors.textStrong),
                      ),
                    ),
                ],
              ),
            ),
          if (shown > 0) const SizedBox(width: 6),
          Text(
            '$count inscrit${count > 1 ? 's' : ''}',
            style: const TextStyle(
              color: EventsColors.textStrong,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// « Prochains rendez-vous » + accès à « Mes inscriptions ».
class _UpcomingHeader extends StatelessWidget {
  const _UpcomingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prochains rendez-vous',
                  style: TextStyle(
                    color: EventsColors.textStrong,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Inscrivez-vous avec votre compagnon',
                  style: TextStyle(color: EventsColors.textMuted, fontSize: 12, height: 16 / 12),
                ),
              ],
            ),
          ),
          Material(
            color: EventsColors.chip,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyEventsPage()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.how_to_reg, size: 14, color: EventsColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Mes inscriptions',
                      style: TextStyle(
                        color: EventsColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'un événement dans les listes (maquette « Article - événement »).
class EventListCard extends StatelessWidget {
  const EventListCard({super.key, required this.event, this.dimmed = false});

  final PetEvent event;
  final bool dimmed;

  void _openDetail(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailPage(eventId: event.id)),
      );

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: EventsColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: EventsColors.cardShadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openDetail(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: EventTypeBadge(event.type)),
                    const SizedBox(width: 8),
                    _StatusPill(event: event),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: EventsColors.textStrong,
                              fontSize: 18,
                              height: 22.5 / 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.calendar_today_outlined,
                            text: formatEventShort(event),
                            color: EventsColors.primary,
                            bold: true,
                          ),
                          const SizedBox(height: 3),
                          _InfoLine(
                            icon: Icons.place_outlined,
                            text: event.location,
                            color: EventsColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        eventTypeImage(event.type),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _footerText(event),
                        style: const TextStyle(
                          color: EventsColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CardAction(event: event, onOpen: () => _openDetail(context)),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _footerText(PetEvent e) {
    if (e.full) return 'Complet · ${e.capacity} places';
    return '${e.registeredCount}/${e.capacity} inscrits';
  }
}

/// Pastille de droite : alerte places / complet / inscrit / nombre d'inscrits.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.event});
  final PetEvent event;

  @override
  Widget build(BuildContext context) {
    if (event.registered) {
      return const EventPill(
        icon: Icons.check_circle,
        label: 'Inscrit',
        background: EventsColors.mint,
        foreground: EventsColors.onMint,
      );
    }
    if (event.full) {
      return const EventPill(
        icon: Icons.block,
        label: 'Complet',
        background: EventsColors.alert,
        foreground: EventsColors.onAlert,
      );
    }
    if (event.remainingSpots <= 5) {
      final n = event.remainingSpots;
      return EventPill(
        icon: Icons.hourglass_bottom,
        label: '$n place${n > 1 ? 's' : ''} restante${n > 1 ? 's' : ''}',
        background: EventsColors.alert,
        foreground: EventsColors.onAlert,
      );
    }
    return EventPill(
      icon: Icons.groups_outlined,
      label: '${event.remainingSpots} places',
      background: Colors.transparent,
      foreground: EventsColors.textMuted,
    );
  }
}

/// Bouton secondaire de la carte (« S'inscrire », « Voir », …).
class _CardAction extends ConsumerWidget {
  const _CardAction({required this.event, required this.onOpen});
  final PetEvent event;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String label;
    final VoidCallback onPressed;
    if (event.canRegister) {
      label = event.type == 'BEAUTY_CONTEST' ? 'Inscrire son animal' : "S'inscrire";
      onPressed = () => registerWithPet(context, ref, event);
    } else {
      label = event.registered ? 'Mon inscription' : 'En savoir plus';
      onPressed = onOpen;
    }
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: EventsColors.chip,
        foregroundColor: EventsColors.primary,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.24),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text, required this.color, this.bold = false});
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 12.5, color: color),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              height: 16 / 12,
              fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouton flottant admin « Proposer une sortie ou un événement ».
class _ProposeEventButton extends StatelessWidget {
  const _ProposeEventButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: EventsColors.primarySoft,
            shape: const StadiumBorder(),
            elevation: 6,
            shadowColor: const Color(0x33000000),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.14),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Proposer une sortie ou un événement'),
        ),
      ),
    );
  }
}
