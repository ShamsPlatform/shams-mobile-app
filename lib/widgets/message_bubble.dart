import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isRead; // جديد: لمعرفة حالة قراءة الرسالة

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    this.isRead = false, // القيمة الافتراضية: غير مقروءة
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      // محاذاة لليسار إذا كانت رسالتي، ولليمين إذا كانت من الورشة
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // اللون أصفر شمسي لرسالتي، ورمادي فاتح لرسالة الورشة
          color: isMe ? ShamsColors.solarYellow : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: Radius.circular(isMe ? 16 : 0), // ذيل الورشة في الأعلى يميناً
            bottomRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 0 : 16), // ذيل رسالتي في الأسفل يساراً
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: isMe ? ShamsColors.bgWhite : ShamsColors.textGray,
                height: 1.5, // لزيادة وضوح المسافة بين السطور
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min, // لكي لا يتمدد الصف
              children: [
                Text(
                  time,
                  style: textTheme.labelSmall?.copyWith(
                    color: isMe ? Colors.white70 : const Color(0xFF9EA3B0),
                    fontSize: 11,
                  ),
                ),
                // إظهار علامات القراءة فقط إذا كانت الرسالة صادرة مني (isMe)
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.check_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}