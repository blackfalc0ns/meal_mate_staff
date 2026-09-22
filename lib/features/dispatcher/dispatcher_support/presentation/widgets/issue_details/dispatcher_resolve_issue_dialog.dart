import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/network/failures.dart';

class DispatcherResolveIssueDialog extends StatefulWidget {
  const DispatcherResolveIssueDialog({
    super.key,
    required this.onResolve,
    this.isResolving = false,
    this.resolveFailure,
    this.notesError,
    this.onRetry,
  });

  final Future<void> Function(String notes) onResolve;
  final bool isResolving;
  final Failure? resolveFailure;
  final String? notesError;
  final VoidCallback? onRetry;

  @override
  State<DispatcherResolveIssueDialog> createState() =>
      _DispatcherResolveIssueDialogState();
}

class _DispatcherResolveIssueDialogState
    extends State<DispatcherResolveIssueDialog> {
  late final TextEditingController _controller;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.length < 3) {
      setState(() {
        _localError = 'ملاحظات الحل يجب أن تكون 3 أحرف على الأقل';
      });
      return;
    }
    if (text.length > 500) {
      setState(() {
        _localError = 'ملاحظات الحل لا يمكن أن تتجاوز 500 حرف';
      });
      return;
    }
    setState(() {
      _localError = null;
    });
    await widget.onResolve(text);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final errorMessage = _localError ?? widget.notesError;

    return Dialog(
      backgroundColor: color.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: color.secondary,
                  size: Spacing.iconMd,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    locale.issueDetailsResolveDialogTitle,
                    style: getBoldStyle(
                      fontSize: FontSize.size14,
                      color: color.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            if (widget.resolveFailure != null) ...[
              InlineApiErrorWidget(
                failure: widget.resolveFailure!,
                onRetry: widget.onRetry ?? _handleSubmit,
              ),
              const SizedBox(height: Spacing.sm),
            ],

            Text(
              locale.issueDetailsResolveNotesLabel,
              style: getMediumStyle(
                fontSize: FontSize.size12,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: locale.issueDetailsResolveNotesHint,
                hintStyle: getRegularStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurfaceVariant,
                ),
                errorText: errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  borderSide: BorderSide(color: color.outlineVariant),
                ),
                contentPadding: const EdgeInsets.all(Spacing.sm),
              ),
            ),
            const SizedBox(height: Spacing.md),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isResolving
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Spacing.buttonSmallRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      locale.issueDetailsClose,
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isResolving ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.secondary,
                      foregroundColor: color.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Spacing.buttonSmallRadius,
                        ),
                      ),
                    ),
                    child: widget.isResolving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            locale.issueDetailsConfirmResolve,
                            style: getBoldStyle(
                              fontSize: FontSize.size12,
                              color: color.onSecondary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
