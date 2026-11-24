import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_shimmer.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String userHandle;
  final String avatarPath;
  final String content;
  final List<String>? imagePaths;
  final String? timeAgoText;
  final String? heroTag;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final ValueChanged<bool>? onLikeToggle;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onUserTap;
  final int maxLines;

  const PostCard({
    super.key,
    required this.username,
    required this.userHandle,
    required this.avatarPath,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    this.imagePaths,
    this.timeAgoText,
    this.heroTag,
    this.onLikeToggle,
    this.onCommentTap,
    this.onShareTap,
    this.onMenuTap,
    this.onUserTap,
    this.maxLines = 3,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  bool _isExpanded = false;
  int _currentImageIndex = 0;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _likeScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.30)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.30, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_likeAnimController);
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleLikeTap() {
    if (widget.onLikeToggle == null) return;
    HapticFeedback.lightImpact();
    _likeAnimController
      ..reset()
      ..forward();
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLikeToggle!.call(_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ext.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: ext.borderLight, width: 0.8) : null,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme, ext),
          _buildContent(colorScheme),
          if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
            _buildImageCarousel(ext),
          Divider(color: ext.dividerLight, thickness: 1, height: 1),
          _buildActions(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, ShamsExtendedColors ext) {
    final bool isNetwork = widget.avatarPath.startsWith('http');
    final trimmedHandle = widget.userHandle.trim();
    final formattedHandle = trimmedHandle.isEmpty
        ? ''
        : (trimmedHandle.startsWith('@') ? trimmedHandle : '@$trimmedHandle');

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: widget.onUserTap,
            child: _Avatar(
              imagePath: widget.avatarPath,
              username: widget.username,
              isNetwork: isNetwork,
              colorScheme: colorScheme,
              ext: ext,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: widget.onUserTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (formattedHandle.isNotEmpty)
                        Flexible(
                          child: Text(
                            formattedHandle,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (widget.timeAgoText != null &&
                          widget.timeAgoText!.isNotEmpty) ...[
                        if (formattedHandle.isNotEmpty)
                          Text(
                            ' • ',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: ext.textHint,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            widget.timeAgoText!,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: ext.textHint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MenuButton(onTap: widget.onMenuTap, ext: ext, colorScheme: colorScheme),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showToggle = _shouldShowToggle(constraints.maxWidth);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                firstChild: Text(
                  widget.content,
                  textAlign: TextAlign.start,
                  maxLines: widget.maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.5,
                    height: 1.65,
                    color: colorScheme.onSurface,
                  ),
                ),
                secondChild: Text(
                  widget.content,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.5,
                    height: 1.65,
                    color: colorScheme.onSurface,
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              if (showToggle)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _isExpanded ? l10n.showLess : l10n.readMore,
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  bool _shouldShowToggle(double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.content,
        style: GoogleFonts.tajawal(fontSize: 14.5, height: 1.65),
      ),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final exceeded = tp.didExceedMaxLines;
    tp.dispose();
    return exceeded;
  }

  Widget _buildImageCarousel(ShamsExtendedColors ext) {
    final images = widget.imagePaths!;

    Widget carousel = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          SizedBox(
            height: 210,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (context, index) {
                final path = images[index];
                final isNetwork = path.startsWith('http');
                if (isNetwork) {
                  return _NetworkPostImage(
                    imageUrl: path,
                    ext: ext,
                    fallback: _imagePlaceholder(ext),
                  );
                } else if (path.startsWith('assets/')) {
                  return Image.asset(
                    path,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => _imagePlaceholder(ext),
                  );
                } else {
                  final file = File(path);
                  if (file.existsSync()) {
                    return Image.file(
                      file,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => _imagePlaceholder(ext),
                    );
                  } else {
                    return _imagePlaceholder(ext);
                  }
                }
              },
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.all(10),
              child: _PageIndicatorBadge(
                current: _currentImageIndex + 1,
                total: images.length,
              ),
            ),
        ],
      ),
    );

    if (widget.heroTag != null && widget.heroTag!.isNotEmpty) {
      carousel = Hero(
        tag: widget.heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: carousel,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 14,
        end: 14,
        bottom: 10,
      ),
      child: carousel,
    );
  }

  Widget _imagePlaceholder(ShamsExtendedColors ext) {
    return Container(
      color: ext.imageErrorPlaceholder,
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: ext.textHint.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ActionChip(
                icon: Icons.chat_bubble_outline_rounded,
                count: widget.commentsCount,
                color: colorScheme.onSurfaceVariant,
                onTap: widget.onCommentTap,
              ),
              const SizedBox(width: 18),
              ScaleTransition(
                scale: _likeScaleAnim,
                child: _ActionChip(
                  icon: _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  count: _likesCount,
                  color: _isLiked
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  onTap: widget.onLikeToggle != null ? _handleLikeTap : null,
                  isAnimated: true,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: widget.onShareTap,
            icon: Icon(
              Icons.share_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ── _Avatar ────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String imagePath;
  final String username;
  final bool isNetwork;
  final ColorScheme colorScheme;
  final ShamsExtendedColors ext;

  const _Avatar({
    required this.imagePath,
    required this.username,
    required this.isNetwork,
    required this.colorScheme,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: isNetwork
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _fallback();
                },
                errorBuilder: (_, _, _) => _fallback(),
              )
            : (imagePath.startsWith('assets/')
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(),
                    )
                  : (File(imagePath).existsSync()
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallback(),
                          )
                        : _fallback())),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: ext.avatarFallbackBg,
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ── _MenuButton ──────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;
  final ShamsExtendedColors ext;
  final ColorScheme colorScheme;

  const _MenuButton({this.onTap, required this.ext, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: ext.inputFill,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: ext.borderLight),
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── _PageIndicatorBadge ───────────────────────────────────────────────────────

class _PageIndicatorBadge extends StatelessWidget {
  final int current;
  final int total;

  const _PageIndicatorBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$current/$total',
        style: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── _ActionChip ───────────────────────────────────────────────────────────────

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  final bool isAnimated;

  const _ActionChip({
    required this.icon,
    required this.count,
    required this.color,
    this.onTap,
    this.isAnimated = false,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  int _iconVersion = 0;
  int _countVersion = 0;

  @override
  void didUpdateWidget(_ActionChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.icon != widget.icon) {
      _iconVersion++;
    }
    if (_formatCount(oldWidget.count) != _formatCount(widget.count)) {
      _countVersion++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                widget.icon,
                key: ValueKey('icon-$_iconVersion'),
                size: 22,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _formatCount(widget.count),
                key: ValueKey('count-$_countVersion'),
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}


// ── _NetworkPostImage ─────────────────────────────────────────────────────────

class _NetworkPostImage extends StatelessWidget {
  final String imageUrl;
  final ShamsExtendedColors ext;
  final Widget fallback;

  const _NetworkPostImage({
    required this.imageUrl,
    required this.ext,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final totalBytes = loadingProgress.expectedTotalBytes;
        final progress = totalBytes != null && totalBytes > 0
            ? loadingProgress.cumulativeBytesLoaded / totalBytes
            : null;
        return Stack(
          fit: StackFit.expand,
          children: [
            ShamsShimmer(
              child: Container(color: ext.chipBackground),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ext.cardSurface.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: colorScheme.primary,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ],
        );
      },
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
