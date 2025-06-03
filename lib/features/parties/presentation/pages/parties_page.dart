import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fmp_supplier_app/core/config/theme.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fmp_supplier_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:fmp_supplier_app/features/parties/domain/entities/party_entity.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_bloc.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_event.dart';
import 'package:fmp_supplier_app/features/parties/presentation/bloc/party_state.dart';
import 'package:fmp_supplier_app/features/parties/presentation/widgets/party_card.dart';
import 'package:intl/intl.dart';

class PartiesPage extends StatefulWidget {
  const PartiesPage({Key? key}) : super(key: key);

  @override
  State<PartiesPage> createState() => _PartiesPageState();
}

class _PartiesPageState extends State<PartiesPage> {
  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  void _loadParties() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<PartyBloc>().add(GetOwnerPartiesEvent(authState.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Parties'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadParties),
        ],
      ),
      body: BlocBuilder<PartyBloc, PartyState>(
        builder: (context, state) {
          if (state is PartyLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PartiesLoaded) {
            final parties = state.parties;
            if (parties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No parties found',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppTheme.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first party by tapping the + button',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGrey),
                    ),
                  ],
                ),
              );
            }

            // Group parties by date
            final groupedParties = _groupPartiesByDate(parties);

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedParties.length,
              itemBuilder: (context, index) {
                final dateGroup = groupedParties.keys.elementAt(index);
                final partiesForDate = groupedParties[dateGroup]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        dateGroup,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: partiesForDate.length,
                      itemBuilder: (context, i) {
                        return PartyCard(
                          party: partiesForDate[i],
                          onTap: () {
                            // Navigate to party details page
                            Navigator.pushNamed(
                              context,
                              '/party-details',
                              arguments: partiesForDate[i].id,
                            );
                          },
                          onEdit: () {
                            // Navigate to edit party page
                            Navigator.pushNamed(
                              context,
                              '/edit-party',
                              arguments: partiesForDate[i].id,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          } else if (state is PartyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading parties',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppTheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadParties,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create party page
          Navigator.pushNamed(context, '/create-party');
        },
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<PartyEntity>> _groupPartiesByDate(
    List<PartyEntity> parties,
  ) {
    final Map<String, List<PartyEntity>> grouped = {};

    for (final party in parties) {
      // Format the date
      final dateStr = _formatDate(party.date);

      // Add to group
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(party);
    }

    // Sort dates (most recent first)
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          // Parse the date strings for comparison
          final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
          final dateA = dateFormat.parse(a);
          final dateB = dateFormat.parse(b);
          return dateB.compareTo(dateA);
        });

    // Create a new sorted map
    final Map<String, List<PartyEntity>> sortedMap = {};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  String _formatDate(DateTime date) {
    // Today/Tomorrow logic
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, ${DateFormat('MMMM d, yyyy').format(date)}';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow, ${DateFormat('MMMM d, yyyy').format(date)}';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }
}
