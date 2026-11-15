import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/constants/app_constants.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/maintenance/presentation/providers/maintenance_request_provider.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/views/chat/chat_conversation_screen.dart';

/// Opens the modal bottom sheet for submitting a maintenance request to [workshop].
void showMaintenanceRequestSheet(BuildContext context, Workshop workshop) {
  final parentContext = context;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: _MaintenanceRequestSheetContent(
        parentContext: parentContext,
        workshop: workshop,
      ),
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

  @override
  void dispose() {
    _capacityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: Theme.of(context)
          .extension<ShamsExtendedColors>()!
          .backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
        ),
      ),
      hintStyle: GoogleFonts.tajawal(
        fontSize: 13,
        color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
      ),
    );
  }

  Future<void> _submit() async {
    final parentContext = widget.parentContext;
    final workshop = widget.workshop;

    if (_selectedService == null || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تحديد نوع الخدمة وتفاصيل المشكلة',
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(context);

    if (!parentContext.mounted) return;
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(
        content: Text(
          'جاري إرسال الطلب وإنشاء المحادثة...',
          style: GoogleFonts.tajawal(color: Colors.white),
        ),
        backgroundColor: Theme.of(parentContext).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

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

    if (!parentContext.mounted) return;

    if (generatedChatId != null && generatedChatId.isNotEmpty) {
      await chatListProvider.load(silent: true);
      if (!parentContext.mounted) return;
      Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(chatId: generatedChatId),
        ),
      );
    } else {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: Text(
            maintenanceProvider.errorMessage ??
                'فشل في إرسال الطلب، يرجى المحاولة لاحقاً',
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          backgroundColor: Theme.of(parentContext).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _inputDecoration(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .extension<ShamsExtendedColors>()!
                        .handleBar,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'طلب خدمة صيانة من ${widget.workshop.name}',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedService,
                hint: Text(
                  'نوع الخدمة المطلوبة',
                  style: GoogleFonts.tajawal(fontSize: 14),
                ),
                items: ShamsConstants.solarServiceTypes
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.tajawal(fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedService = val),
                decoration: decoration,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedInverter,
                hint: Text(
                  'نوع المحول (الإنفرتر)',
                  style: GoogleFonts.tajawal(fontSize: 14),
                ),
                items: ShamsConstants.inverterBrands
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.tajawal(fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedInverter = val),
                decoration: decoration,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedBattery,
                hint: Text(
                  'نوع البطاريات',
                  style: GoogleFonts.tajawal(fontSize: 14),
                ),
                items: ShamsConstants.batteryTypes
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.tajawal(fontSize: 14)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedBattery = val),
                decoration: decoration,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: decoration.copyWith(
                  hintText: 'حجم المنظومة (بالوات) - اختياري',
                ),
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: decoration.copyWith(
                  hintText: 'تفاصيل المشكلة (مثال: الشحن ضعيف وقت الظهيرة...)',
                ),
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              CustomSolidButton(
                title: 'إرسال الطلب',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
