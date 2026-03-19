import 'package:expense_tracker_v2/features/trips/presentation/providers/trip_providers.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/trip_summary_body.dart';

class TripSummaryScreen extends ConsumerStatefulWidget {
  const TripSummaryScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends ConsumerState<TripSummaryScreen> {
  final _currencyService = CurrencyService();
  bool _ratesLoaded = false;

  @override
  void initState() {
    super.initState();
    final trip = ref
        .read(tripNotifierProvider)
        .value
        ?.firstWhere((t) => t.id == widget.tripId);
    if (trip != null) {
      _currencyService.fetchRates(trip.currency).then((_) {
        if (mounted) setState(() => _ratesLoaded = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripId = widget.tripId;
    final tripsAsync = ref.watch(tripNotifierProvider);
    final currentTrip = tripsAsync
        .whenData((trips) => trips.firstWhere((t) => t.id == tripId))
        .value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trip Summary',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: _ratesLoaded
          ? TripSummaryBody(trip: currentTrip!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
