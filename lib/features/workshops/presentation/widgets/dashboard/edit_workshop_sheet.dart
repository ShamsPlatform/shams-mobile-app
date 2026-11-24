import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/constants/app_constants.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';

/// Opens the modal bottom sheet for editing the owner's workshop info.
void showEditWorkshopSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final myWorkshop = context.read<MyWorkshopProvider>().myWorkshop;
  final currentName = myWorkshop?.name ?? l10n.myWorkshopOnShams;
  final currentUsername = myWorkshop?.username ?? 'workshop';
  final currentCity = myWorkshop?.city ?? 'صنعاء';
  final parentMessenger = ScaffoldMessenger.of(context);
  final successColor = Theme.of(context).colorScheme.tertiary;
  final errorColor = Theme.of(context).colorScheme.error;

  showShamsModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditWorkshopSheetContent(
      initialName: currentName,
      initialUsername: currentUsername,
      initialCity: currentCity,
      parentMessenger: parentMessenger,
      successColor: successColor,
      errorColor: errorColor,
    ),
  );
}

class _EditWorkshopSheetContent extends StatefulWidget {
  const _EditWorkshopSheetContent({
    required this.initialName,
    required this.initialUsername,
    required this.initialCity,
    required this.parentMessenger,
    required this.successColor,
    required this.errorColor,
  });

  final String initialName;
  final String initialUsername;
  final String initialCity;
  final ScaffoldMessengerState parentMessenger;
  final Color successColor;
  final Color errorColor;

  @override
  State<_EditWorkshopSheetContent> createState() =>
      _EditWorkshopSheetContentState();
}

class _EditWorkshopSheetContentState extends State<_EditWorkshopSheetContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _handleCtrl;
  String? _selectedCity;

  static List<String> get _cities => ShamsConstants.yemeniCities;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _handleCtrl = TextEditingController(text: widget.initialUsername);
    _selectedCity =
        _cities.contains(widget.initialCity) ? widget.initialCity : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _handleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .handleBar,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.editWorkshopProfile,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildEditField(
              context: context,
              controller: _nameCtrl,
              label: l10n.workshopNameLabel,
              icon: Icons.store_outlined,
            ),
            const SizedBox(height: 14),
            _buildEditField(
              context: context,
              controller: _handleCtrl,
              label: l10n.username,
              icon: Icons.alternate_email_rounded,
              prefix: '@',
            ),
            const SizedBox(height: 14),
            Text(
              l10n.governorateLabel,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .textHint,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedCity != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .extension<ShamsExtendedColors>()!
                          .borderLight,
                  width: _selectedCity != null ? 1.5 : 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  hint: Text(
                    l10n.selectGovernorate,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  items: _cities
                      .map(
                        (city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            l10n.localizeCity(city),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCity = v),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final provider = context.read<MyWorkshopProvider>();
                  final ok = await provider.updateInfo(
                    name: _nameCtrl.text,
                    username: _handleCtrl.text,
                    city: _selectedCity,
                  );

                  if (mounted && context.mounted) Navigator.pop(context);
                  if (ok) {
                    widget.parentMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.workshopInfoSaved,
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor: widget.successColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    widget.parentMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.localizeErrorMessage(
                            provider.errorMessage,
                            fallback: l10n.saveEditsFailed,
                          ),
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor: widget.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.saveEdits,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(
          color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        prefixText: prefix,
        prefixStyle: GoogleFonts.tajawal(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Theme.of(context)
            .extension<ShamsExtendedColors>()!
            .backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
