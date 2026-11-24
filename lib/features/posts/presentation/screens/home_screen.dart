import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/main_screen.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/appbar.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/comments_component.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/post_card.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/post_card_skeleton.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/presentation/constants/workshop_assets.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// (أُزيلت البيانات الوهمية، يتم جلبها الآن من FeedProvider)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — الشاشة الرئيسية لمنصة شمس
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250) {
      context.read<FeedProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
      // ── AppBar المُعاد استخدامه من widgets/appbar.dart ──────────
      appBar: ShamsPlatformAppBar(
        unreadNotifications:
            context.select<NotificationProvider, int>((p) => p.unreadCount),
        onMenuTap: () {
          final rootScaffold = Scaffold.maybeOf(context);
          if (rootScaffold != null && rootScaffold.hasDrawer) {
            rootScaffold.openDrawer();
          } else if (MainScreen.scaffoldKey.currentState?.hasDrawer ?? false) {
            MainScreen.scaffoldKey.currentState?.openDrawer();
          } else {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
          );
        },
        // onDarkModeTap intentionally omitted — AppBar uses ThemeProvider.toggleTheme() by default
      ),
      body: _buildBody(context),
    );
  }

  // ─── شريط البحث الثابت ────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InlineSearchBar(
            hintText: l10n.homeSearchHint,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: ext.dividerLight,
          ),
        ],
      ),
    );
  }

  // ─── محتوى الصفحة: بحث ثابت + قائمة المنشورات ───────────────────────────

  Widget _buildBody(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final l10n = AppLocalizations.of(context)!;
    final allPosts = feedProvider.posts;

    final filteredPosts = _searchQuery.isEmpty 
        ? allPosts 
        : allPosts.where((p) => 
            p.textDetails.toLowerCase().contains(_searchQuery.toLowerCase()) || 
            (p.author?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    return RefreshIndicator(
      onRefresh: () => context.read<FeedProvider>().load(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── شريط البحث الثابت ────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(child: _buildSearchBar(context)),
          ),

          // ── فراغ علوي قبل المنشورات ───────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── قائمة المنشورات ───────────────────────────────
          if (feedProvider.isLoading && allPosts.isEmpty)
            const SliverToBoxAdapter(
              child: PostFeedSkeletonList(),
            )
          else if (filteredPosts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
              child: _searchQuery.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 60,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noPostsYet,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      l10n.noResultsFor(_searchQuery),
                      style: GoogleFonts.tajawal(
                          color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                    ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = filteredPosts[index];
              // Resolve workshop for the post's owner display
              final workshops = context.watch<WorkshopsProvider>().workshops;
              Workshop? postWorkshop;
              if (post.workshopId != null) {
                for (final w in workshops) {
                  if (w.id == post.workshopId) {
                    postWorkshop = w;
                    break;
                  }
                }
              }
              if (postWorkshop == null && post.author != null) {
                for (final w in workshops) {
                  if (w.id == post.author!.id) {
                    postWorkshop = w;
                    break;
                  }
                }
              }

              final displayName = postWorkshop?.name ?? post.author?.name ?? l10n.unknownUser;
              final displayHandle = postWorkshop?.handle ?? (post.author?.email != null ? '@${post.author!.email.split('@').first}' : '@unknown');
              final displayAvatar = postWorkshop?.logoUrl ?? post.author?.profileImageUrl ?? kDefaultWorkshopLogoAsset;

              return GestureDetector(
                // Pass only the postId — PostDetailScreen reads all live data
                // from FeedProvider via context.watch inside its own build().
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                ),
                child: PostCard(
                  username: displayName,
                  userHandle: displayHandle,
                  avatarPath: displayAvatar,
                  content: post.textDetails,
                  imagePaths: post.images.isNotEmpty ? post.images : null,
                  timeAgoText: l10n.formatRelativeTimeLocalized(post.createdAt),
                  heroTag: 'post-media-${post.id}',
                  likesCount: post.likesCount,
                  commentsCount: post.comments.length,
                  sharesCount: 0,
                  isLiked: post.isLiked,
                  // context.read() inside a callback — correct usage.
                  onLikeToggle: (_) =>
                      context.read<FeedProvider>().toggleLike(post.id),
                  onCommentTap: () => showCommentsSheet(
                    context,
                    postId: post.id,
                  ),
                  onShareTap: () => _onShare(context),
                  onMenuTap: () => _showPostMenu(context),
                   onUserTap: () {
                    final workshops = context.read<WorkshopsProvider>().workshops;
                    Workshop? targetWorkshop;

                    if (post.workshopId != null) {
                      for (final w in workshops) {
                        if (w.id == post.workshopId) {
                          targetWorkshop = w;
                          break;
                        }
                      }
                    }

                    if (targetWorkshop == null && post.author != null) {
                      for (final w in workshops) {
                        if (w.id == post.author!.id) {
                          targetWorkshop = w;
                          break;
                        }
                      }
                    }
                    
                    final targetId = targetWorkshop?.id ?? post.author?.id;
                    if (targetId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkshopProfile(workshopId: targetId),
                        ),
                      );
                    }
                  },
                ),
              );
            }, childCount: filteredPosts.length),
          ),

        if (feedProvider.isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.primary,
                  size: 34,
                ),
              ),
            ),
          ),

        // ── فراغ سفلي ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
      ),
    );
  }

  void _onShare(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.postShared,
          style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onInverseSurface),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  // ─── قائمة خيارات المنشور ─────────────────────────────────────────────────

  void _showPostMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showShamsModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .handleBar,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            _MenuOption(
              icon: Icons.bookmark_border_rounded,
              label: l10n.savePost,
              onTap: () => Navigator.pop(context),
            ),
            _MenuOption(
              icon: Icons.person_add_outlined,
              label: l10n.followAccount,
              onTap: () => Navigator.pop(context),
            ),
            _MenuOption(
              icon: Icons.flag_outlined,
              label: l10n.reportPost,
              color: Theme.of(context).colorScheme.error,
              onTap: () => Navigator.pop(context),
            ),
          ],
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
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
