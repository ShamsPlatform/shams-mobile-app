import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/constants/app_constants.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/maintenance/presentation/providers/maintenance_request_provider.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/chat/presentation/screens/chat_conversation_screen.dart';

/// Opens the modal bottom sheet for submitting a maintenance request to [workshop].
void showMaintenanceRequestSheet(BuildContext context, Workshop workshop) {
  final parentContext = context;
  showShamsModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bCtx) => _MaintenanceRequestSheetContent(
      parentContext: parentContext,
      workshop: workshop,
    ),
  );
}

class _MaintenanceRequestSheetContent extends StatefulWidget {
  const _MaintenanceRequestSheetContent({
    required this.parentContext,
    required this.workshop,
  });

  final BuildContext parentContext;
  final Workshop workshop;

  @override
  State<_MaintenanceRequestSheetContent> createState() =>
      _MaintenanceRequestSheetContentState();
}

class _MaintenanceRequestSheetContentState
    extends State<_MaintenanceRequestSheetContent> {
  String? _selectedService;
  String? _selectedInverter;
  String? _selectedBattery;
  final _capacityController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _capacityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    IconData? prefixIcon,
    String? labelText,
    String? hintText,
    bool alignIconTop = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return InputDecoration(
      filled: true,
      fillColor: ext.backgroundLight,
      labelText: labelText,
      hintText: hintText,
      alignLabelWithHint: alignIconTop,
      labelStyle: GoogleFonts.tajawal(
        fontSize: 13,
        color: ext.textHint,
      ),
      hintStyle: GoogleFonts.tajawal(
        fontSize: 13,
        color: ext.textHint,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : (alignIconTop
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 40),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                )
              : Icon(
                  prefixIcon,
                  size: 20,
                  color: colorScheme.primary,
                )),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ext.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ext.borderLight),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final parentContext = widget.parentContext;
    final workshop = widget.workshop;
    final sheetL10n = AppLocalizations.of(context)!;
    final parentL10n = AppLocalizations.of(parentContext)!;

    if (_selectedService == null || _descController.text.trim().isEmpty) {
      setState(() {
        _submitError = sheetL10n.selectServiceAndDetails;
      });
      return;
    }

    setState(() {
      _submitError = null;
      _isSubmitting = true;
    });

    final capacityVal = double.tryParse(_capacityController.text.trim());
    final problemDesc = _descController.text.trim();

    final maintenanceProvider =
        parentContext.read<MaintenanceRequestProvider>();
    final chatListProvider = parentContext.read<ChatListProvider>();

    final generatedChatId = await maintenanceProvider.submit(
      SubmitMaintenanceRequestParams(
        workshopId: workshop.id,
        workshopOwnerId: workshop.ownerId,
        serviceType: _selectedService!,
        problemDescription: problemDesc,
        systemCapacityKw: capacityVal,
        inverterBrand: _selectedInverter,
        batteryType: _selectedBattery,
      ),
    );

    if (!mounted || !parentContext.mounted) return;

    if (generatedChatId != null && generatedChatId.isNotEmpty) {
      await chatListProvider.load(silent: true);
      if (!mounted || !parentContext.mounted) return;
      Navigator.pop(context);
      Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(chatId: generatedChatId),
        ),
      );
    } else {
      setState(() {
        _isSubmitting = false;
        _submitError = parentL10n.localizeErrorMessage(
          maintenanceProvider.errorMessage,
          fallback: parentL10n.maintenanceRequestFailed,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return PopScope(
      canPop: !_isSubmitting,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _isSubmitting
                  ? _MaintenanceTransferLoadingView(
                      key: const ValueKey('maintenance-submitting-loader'),
                      message: l10n.sendingMaintenanceRequest,
                      workshopName: widget.workshop.name,
                    )
                  : SingleChildScrollView(
                      key: const ValueKey('maintenance-request-form'),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: ext.handleBar,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.requestMaintenanceFrom(widget.workshop.name),
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedService,
                            isExpanded: true,
                            items: ShamsConstants.solarServiceTypes
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      l10n.localizeServiceType(s),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.tajawal(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedService = val),
                            decoration: _inputDecoration(
                              context,
                              prefixIcon: Icons.build_circle_outlined,
                              labelText: l10n.requiredServiceType,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedInverter,
                            isExpanded: true,
                            items: ShamsConstants.inverterBrands
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      l10n.localizeInverterBrand(s),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.tajawal(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedInverter = val),
                            decoration: _inputDecoration(
                              context,
                              prefixIcon: Icons.electrical_services_rounded,
                              labelText: l10n.inverterType,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedBattery,
                            isExpanded: true,
                            items: ShamsConstants.batteryTypes
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      l10n.localizeBatteryType(s),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.tajawal(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedBattery = val),
                            decoration: _inputDecoration(
                              context,
                              prefixIcon: Icons.battery_charging_full_rounded,
                              labelText: l10n.batteryType,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              context,
                              prefixIcon: Icons.bolt_rounded,
                              labelText: l10n.systemSizeHint,
                            ),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descController,
                            maxLines: 3,
                            decoration: _inputDecoration(
                              context,
                              prefixIcon: Icons.description_outlined,
                              hintText: l10n.problemDetailsHint,
                              alignIconTop: true,
                            ),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (_submitError != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _submitError!,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          CustomSolidButton(
                            title: l10n.sendRequest,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaintenanceTransferLoadingView extends StatelessWidget {
  final String message;
  final String workshopName;

  const _MaintenanceTransferLoadingView({
    super.key,
    required this.message,
    required this.workshopName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ext.handleBar,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 36),
          LoadingAnimationWidget.discreteCircle(
            color: colorScheme.primary,
            secondRingColor: colorScheme.secondary,
            thirdRingColor: colorScheme.primary.withValues(alpha: 0.35),
            size: 56,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            workshopName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
