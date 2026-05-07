import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ManagedPostCard extends StatelessWidget {
  final String content;
  final String timeAgo;
  final String viewsCount;
  final String imagePath;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManagedPostCard({
    super.key,
    required this.content,
    required this.timeAgo,
    required this.viewsCount,
    required this.imagePath,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ShamsColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. الرأس: القائمة المنسدلة + الوقت ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // القائمة المنسدلة الثلاثية (...)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, color: ShamsColors.textGray),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('تعديل', style: GoogleFonts.tajawal(fontSize: 14)),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف', style: GoogleFonts.tajawal(fontSize: 14, color: Colors.red)),
                    ),
                  ],
                ),
                // شارة الوقت (مثال: منذ يومين)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeAgo,
                    style: GoogleFonts.tajawal(fontSize: 11, color: const Color(0xFF9EA3B0), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. نص المنشور ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              content,
              style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: ShamsColors.textGray, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),

          // ── 3. صورة المنشور ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                // صورة افتراضية في حال عدم وجود مسار صحيح أثناء الاختبار
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey, size: 50),
                ),
              ),
            ),
          ),

          // ── 4. عدد المشاهدات ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  viewsCount,
                  style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: ShamsColors.textGray),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.visibility_outlined, size: 18, color: ShamsColors.textGray),
              ],
            ),
          ),
        ],
      ),
    );
  }
}