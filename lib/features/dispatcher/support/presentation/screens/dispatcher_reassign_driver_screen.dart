import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';
import '../../domain/entities/reassign_driver_candidate_entity.dart';
import '../../domain/fake_data/dispatcher_issue_detail_fake_data.dart';
import '../../domain/fake_data/dispatcher_reassign_driver_fake_data.dart';
import '../../../driver_filter/presentation/widgets/driver_filter_bottom_sheet.dart';
import '../widgets/reassign_driver/reassign_driver_app_bar.dart';
import '../widgets/reassign_driver/reassign_driver_bottom_button.dart';
import '../widgets/reassign_driver/reassign_driver_card.dart';
import '../widgets/reassign_driver/reassign_driver_issue_summary_card.dart';
import '../widgets/reassign_driver/reassign_driver_list_header.dart';

class DispatcherReassignDriverScreen extends StatefulWidget {
  const DispatcherReassignDriverScreen({
    super.key,
    this.issue,
    this.candidates,
    this.onBack,
    this.onConfirm,
  });

  final DispatcherIssueDetailEntity? issue;
  final List<ReassignDriverCandidateEntity>? candidates;
  final VoidCallback? onBack;
  final ValueChanged<ReassignDriverCandidateEntity>? onConfirm;

  @override
  State<DispatcherReassignDriverScreen> createState() =>
      _DispatcherReassignDriverScreenState();
}

class _DispatcherReassignDriverScreenState
    extends State<DispatcherReassignDriverScreen> {
  late final DispatcherIssueDetailEntity _issue;
  late final List<ReassignDriverCandidateEntity> _candidates;
  late String _selectedDriverId;

  @override
  void initState() {
    super.initState();
    _issue = widget.issue ?? DispatcherIssueDetailFakeData.sampleIssueDetail;
    _candidates =
        widget.candidates ?? DispatcherReassignDriverFakeData.defaultCandidates;
    _selectedDriverId = _candidates.isNotEmpty ? _candidates.first.id : '';
  }

  void _onDriverSelected(String driverId) {
    if (_selectedDriverId == driverId) return;
    setState(() {
      _selectedDriverId = driverId;
    });
  }

  void _onConfirm() {
    final selectedCandidate = _candidates.firstWhere(
      (c) => c.id == _selectedDriverId,
      orElse: () => _candidates.first,
    );

    if (widget.onConfirm != null) {
      widget.onConfirm!(selectedCandidate);
    } else {
      final locale = context.localization;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale.reassignDriverSuccess),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop(selectedCandidate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surfaceContainerLowest,
      appBar: ReassignDriverAppBar(onBack: widget.onBack),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReassignDriverIssueSummaryCard(issue: _issue),
              const SizedBox(height: Spacing.base),
              ReassignDriverListHeader(
                onFilterTap: () {
                  DriverFilterBottomSheet.show(context: context);
                },
              ),
              const SizedBox(height: Spacing.sm),
              ..._candidates.map(
                (candidate) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: ReassignDriverCard(
                    candidate: candidate,
                    isSelected: _selectedDriverId == candidate.id,
                    onSelected: () => _onDriverSelected(candidate.id),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ReassignDriverBottomButton(
        isEnabled: _selectedDriverId.isNotEmpty,
        onPressed: _onConfirm,
      ),
    );
  }
}
