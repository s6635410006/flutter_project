import 'package:flutter/material.dart';
import 'package:flutter_project/views/user_notification_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "การแจ้งเตือน",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink.shade100,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("กรุณาเข้าสู่ระบบ"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _NotificationCategoryCard(
                  icon: Icons.local_offer,
                  iconColor: Colors.pink,
                  title: "แจ้งเตือนประเมินราคา (Custom Cake)",
                  subtitle: "เมื่อแอดมินประเมินราคาแล้วส่งมาให้คุณ",
                  streamCount: supabase
                      .from('custom_requests')
                      .stream(primaryKey: ['id'])
                      .eq('userid', user.id)
                      .order('created_at', ascending: false),
                  countWhen: (row) => row['status']?.toString() == 'price_quoted',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserNotificationPage()),
                  ),
                ),
                const SizedBox(height: 12),
                _DisabledCategoryCard(
                  icon: Icons.receipt_long,
                  title: "อัปเดตสถานะออเดอร์ (เร็ว ๆ นี้)",
                  subtitle: "กำลังเตรียมรองรับแจ้งเตือนการจัดส่ง/สถานะ",
                ),
                const SizedBox(height: 12),
                _DisabledCategoryCard(
                  icon: Icons.chat_bubble_outline,
                  title: "ข้อความแชท (เร็ว ๆ นี้)",
                  subtitle: "กำลังเตรียมรองรับแจ้งเตือนข้อความใหม่",
                ),
              ],
            ),
    );
  }
}

class _NotificationCategoryCard extends StatelessWidget {
  const _NotificationCategoryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.streamCount,
    required this.countWhen,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Stream<List<Map<String, dynamic>>> streamCount;
  final bool Function(Map<String, dynamic> row) countWhen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamCount,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <Map<String, dynamic>>[];
        final count = rows.where(countWhen).length;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (count > 0) _CountPill(count: count),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DisabledCategoryCard extends StatelessWidget {
  const _DisabledCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.brown),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.lock_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          height: 1.0,
        ),
      ),
    );
  }
}

