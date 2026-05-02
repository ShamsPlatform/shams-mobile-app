import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ChatInputField extends StatefulWidget {
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
    // نراقب الحقل لكي نضيء زر الإرسال فقط إذا كان هناك نص
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
      widget.onSendMessage(text); // إرسال النص
      _messageController.clear(); // تفريغ الحقل
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5), // خلفية الشريط
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── 1. حقل الإدخال النصي ──
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 45, maxHeight: 120),
                  decoration: BoxDecoration(
                    color: ShamsColors.bgWhite,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    style: GoogleFonts.tajawal(fontSize: 15, color: ShamsColors.textGray),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: 'اكتب رسالتك...', // نص إرشادي خفيف
                      hintStyle: GoogleFonts.tajawal(color: const Color(0xFFBFC3CE), fontSize: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── 2. زر الإرسال الدائري ──
              Container(
                margin: const EdgeInsets.only(bottom: 2), // محاذاة بسيطة للأسفل
                decoration: BoxDecoration(
                  // لون أصفر إذا كان يكتب، ورمادي باهت إذا كان الحقل فارغاً
                  color: _isTyping ? ShamsColors.solarYellow : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 20),
                  color: Colors.white,
                  // الزر معطل (null) إذا لم يكن هناك نص، ويعمل إذا كتب شيئاً
                  onPressed: _isTyping ? _handleSend : null, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}