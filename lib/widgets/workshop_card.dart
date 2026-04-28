import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// WorkshopCard — بطاقة عرض الورشة مع بيانات المستخدم وحالة المتابعة
class WorkshopCard extends StatefulWidget {
  /// اسم المستخدم / صاحب الورشة
  final String username;

  /// مسار الصورة الشخصية (asset أو network)
  final String imagePath;

  /// اسم المدينة
  final String cityName;

  /// تقييم الورشة (من 0.0 إلى 5.0)
  final double rating;

  /// هل المستخدم الحالي يتابع هذه الورشة؟
  final bool isFollowing;

  /// عدد المتابعين (اختياري)
  final int? followersCount;

  /// callback عند الضغط على زر المتابعة
  final ValueChanged<bool>? onFollowToggle;

  /// callback عند الضغط على البطاقة
  final VoidCallback? onTap;

  const WorkshopCard({
    super.key,
    required this.username,
    required this.imagePath,
    required this.cityName,
    required this.rating,
    required this.isFollowing,
    this.followersCount,
    this.onFollowToggle,
    this.onTap,
  }) : assert(rating >= 0.0 && rating <= 5.0, 'rating must be between 0 and 5');

  @override
  State<WorkshopCard> createState() => _WorkshopCardState();
}

class _WorkshopCardState extends State<WorkshopCard>
    with SingleTickerProviderStateMixin {
  late bool _isFollowing;
  late AnimationController _followAnimController;
  late Animation<double> _followScaleAnim;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
    _followAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _followScaleAnim = _followAnimController;
  }

  @override
  void didUpdateWidget(WorkshopCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowing != widget.isFollowing) {
      _isFollowing = widget.isFollowing;
    }
  }

  @override
  void dispose() {
    _followAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleFollowTap() async {
    await _followAnimController.reverse();
    await _followAnimController.forward();
    setState(() => _isFollowing = !_isFollowing);
    widget.onFollowToggle?.call(_isFollowing);
  }

  /// يحدد لون النجوم بناءً على التقييم
  Color _ratingColor(double rating) {
    if (rating >= 4.0) return ShamsColors.verifiedGreen;
    if (rating >= 2.5) return ShamsColors.solarYellow;
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = widget.imagePath.startsWith('http');

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ShamsColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ShamsColors.primaryBlue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── الرأس: خلفية زرقاء متدرجة ──────────────────────────────
            _buildCardHeader(isNetworkImage),

            // ── محتوى البطاقة ─────────────────────────────────────────
            _buildCardBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(bool isNetworkImage) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ShamsColors.primaryBlue, Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // نقاط زخرفية
          Positioned(
            top: -10,
            right: -10,
            child: _DecorativeDot(size: 80, opacity: 0.08),
          ),
          Positioned(
            top: 20,
            left: 30,
            child: _DecorativeDot(size: 40, opacity: 0.06),
          ),

          // صورة الملف الشخصي (تطل من الأسفل)
          Positioned(
            bottom: -36,
            right: 20,
            child: _buildAvatar(isNetworkImage),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isNetworkImage) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ShamsColors.bgWhite, width: 3),
        boxShadow: [
          BoxShadow(
            color: ShamsColors.primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: isNetworkImage
            ? Image.network(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(),
              )
            : Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(),
              ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFFD6E4FF),
      child: Center(
        child: Text(
          widget.username.isNotEmpty
              ? widget.username[0].toUpperCase()
              : '؟',
          style: GoogleFonts.tajawal(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ShamsColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── الصف العلوي: الاسم + زر المتابعة ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المستخدم والمدينة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: GoogleFonts.tajawal(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ShamsColors.textGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: ShamsColors.primaryBlue,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            widget.cityName,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: ShamsColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // زر المتابعة مع أنيميشن
              ScaleTransition(
                scale: _followScaleAnim,
                child: _FollowButton(
                  isFollowing: _isFollowing,
                  onTap: _handleFollowTap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0F4FF), thickness: 1),
          const SizedBox(height: 12),

          // ── الصف السفلي: التقييم + عدد المتابعين ────────────────────
          Row(
            children: [
              // التقييم
              _buildRatingChip(),

              if (widget.followersCount != null) ...[
                const SizedBox(width: 12),
                _buildFollowersChip(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip() {
    final color = _ratingColor(widget.rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            widget.rating.toStringAsFixed(1),
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_alt_rounded,
              size: 15, color: ShamsColors.primaryBlue),
          const SizedBox(width: 4),
          Text(
            _formatCount(widget.followersCount!),
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ShamsColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// زر المتابعة المنفصل
// ─────────────────────────────────────────────────────────────────────────────

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.isFollowing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isFollowing ? ShamsColors.bgWhite : ShamsColors.primaryBlue,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFollowing
                ? const Color(0xFFD0D5DD)
                : ShamsColors.primaryBlue,
            width: 1.5,
          ),
          boxShadow: isFollowing
              ? []
              : [
                  BoxShadow(
                    color: ShamsColors.primaryBlue.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isFollowing
                    ? Icons.check_rounded
                    : Icons.add_rounded,
                key: ValueKey(isFollowing),
                size: 16,
                color: isFollowing
                    ? ShamsColors.textGray
                    : ShamsColors.bgWhite,
              ),
            ),
            const SizedBox(width: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                isFollowing ? 'متابَع' : 'متابعة',
                key: ValueKey(isFollowing),
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFollowing
                      ? ShamsColors.textGray
                      : ShamsColors.bgWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// دائرة زخرفية مساعدة
// ─────────────────────────────────────────────────────────────────────────────

class _DecorativeDot extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeDot({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}