import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/main_screen.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:shams_mobile_app/features/chat/presentation/widgets/chat_tile.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/constants/workshop_assets.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';

class ChatListScreen extends StatefulWidget {
  final VoidCallback? onExploreWorkshops;

  const ChatListScreen({super.key, this.onExploreWorkshops});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _searchQuery = '';
  final Set<String> _selectedChatIds = {};

  void _toggleSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _selectAll(List<Chat> visibleChats) {
    setState(() {
      final visibleIds = visibleChats.map((c) => c.chatId).toList();
      final allSelected = visibleIds.isNotEmpty && visibleIds.every((id) => _selectedChatIds.contains(id));
      if (allSelected) {
        for (final id in visibleIds) {
          _selectedChatIds.remove(id);
        }
      } else {
        _selectedChatIds.addAll(visibleIds);
      }
    });
  }

  Widget _buildSelectionBar(List<Chat> visibleChats, AppLocalizations l10n) {
    final allSelected = visibleChats.isNotEmpty && visibleChats.every((c) => _selectedChatIds.contains(c.chatId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  onPressed: _clearSelection,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.selectedCount(_selectedChatIds.length),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _selectAll(visibleChats),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    allSelected ? Icons.deselect : Icons.select_all,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    allSelected ? l10n.deselectAll : l10n.selectAll,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmationDialog(context, _selectedChatIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(
                    l10n.delete,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatListProvider = context.watch<ChatListProvider>();
    final currentUser = context.watch<ProfileProvider>().currentUserOrPlaceholder;
    final workshopsProvider = context.watch<WorkshopsProvider>();
    final l10n = AppLocalizations.of(context)!;
    final allChats = chatListProvider.chats;

    final filteredChats = _searchQuery.isEmpty 
        ? allChats 
        : allChats.where((c) {
            if (c.participants.isEmpty) return false;
            final otherParticipant = c.participants.firstWhere((p) => p.id != currentUser.id, orElse: () => c.participants.first);
            final workshopMatch = workshopsProvider.getWorkshopByOwnerId(otherParticipant.id);
            final displayName = workshopMatch != null ? workshopMatch.name : otherParticipant.name;
            return displayName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    final searchBar = InlineSearchBar(
      hintText: l10n.searchChatsHint,
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
    );

    final subHeader = _selectedChatIds.isNotEmpty
        ? _buildSelectionBar(filteredChats, l10n)
        : (_searchQuery.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Text(
                  l10n.recentChats,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              )
            : null);

    Widget buildStatusOrEmptyBody() {
      if (chatListProvider.status == ViewStatus.loading && allChats.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      if (chatListProvider.status == ViewStatus.failure && allChats.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.localizeErrorMessage(
                      chatListProvider.errorMessage,
                      fallback: l10n.failedToLoadChats,
                    ),
                    style: GoogleFonts.tajawal(
                      color: Theme.of(context)
                          .extension<ShamsExtendedColors>()!
                          .textHint,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.read<ChatListProvider>().load(),
                  child: Text(
                    l10n.retry,
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _searchQuery.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.35),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 42,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        l10n.noChatsYet,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        l10n.startChatFromWorkshop,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: CustomSolidButton(
                          title: l10n.exploreWorkshops,
                          onPressed: () {
                            if (widget.onExploreWorkshops != null) {
                              widget.onExploreWorkshops!();
                            } else {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MainScreen(initialIndex: 1),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.noChatsMatching(_searchQuery),
                    style: GoogleFonts.tajawal(
                      color: Theme.of(context)
                          .extension<ShamsExtendedColors>()!
                          .textHint,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      );
    }

    Widget buildChatItem(BuildContext context, int index) {
      final chat = filteredChats[index];
      final otherParticipant = chat.participants.isEmpty
          ? AppUser(id: '', name: l10n.chatFallbackTitle, email: '')
          : chat.participants.firstWhere(
              (p) => p.id != currentUser.id,
              orElse: () => chat.participants.first,
            );

      final workshopMatch =
          workshopsProvider.getWorkshopByOwnerId(otherParticipant.id);
      final displayName =
          workshopMatch != null ? workshopMatch.name : otherParticipant.name;
      final displayAvatar = workshopMatch != null
          ? (workshopMatch.logoUrl ?? kDefaultWorkshopLogoAsset)
          : (otherParticipant.profileImageUrl ?? kDefaultWorkshopLogoAsset);

      final lastMessage = chat.messages.isNotEmpty
          ? chat.messages.first.text
          : l10n.noMessagesYetShort;
      final unreadCount = chat.messages
          .where((m) => !m.isRead && m.senderId != currentUser.id)
          .length;

      return ChatTile(
        name: displayName,
        lastMessage: lastMessage,
        time: l10n.formatRelativeTimeLocalized(chat.lastMessageTime),
        isOnline: false, // Dummy online status
        unreadCount: unreadCount,
        avatarPath: displayAvatar,
        isSelected: _selectedChatIds.contains(chat.chatId),
        onTap: () {
          if (_selectedChatIds.isNotEmpty) {
            _toggleSelection(chat.chatId);
          } else {
            final chatList = context.read<ChatListProvider>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatConversationScreen(
                  chatId: chat.chatId,
                ),
              ),
            ).then((_) {
              chatList.markAsRead(chat.chatId);
            });
          }
        },
        onLongPress: () {
          _toggleSelection(chat.chatId);
        },
      );
    }

    final showList =
        !(chatListProvider.status == ViewStatus.loading && allChats.isEmpty) &&
            !(chatListProvider.status == ViewStatus.failure &&
                allChats.isEmpty) &&
            filteredChats.isNotEmpty;

    return Scaffold(
      backgroundColor:
          Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          l10n.chatsTitle,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: Theme.of(context)
                .extension<ShamsExtendedColors>()!
                .dividerLight,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: searchBar),
          if (subHeader != null) SliverToBoxAdapter(child: subHeader),
          if (showList)
            SliverList.separated(
              itemCount: filteredChats.length,
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(context)
                    .extension<ShamsExtendedColors>()!
                    .dividerLight,
                height: 1,
              ),
              itemBuilder: buildChatItem,
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: buildStatusOrEmptyBody(),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, List<String> chatIds) {
    final count = chatIds.length;
    if (count == 0) return;
    final l10n = AppLocalizations.of(context)!;

    showShamsDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          count == 1 ? l10n.deleteChatTitle : l10n.deleteSelectedChatsTitle,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        content: Text(
          count == 1
              ? l10n.deleteChatConfirm
              : l10n.deleteSelectedChatsConfirm(count),
          style: GoogleFonts.tajawal(
            fontSize: 14.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.tajawal(
                color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Show loading indicator
              showShamsDialog(
                context: context,
                barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              );

              final chatList = context.read<ChatListProvider>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final errorColor = Theme.of(context).colorScheme.error;

              final deleted = await chatList.deleteMultipleChats(chatIds);

              // Hide loading indicator
              navigator.pop();

              if (!context.mounted) return;
              if (deleted) {
                _clearSelection();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      count == 1
                          ? l10n.chatDeletedSuccess
                          : l10n.chatsDeletedSuccess,
                      style: GoogleFonts.tajawal(),
                    ),
                    backgroundColor: errorColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.localizeErrorMessage(
                        chatList.errorMessage,
                        fallback: l10n.deleteError,
                      ),
                      style: GoogleFonts.tajawal(),
                    ),
                    backgroundColor: errorColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
