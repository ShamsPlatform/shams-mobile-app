import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/chat.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/conversation_provider.dart';
import 'package:shams_mobile_app/widgets/message_bubble.dart';
import 'package:shams_mobile_app/widgets/chat_input_field.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChatConversationScreen — شاشة المحادثة الفردية
//
// • Scopes [ConversationProvider] per screen and closes its realtime channel on exit.
// • Date dividers are inserted automatically between messages on different days.
// ─────────────────────────────────────────────────────────────────────────────

class ChatConversationScreen extends StatelessWidget {
  final String chatId;

  const ChatConversationScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConversationProvider>(
      create: (ctx) {
        final chatList = ctx.read<ChatListProvider>();
        return sl<ConversationProvider>()
          ..setSyncCallbacks(
            onMessageSent: chatList.applySentMessage,
            onCleared: chatList.clearChat,
          )
          ..open(chatId, initialChat: chatList.getChatById(chatId));
      },
      child: _ChatConversationView(chatId: chatId),
    );
  }
}

class _ChatConversationView extends StatefulWidget {
  final String chatId;

  const _ChatConversationView({required this.chatId});

  @override
  State<_ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<_ChatConversationView> {
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isMuted = false;

  Widget _buildChatAvatar(String? path, String name) {
    if (path == null || path.isEmpty) {
      return _buildFallbackAvatar(name);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
        );
      } else {
        return _buildFallbackAvatar(name);
      }
    }
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      color: Theme.of(context).extension<ShamsExtendedColors>()!.avatarFallbackBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _addNewMessage(String text) async {
    if (text.trim().isEmpty) return;
    final currentUser =
        context.read<ProfileProvider>().currentUserOrPlaceholder;
    final conversation = context.read<ConversationProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    final sent = await conversation.sendMessage(
      senderId: currentUser.id,
      text: text,
    );
    if (!sent && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            conversation.errorMessage ?? 'تعذر إرسال الرسالة',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Returns a human-readable date label for a given [date].
  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return 'اليوم';
    if (msgDay == yesterday) return 'أمس';

    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }

  /// Returns true if [a] and [b] are on different calendar days.
  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  @override
  Widget build(BuildContext context) {
    final conversation = context.watch<ConversationProvider>();
    final currentUser = context.watch<ProfileProvider>().currentUserOrPlaceholder;
    final chat = conversation.chat ??
        context.watch<ChatListProvider>().getChatById(widget.chatId) ??
        Chat(
          chatId: widget.chatId,
          participants: const [],
          messages: const [],
          lastMessageTime: DateTime.now(),
        );
    final otherParticipant = chat.participants.isEmpty
        ? const AppUser(id: '', name: 'محادثة', email: '')
        : chat.participants.firstWhere(
            (p) => p.id != currentUser.id,
            orElse: () => chat.participants.first,
          );

    String displayName = otherParticipant.name;
    String? displayAvatar = otherParticipant.profileImageUrl;

    final workshopsProvider = context.watch<WorkshopsProvider>();
    final workshopMatch =
        workshopsProvider.getWorkshopByOwnerId(otherParticipant.id);
    if (workshopMatch != null) {
      displayName = workshopMatch.name;
      displayAvatar = workshopMatch.logoUrl ?? displayAvatar;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0F2F5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildChatAvatar(displayAvatar, displayName),
              ),
              const SizedBox(width: 10),
              Text(
                displayName,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onSelected: (value) {
                if (value == 'search') {
                  setState(() => _isSearching = true);
                } else if (value == 'mute') {
                  setState(() => _isMuted = !_isMuted);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isMuted ? 'تم كتم إشعارات هذه المحادثة' : 'تم تفعيل إشعارات هذه المحادثة',
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.inverseSurface,
                        behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (value == 'clear') {
                  // Show confirmation dialog before clearing
                  _showClearChatDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'search',
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('بحث', style: GoogleFonts.tajawal()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(
                        _isMuted ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isMuted ? 'تفعيل الإشعارات' : 'كتم الإشعارات',
                        style: GoogleFonts.tajawal(),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مسح المحادثة',
                        style: GoogleFonts.tajawal(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isSearching)
              InlineSearchBar(
                hintText: 'ابحث في المحادثة...',
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onClose: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                  });
                },
              ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final allMessages = conversation.messages;
                  final filteredMessages = _searchQuery.isEmpty
                      ? allMessages
                      : allMessages.where((msg) {
                          return msg.text
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                        }).toList();

                  if (conversation.status == ViewStatus.loading &&
                      allMessages.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }

                  // ── Empty chat state ──────────────────────────────────────
                  if (allMessages.isEmpty && _searchQuery.isEmpty) {
                    return _buildEmptyChatState();
                  }

                  // ── No search results ─────────────────────────────────────
                  if (filteredMessages.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج لـ "$_searchQuery"',
                        style: GoogleFonts.tajawal(
                          color: Theme.of(context)
                              .extension<ShamsExtendedColors>()!
                              .textHint,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // ── Build list items with date dividers ───────────────────
                  // Because the list is reversed, index 0 is the newest message.
                  // We insert a date divider when adjacent messages (i) and (i+1)
                  // are on different calendar days — i+1 is older in reversed order.
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final msg = filteredMessages[index];
                      final isMe = msg.senderId == currentUser.id;

                      // Check if we need a date divider above this message.
                      // In a reversed list, index+1 is the message *before* this one.
                      final bool showDivider = index == filteredMessages.length - 1 ||
                          _isDifferentDay(
                            msg.timestamp,
                            filteredMessages[index + 1].timestamp,
                          );

                      return Column(
                        children: [
                          MessageBubble(
                            message: msg.text,
                            time: _formatTime(msg.timestamp),
                            isMe: isMe,
                            isRead: msg.isRead,
                          ),
                          if (showDivider)
                            _DateDivider(label: _formatDateLabel(msg.timestamp)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            // ربط حقل الإدخال بدالة الإضافة
            ChatInputField(onSendMessage: _addNewMessage),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Formats a [DateTime] as HH:mm (24-hour) for the message timestamp.
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Confirmation dialog before wiping all messages.
  void _showClearChatDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'مسح المحادثة',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟',
            style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ConversationProvider>().clearMessages();
              },
              child: Text(
                'مسح',
                style: GoogleFonts.tajawal(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 60,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل بعد',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ابدأ المحادثة الآن!',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: Theme.of(context)
                  .extension<ShamsExtendedColors>()!
                  .textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateDivider — فاصل التاريخ بين الرسائل
// ─────────────────────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final String label;

  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).extension<ShamsExtendedColors>()!.dividerLight,
              endIndent: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11.5,
                color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).extension<ShamsExtendedColors>()!.dividerLight,
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }
}
