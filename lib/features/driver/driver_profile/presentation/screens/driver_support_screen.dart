import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/driver_support_topic_entity.dart';
import '../../domain/fake_data/driver_support_fake_data.dart';
import '../widgets/driver_support_contact_section.dart';
import '../widgets/driver_support_faq_card.dart';
import '../widgets/driver_support_form_card.dart';
import '../widgets/driver_support_header.dart';

class DriverSupportScreen extends StatefulWidget {
  const DriverSupportScreen({
    super.key,
    this.initialTopics,
    this.initialCategories,
    this.onBack,
    this.onNotificationTap,
    this.onCallTap,
    this.onEmailTap,
    this.onTopicTap,
    this.onViewAllTopicsTap,
    this.onSubmitMessage,
  });

  final List<DriverSupportTopicEntity>? initialTopics;
  final List<String>? initialCategories;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onEmailTap;
  final ValueChanged<DriverSupportTopicEntity>? onTopicTap;
  final VoidCallback? onViewAllTopicsTap;
  final ValueChanged<String>? onSubmitMessage;

  @override
  State<DriverSupportScreen> createState() => _DriverSupportScreenState();
}

class _DriverSupportScreenState extends State<DriverSupportScreen> {
  late final TextEditingController _messageController;
  late final List<DriverSupportTopicEntity> _topics;
  late final List<String> _categories;

  String? _selectedCategory;
  String? _attachedFileName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _topics = List.of(widget.initialTopics ?? DriverSupportFakeData.defaultTopics);
    _categories = List.of(
      widget.initialCategories ?? DriverSupportFakeData.defaultCategories,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleCall() {
    if (widget.onCallTap != null) {
      widget.onCallTap!();
      return;
    }
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: '${locale.driverSupportCallUs}: ${DriverSupportFakeData.phoneNumber}',
    );
  }

  void _handleEmail() {
    if (widget.onEmailTap != null) {
      widget.onEmailTap!();
      return;
    }
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message:
          '${locale.driverSupportEmail}: ${DriverSupportFakeData.emailAddress}',
    );
  }

  void _handleTopicTap(DriverSupportTopicEntity topic) {
    if (widget.onTopicTap != null) {
      widget.onTopicTap!(topic);
      return;
    }
    CustomSnackbar.showSuccess(
      context: context,
      message: topic.title,
    );
  }

  void _handleAttachment() {
    setState(() {
      _attachedFileName = 'issue_attachment.png';
    });
  }

  void _handleRemoveAttachment() {
    setState(() {
      _attachedFileName = null;
    });
  }

  void _handleSubmit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (widget.onSubmitMessage != null) {
      widget.onSubmitMessage!(message);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: locale.driverSupportSuccessMessage,
    );

    setState(() {
      _isSubmitting = false;
      _messageController.clear();
      _selectedCategory = null;
      _attachedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverSupportHeader(
        onBack: widget.onBack,
        onNotificationTap: widget.onNotificationTap ??
            () => context.pushNamed(AppRoutes.driverNotifications),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverSupportContactSection(
                onCallTap: _handleCall,
                onEmailTap: _handleEmail,
              ),
              const SizedBox(height: Spacing.base),
              DriverSupportFaqCard(
                topics: _topics,
                onTopicTap: _handleTopicTap,
                onViewAllTap: widget.onViewAllTopicsTap,
              ),
              const SizedBox(height: Spacing.base),
              DriverSupportFormCard(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) =>
                    setState(() => _selectedCategory = cat),
                messageController: _messageController,
                attachedFileName: _attachedFileName,
                onAttachmentTap: _handleAttachment,
                onAttachmentRemove: _handleRemoveAttachment,
                onSubmit: _handleSubmit,
                isSubmitting: _isSubmitting,
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
