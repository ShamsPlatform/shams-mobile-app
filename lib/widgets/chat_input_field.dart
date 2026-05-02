import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ChatInputField extends StatefulWidget {
  // السلك الذي يربط هذا الحقل بالشاشة الرئيسية لإرسال النص
  final ValueChanged<String> onSendMessage;

  const ChatInputField({super.key, required this.onSendMessage});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // مراقبة الحقل لتغيير حالة الزر عند الكتابة
    _messageController.addListener(() {
      final isNotEmpty = _messageController.text.trim().isNotEmpty;
      if (isNotEmpty != _isTyping) {
        setState(() => _isTyping = isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text); // إرسال النص للشاشة الأم
      _messageController.clear(); // تفريغ الحقل بعد الإرسال
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // زر الإرسال (يظهر عند الكتابة) أو زر المرفقات
              _isTyping
                  ? IconButton(
                      icon: const Icon(Icons.send_rounded, size: 28),
                      color: ShamsColors.solarYellow,
                      onPressed: _handleSend,
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_rounded, size: 28),
                      color: ShamsColors.textGray,
                      onPressed: () {},
                    ),

              // حقل النص
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 45, maxHeight: 120),
                  decoration: BoxDecoration(
                    color: ShamsColors.bgWhite,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    style: GoogleFonts.tajawal(fontSize: 15, color: ShamsColors.textGray),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // أيقونات الوسائط (تختفي عند الكتابة لتوفير مساحة)
              if (!_isTyping) ...[
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, size: 24),
                  color: ShamsColors.textGray,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                ),
                const SizedBox(width: 12),
              ],

              IconButton(
                icon: const Icon(Icons.mic_none_rounded, size: 26),
                color: ShamsColors.textGray,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}