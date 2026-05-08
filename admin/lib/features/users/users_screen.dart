import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../shared/sidebar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .orderBy('created_at', descending: true)
                          .snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        var docs = snap.data!.docs;
                        if (_search.isNotEmpty) {
                          docs = docs.where((d) {
                            final data = d.data() as Map<String, dynamic>;
                            return (data['name'] as String? ?? '').toLowerCase().contains(_search.toLowerCase()) ||
                                (data['phone'] as String? ?? '').contains(_search);
                          }).toList();
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: docs.map((doc) => _UserRow(doc: doc)).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _topBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AdminColors.sidebar,
          border: Border(bottom: BorderSide(color: AdminColors.border)),
        ),
        child: Row(
          children: [
            const Text('Utilisateurs', style: TextStyle(color: AdminColors.textLight,
                fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: 240,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                style: const TextStyle(color: AdminColors.textLight, fontSize: 13),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          ],
        ),
      );
}

class _UserRow extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _UserRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;
    final isBlocked = d['is_blocked'] as bool? ?? false;
    final rating    = (d['rating'] as num?)?.toDouble() ?? 5.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.sidebar,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AdminColors.primary.withOpacity(0.15),
            child: Text(
              (d['name'] as String? ?? '?').isNotEmpty
                  ? (d['name'] as String)[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(d['name'] as String? ?? 'Sans nom',
                      style: const TextStyle(color: AdminColors.textLight, fontWeight: FontWeight.w600)),
                  if (isBlocked) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AdminColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Bloqué',
                          style: TextStyle(color: AdminColors.error, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text('${d['phone'] ?? '-'} • ⭐ ${rating.toStringAsFixed(1)} • ${d['total_interventions'] ?? 0} interventions',
                    style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _toggleBlock(context, doc.id, isBlocked),
            icon: Icon(isBlocked ? Icons.check : Icons.block, size: 16),
            label: Text(isBlocked ? 'Débloquer' : 'Bloquer'),
            style: TextButton.styleFrom(
              foregroundColor: isBlocked ? AdminColors.success : AdminColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBlock(BuildContext context, String uid, bool isBlocked) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'is_blocked': !isBlocked});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBlocked ? 'Utilisateur débloqué' : 'Utilisateur bloqué'),
          backgroundColor: isBlocked ? AdminColors.success : AdminColors.error,
        ),
      );
    }
  }
}
