import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/constants/app_constants.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _selectedLocation;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    // تهيئة البيانات المسبقة من الـ Provider
    final currentUser = context.read<ProfileProvider>().currentUserOrPlaceholder;
    _nameController.text = currentUser.name;
    _usernameController.text =
        currentUser.username ?? currentUser.email.split('@').first;
    final rawLocation = currentUser.location?.trim();
    _selectedLocation =
        (rawLocation != null && ShamsConstants.yemeniCities.contains(rawLocation))
            ? rawLocation
            : null;
    _phoneController.text = currentUser.phone ?? '';
    _bioController.text = currentUser.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  ImageProvider _getProfileImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/logo/shams logo.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return const AssetImage('assets/images/logo/shams logo.png');
  }

  // دالة اختيار الصورة
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // دالة الحفظ وإرسال البيانات للـ Provider
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    final provider = context.read<ProfileProvider>();
    final isSuccess = await provider.updateProfile(
      UpdateProfileParams(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        location: _selectedLocation,
        newAvatarPath: _selectedImage?.path,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.profileUpdatedSuccess,
            style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary, // لون أخضر للنجاح
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      final rawError = provider.errorMessage ?? '';
      final localizedError = l10n.localizeErrorMessage(rawError);
      final errorText = rawError.startsWith('فشل رفع الصورة:')
          ? localizedError
          : l10n.saveEditsError(localizedError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorText,
            style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error, // لون أحمر للفشل
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<ProfileProvider>().currentUserOrPlaceholder;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.editMyProfile,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: ext.dividerLight, height: 1.0),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              // ── قسم الصورة الدائرية (Avatar) المطابق للتصميم ──
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الحدود المتدرجة
                    Container(
                      padding: const EdgeInsets.all(4), // سمك الحدود
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.secondary,
                            colorScheme.primary,
                          ],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 55, // الحجم مطابق للتصميم
                        backgroundColor: colorScheme.surface,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : _getProfileImageProvider(
                                currentUser.profileImageUrl,
                              ),
                      ),
                    ),
                    // أيقونة الكاميرا في موضعها الصحيح
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── حقول الإدخال (Form Fields) - بتصميم الـ Border الجديد ──

              // حقل الاسم الكامل
              _buildInputLabel(l10n.fullName),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _nameController,
                hintText: l10n.fullName,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 24),

              // حقل اسم المستخدم
              _buildInputLabel(l10n.username),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _usernameController,
                hintText: l10n.username,
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 24),

              // حقل رقم الهاتف
              _buildInputLabel(l10n.phoneNumber),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _phoneController,
                hintText: l10n.enterPhoneNumber,
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 24),

              // حقل المحافظة
              _buildInputLabel(l10n.governorateLabel),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedLocation,
                isExpanded: true,
                hint: Text(
                  l10n.selectGovernorate,
                  style: GoogleFonts.tajawal(
                    color: ext.textHint,
                    fontSize: 14,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: ext.textHint,
                ),
                dropdownColor: colorScheme.surface,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: ext.textHint,
                    size: 22,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ext.borderLight, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ext.borderLight, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: ShamsConstants.yemeniCities
                    .map(
                      (city) => DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          l10n.localizeCity(city),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedLocation = value),
              ),
              const SizedBox(height: 24),

              // حقل نبذة شخصية
              _buildInputLabel(l10n.bio),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _bioController,
                hintText: l10n.bioHint,
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 48),

              // ── زر الحفظ (Save Button) ──
              CustomSolidButton(
                title: l10n.saveChanges,
                isLoading: _isLoading,
                onPressed: _saveChanges,
              ),
            ],
          ),
        )
      );
  }

  // ويدجت مساعدة لبناء عنوان الحقل
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w700, // Bold
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء الحقل النصي بتصميم الحدود الجديد (بلا خلفية)
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return TextFormField(
      controller: controller,
      style: GoogleFonts.tajawal(fontSize: 15, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.tajawal(
          color: ext.textHint,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: ext.textHint, size: 22),
        filled: false, // لا توجد خلفية ممتلئة
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.borderLight, width: 1),
        ),
        // الحدود الرمادية الفاتحة والنحيفة كما في التصميم
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ), // تحديد بلون التطبيق عند الوقوف عليه
        ),
      ),
    );
  }

}

