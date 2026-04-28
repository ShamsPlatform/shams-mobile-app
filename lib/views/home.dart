import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/appbar.dart';
import '../widgets/post_card.dart';
import '../widgets/shams_bottom_nav_bar.dart';
import '../widgets/search_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// بيانات تجريبية للمنشورات
// ─────────────────────────────────────────────────────────────────────────────

const _kPostContent =
    'تم الانتهاء اليوم من تركيب منظومة طاقة شمسية بقدرة 5 كيلو واط مع عاكس [مكس/JA] قياسي واط في صنعاء، تم استخدام الألواح الأداء ممتازة من غاز عبر.';

final List<Map<String, dynamic>> _kPosts = [
  {
    'username': 'م. أحمد العمودي',
    'userHandle': '@ahmed_solar',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content': _kPostContent,
    'imagePaths': ['assets/images/post image.png'],
    'likesCount': 124,
    'commentsCount': 18,
    'sharesCount': 5,
    'isLiked': false,
  },
  {
    'username': 'م. أحمد العمودي',
    'userHandle': '@ahmed_solar',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content': _kPostContent,
    'imagePaths': ['assets/images/post image.png'],
    'likesCount': 124,
    'commentsCount': 18,
    'sharesCount': 5,
    'isLiked': true,
  },
  {
    'username': 'م. سارة الهاشمي',
    'userHandle': '@sara_energy',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content':
        'مشروع جديد في الرياض! تركيب ألواح شمسية على مبنى تجاري بقدرة 20 كيلو واط. النتائج مبهرة والكفاءة عالية جداً.',
    'imagePaths': ['assets/images/post image.png'],
    'likesCount': 89,
    'commentsCount': 12,
    'sharesCount': 3,
    'isLiked': false,
  },
  {
    'username': 'م. خالد السهيل',
    'userHandle': '@khalid_solar',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content':
        'طرحت اليوم تصميمًا جديدًا لنظام إدارة الطاقة الذكي الذي يعمل مع جميع أنواع الألواح الشمسية. تواصل معي للمزيد!',
    'imagePaths': null,
    'likesCount': 56,
    'commentsCount': 7,
    'sharesCount': 10,
    'isLiked': false,
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — الشاشة الرئيسية لمنصة شمس
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  final List<String> _searchSuggestions = [
    'طاقة شمسية',
    'ألواح كهروضوئية',
    'بطاريات تخزين',
    'عاكس كهربائي',
    'تركيب منظومة',
    'شبكة الكهرباء',
    'توفير الطاقة',
    'الطاقة المتجددة',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        // ── AppBar المُعاد استخدامه من widgets/appbar.dart ──────────
        appBar: ShamsPlatformAppBar(
          hasUnreadNotifications: true,
          onMenuTap: () {},
          onNotificationTap: () {},
          onDarkModeTap: () {},
        ),
        body: _buildBody(context),
        bottomNavigationBar: ShamsBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
        ),
      ),
    );
  }

  // ─── شريط البحث الثابت ────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Material(
      color: ShamsColors.bgWhite,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: GestureDetector(
              onTap: () => showSearch(
                context: context,
                delegate: ShamsSearchDelegate(
                  searchSuggestions: _searchSuggestions,
                ),
              ),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEEF0F4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF9EA3B0),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ابحث عن قبليات، مشاريع أو قطع غيار...',
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        color: const Color(0xFF9EA3B0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F4FF)),
        ],
      ),
    );
  }

  // ─── محتوى الصفحة: بحث ثابت + قائمة المنشورات ───────────────────────────

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── شريط البحث الثابت ────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchBarDelegate(child: _buildSearchBar(context)),
        ),

        // ── فراغ علوي قبل المنشورات ───────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ── قائمة المنشورات ───────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = _kPosts[index];
            return PostCard(
              username: post['username'] as String,
              userHandle: post['userHandle'] as String,
              avatarPath: post['avatarPath'] as String,
              content: post['content'] as String,
              imagePaths: post['imagePaths'] as List<String>?,
              likesCount: post['likesCount'] as int,
              commentsCount: post['commentsCount'] as int,
              sharesCount: post['sharesCount'] as int,
              isLiked: post['isLiked'] as bool,
              onLikeToggle: (liked) {
                debugPrint('Post $index liked: $liked');
              },
              onCommentTap: () {
                debugPrint('Comment tapped on post $index');
              },
              onShareTap: () {
                debugPrint('Share tapped on post $index');
              },
              onMenuTap: () => _showPostMenu(context),
              onUserTap: () {
                debugPrint('User tapped on post $index');
              },
            );
          }, childCount: _kPosts.length),
        ),

        // ── فراغ سفلي ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  // ─── قائمة خيارات المنشور ─────────────────────────────────────────────────

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: ShamsColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE0E8),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              _MenuOption(
                icon: Icons.bookmark_border_rounded,
                label: 'حفظ المنشور',
                onTap: () => Navigator.pop(context),
              ),
              _MenuOption(
                icon: Icons.person_add_outlined,
                label: 'متابعة الحساب',
                onTap: () => Navigator.pop(context),
              ),
              _MenuOption(
                icon: Icons.flag_outlined,
                label: 'الإبلاغ عن المنشور',
                color: const Color(0xFFBA1A1A),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchBarDelegate — مفوض شريط البحث الثابت
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _SearchBarDelegate({required this.child});

  // ارتفاع شريط البحث: تبطين (10) + حقل (46) + تبطين (10) + فاصل (1)
  static const double _height = 67.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) =>
      oldDelegate.child != child;
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuOption — عنصر في قائمة خيارات المنشور
// ─────────────────────────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? ShamsColors.textGray;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
