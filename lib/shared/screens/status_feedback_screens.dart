import 'package:flutter/material.dart';
import 'package:ikuku/app_theme.dart';
import 'package:ikuku/shared/widgets/status_feedback_widget.dart';
import 'package:easy_localization/easy_localization.dart';

/// Store Success Screen
class StoreSuccessScreen extends StatelessWidget {
  final VoidCallback? onViewStore;

  const StoreSuccessScreen({Key? key, this.onViewStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: CustomColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.primary, width: 2),
            ),
            child: StatusFeedback(
              heading: 'stock_updated'.tr(),
              bodyText: 'stock_updated_success'.tr(),
              buttonLabel: 'view_store'.tr(),
              statusType: StatusType.success,
              imagePath: 'assets/icons/large_success_tick.svg',
              onButtonPressed: onViewStore ?? () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Store Error Screen
class StoreErrorScreen extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const StoreErrorScreen({Key? key, this.onTryAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: CustomColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.primary, width: 2),
            ),
            child: StatusFeedback(
              heading: 'update_failed'.tr(),
              bodyText: 'update_failed_message'.tr(),
              buttonLabel: 'try_again'.tr(),
              statusType: StatusType.error,
              imagePath: 'assets/icons/large_error_cross.svg',
              onButtonPressed: onTryAgain ?? () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Batch Success Screen
class BatchSuccessScreen extends StatelessWidget {
  final VoidCallback? onViewBatch;

  const BatchSuccessScreen({Key? key, this.onViewBatch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: CustomColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.primary, width: 2),
            ),
            child: StatusFeedback(
              heading: 'batch_created'.tr(),
              bodyText: 'batch_created_success'.tr(),
              buttonLabel: 'view_batch'.tr(),
              statusType: StatusType.success,
              imagePath: 'assets/icons/large_success_tick.svg',
              onButtonPressed: onViewBatch ?? () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Batch Error Screen
class BatchErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const BatchErrorScreen({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: CustomColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.primary, width: 2),
            ),
            child: StatusFeedback(
              heading: 'batch_failed'.tr(),
              bodyText: 'batch_failed_message'.tr(),
              buttonLabel: 'retry'.tr(),
              statusType: StatusType.error,
              imagePath: 'assets/icons/large_error_cross.svg',
              onButtonPressed: onRetry ?? () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Report Success Screen
class ReportSuccessScreen extends StatelessWidget {
  final VoidCallback? onDone;
  final String? buttonLabel;

  const ReportSuccessScreen({Key? key, this.onDone, this.buttonLabel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: CustomColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.primary, width: 2),
            ),
            child: StatusFeedback(
              heading: 'daily_report_saved'.tr(),
              bodyText: 'daily_report_saved_message'.tr(),
              buttonLabel: buttonLabel ?? 'back_to_dashboard'.tr(),
              statusType: StatusType.success,
              imagePath: 'assets/icons/large_success_tick.svg',
              onButtonPressed: onDone ?? () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Report Error Screen
class ReportErrorScreen extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const ReportErrorScreen({Key? key, this.onTryAgain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: CustomColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColors.primary, width: 2),
            ),
            child: StatusFeedback(
              heading: 'save_failed'.tr(),
              bodyText: 'save_failed_message'.tr(),
              buttonLabel: 'try_again'.tr(),
              statusType: StatusType.error,
              imagePath: 'assets/icons/large_error_cross.svg',
              onButtonPressed: onTryAgain ?? () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}
