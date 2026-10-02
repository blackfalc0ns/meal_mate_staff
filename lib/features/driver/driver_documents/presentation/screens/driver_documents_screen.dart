import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_document_item_entity.dart';
import '../../domain/fake_data/driver_documents_fake_data.dart';
import '../widgets/driver_document_card.dart';
import '../widgets/driver_documents_header.dart';
import '../widgets/driver_documents_notice_card.dart';
import '../widgets/driver_edit_document_sheet.dart';
import '../widgets/driver_document_preview_dialog.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({
    super.key,
    this.initialDocuments,
    this.onBack,
  });

  final List<DriverDocumentItemEntity>? initialDocuments;
  final VoidCallback? onBack;

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  late List<DriverDocumentItemEntity> _documents;

  @override
  void initState() {
    super.initState();
    _documents = List.of(
      widget.initialDocuments ?? DriverDocumentsFakeData.defaultDocuments,
    );
  }

  void _handleDocumentUpdate(DriverDocumentItemEntity updatedDocument) {
    final index = _documents.indexWhere((doc) => doc.id == updatedDocument.id);
    if (index != -1) {
      setState(() {
        _documents[index] = updatedDocument;
      });

      final color = context.colorScheme;
      final locale = context.localization;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale.driverDocumentUpdateSuccess,
            style: getMediumStyle(
              fontSize: FontSize.size12,
              color: color.onPrimary,
            ),
          ),
          backgroundColor: color.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          margin: const EdgeInsets.all(Spacing.base),
        ),
      );
    }
  }

  void _openEditSheet(DriverDocumentItemEntity document) {
    unawaited(
      DriverEditDocumentSheet.show(
        context: context,
        document: document,
        onDocumentUpdated: _handleDocumentUpdate,
      ),
    );
  }

  void _openPreviewDialog(DriverDocumentItemEntity document) {
    unawaited(
      DriverDocumentPreviewDialog.show(
        context: context,
        document: document,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverDocumentsHeader(
        title: locale.driverSettingsMyDocuments,
        subtitle: locale.driverDocumentsSubtitle,
        onBack: widget.onBack,
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
              const DriverDocumentsNoticeCard(),
              const SizedBox(height: Spacing.base),
              for (final document in _documents) ...[
                DriverDocumentCard(
                  document: document,
                  onViewTap: () => _openPreviewDialog(document),
                  onUpdateTap: () => _openEditSheet(document),
                ),
                const SizedBox(height: Spacing.base),
              ],
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
