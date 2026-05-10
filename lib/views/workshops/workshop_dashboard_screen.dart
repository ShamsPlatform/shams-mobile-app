import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/managed_post_card.dart';
import '../../widgets/primary_button.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

class WorkshopDashboardScreen extends StatefulWidget {
  const WorkshopDashboardScreen({super.key});

  @override
  State<WorkshopDashboardScreen> createState() =>
      _WorkshopDashboardScreenState();
}

class _WorkshopDashboardScreenState extends State<WorkshopDashboardScreen> {
  // 💡 بيانات ديناميكية لسجل الأعمال المنشور
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'content':
          'إصلاح شامل لمحرك سيارة دفع رباعي مع تنظيف الأجزاء الداخلية وزيادة كفاءة الأداء بنسبة 20%',
      'timeAgo': 'منذ يومين',
      'viewsCount': '45.8K',
      'imagePaths': ['assets/images/engine1.jpg'],
    },
    {
      'id': '2',
      'content':
          'تغيير فلاتر الزيت والهواء لسيارة تويوتا كامري في وقت قياسي لضمان راحة العميل.',
      'timeAgo': 'منذ 4 أيام',
      'viewsCount': '12.3K',
      'imagePaths': ['assets/images/engine2.jpg'],
    },
    {
      'id': '3',
      'content':
          'فحص كمبيوتر شامل لبرمجة السيارة وتحديد الأعطال الكهربائية بدقة متناهية.',
      'timeAgo': 'منذ أسبوع',
      'viewsCount': '8.1K',
      'imagePaths': ['assets/images/engine3.jpg'],
    },
  ];

  // دالة حذف المنشور ديناميكياً
  void _deletePost(int index) {
    setState(() {
      _posts.removeAt(index);
    });
    // عرض رسالة تأكيد سريعة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المنشور بنجاح', style: GoogleFonts.tajawal()),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: ShamsColors.textGray,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'لوحة تحكم الورشة',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShamsColors.textGray,
            ),
          ),
          centerTitle: true,
        ),

        // جسم الشاشة القابل للتمرير
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── 1. الرأس (صورة الغلاف، الصورة الشخصية، والمعلومات) ──
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // صورة الغلاف + أيقونة الكاميرا
                    Stack(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          color: ShamsColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ), // استبدلها بصورة الغلاف لاحقاً
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: _buildCameraBadge(),
                        ),
                      ],
                    ),

                    // الصورة الشخصية + أيقونة الكاميرا
                    Positioned(
                      top: 100,
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 45,
                              backgroundColor: Color(0xFFF0F2F5),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ), // استبدلها بصورة الورشة
                            ),
                          ),
                          _buildCameraBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // معلومات الورشة
              Text(
                'كراج المجد التقني',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.textGray,
                ),
              ),
              Text(
                '@al_majd_tech',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: const Color(0xFF9EA3B0),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: ShamsColors.textGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'صنعاء، اليمن - شارع الستين',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: ShamsColors.textGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // زر تعديل ملف الورشة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: CustomSolidButton(
                    title: 'تعديل ملف الورشة',
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 2. شريط الإحصائيات (المنشورات والمتابعون) ──
              Divider(color: Colors.grey.shade200, height: 1),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _buildStatColumn(
                      '1.2K',
                      'المتابعون',
                      Icons.people_alt_outlined,
                    ),
                    VerticalDivider(
                      color: Colors.grey.shade200,
                      width: 1,
                      thickness: 1,
                    ),
                    _buildStatColumn('89', 'المنشورات', Icons.article_outlined),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 24),

              // ── 3. سجل الأعمال المنشور (ديناميكي) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل الأعمال المنشور',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShamsColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_posts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'لا توجد أعمال منشورة حالياً.',
                            style: GoogleFonts.tajawal(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // تعطيل سكرول القائمة الداخلية
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return ManagedPostCard(
                            content: post['content'],
                            timeAgo: post['timeAgo'],
                            viewsCount: post['viewsCount'],
                            imagePaths: List<String>.from(
                              post['imagePaths'] ?? [],
                            ),
                            isLocalFile: post['isLocalFile'] ?? false,
                            onEdit: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPostScreen(post: post),
                                ),
                              );
                              if (updated != null &&
                                  updated is Map<String, dynamic>) {
                                setState(() => _posts[index] = updated);
                              }
                            },
                            onDelete: () =>
                                _deletePost(index), // استدعاء دالة الحذف
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ), // مساحة إضافية لكي لا يغطي الزر السفلي المحتوى
            ],
          ),
        ),

        // ── 4. الزر الثابت لنشر عمل جديد (Sticky Button) ──
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _posts.insert(0, result);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShamsColors.solarYellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 24),
                label: Text(
                  'نشر عمل جديد',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت مساعدة لأيقونة الكاميرا الصغيرة
  Widget _buildCameraBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: const Icon(
        Icons.camera_alt_outlined,
        size: 16,
        color: ShamsColors.textGray,
      ),
    );
  }

  // ويدجت مساعدة لعمود الإحصائيات
  Widget _buildStatColumn(String count, String label, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: ShamsColors.textGray),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: const Color(0xFF9EA3B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
