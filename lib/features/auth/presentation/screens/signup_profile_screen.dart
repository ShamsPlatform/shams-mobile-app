import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/text_field.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/complete_sign_up_usecase.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';

class SignUpProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  const SignUpProfileScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SignUpProfileScreen> createState() => _SignUpProfileScreenState();
}

class _SignUpProfileScreenState extends State<SignUpProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedLocation;
  File? _profileImage;
  String? _nameError;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // قائمة الـ 21 محافظة يمنية المطلوبة
  final List<String> _cities = [
    'صنعاء', 'عدن', 'تعز', 'الحديدة', 'إب', 'حضرموت', 'ذمار', 'عمران',
    'الضالع', 'لحج', 'أبين', 'المهرة', 'شبوة', 'البيضاء', 'مأرب', 'الجوف',
    'صعدة', 'المحويت', 'حجة', 'ريمة', 'سقطرى',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.email.split('@').first;
    _selectedLocation = 'صنعاء'; // قيمة افتراضية
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _handleCreateAccount() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();
    final location = _selectedLocation;

    setState(() {
      _nameError = name.isEmpty ? 'يرجى إدخال اسمك الكامل' : null;
    });

    if (_nameError == null) {
      setState(() => _isLoading = true);
      try {
        final authProvider = context.read<AuthProvider>();
        final ok = await authProvider.completeSignUp(
          SignUpParams(
            email: widget.email,
            password: widget.password,
            name: name,
            username: username,
            location: location ?? 'صنعاء',
            phone: phone,
            bio: bio,
            avatarPath: _profileImage?.path,
          ),
        );

        if (!mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'حدث خطأ أثناء إكمال الحساب',
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (authProvider.warnings.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.warnings.join('\n'),
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'أكمل ملفك الشخصي',
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'دع مجتمع شمس يتعرف عليك أكثر',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                ),
              ),
              const SizedBox(height: 32),
              
              // ── بطاقة الإدخال ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF0F2F5),
                              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                              child: _profileImage == null 
                                  ? const Icon(Icons.person_outline, size: 50, color: Colors.grey)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _inputLabel('الاسم الكامل *'),
                    CustomTextField(hintText: 'أدخل اسمك الكامل', prefixIcon: Icons.person_outline, controller: _nameController, errorText: _nameError),
                    const SizedBox(height: 16),

                    _inputLabel('اسم المستخدم *'),
                    CustomTextField(hintText: 'أدخل اسم المستخدم', prefixIcon: Icons.alternate_email, controller: _usernameController),
                    const SizedBox(height: 16),

                    _inputLabel('الموقع *'),
                    _buildDropdownField(),
                    const SizedBox(height: 16),

                    _inputLabel('رقم الهاتف (اختياري)'),
                    CustomTextField(hintText: '05xxxxxxxx', prefixIcon: Icons.phone_outlined, controller: _phoneController),
                    const SizedBox(height: 16),

                    _inputLabel('نبذة شخصية (اختياري)'),
                    CustomTextField(hintText: 'مهتم بالطاقة المتجددة...', prefixIcon: Icons.info_outline, controller: _bioController),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : CustomSolidButton(
                              title: 'إنشاء الحساب',
                              onPressed: _handleCreateAccount,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocation,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9EA3B0)),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF9EA3B0), size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 1.5,
          ),
        ),
      ),
      items: _cities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city, style: GoogleFonts.tajawal(fontSize: 15)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocation = value;
        });
      },
    );
  }
}

