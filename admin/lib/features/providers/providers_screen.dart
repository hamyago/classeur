import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../shared/sidebar.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});
  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  String _filter = 'all';
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
                          .collection('providers')
                          .orderBy('created_at', descending: true)
                          .snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        var docs = snap.data!.docs;
                        if (_filter == 'unverified') {
                          docs = docs.where((d) => !(d.data() as Map)['is_verified']).toList();
                        } else if (_filter == 'blocked') {
                          docs = docs.where((d) => !(d.data() as Map)['is_active']).toList();
                        }
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
                            children: docs.map((doc) => _ProviderRow(doc: doc)).toList(),
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
            const Text('Prestataires', style: TextStyle(color: AdminColors.textLight,
                fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(width: 24),
            _FilterChip('Tous', 'all'),
            const SizedBox(width: 8),
            _FilterChip('Non vérifiés', 'unverified'),
            const SizedBox(width: 8),
            _FilterChip('Bloqués', 'blocked'),
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

  Widget _FilterChip(String label, String value) => GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _filter == value ? AdminColors.primary.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _filter == value ? AdminColors.primary : AdminColors.border,
            ),
          ),
          child: Text(label, style: TextStyle(
            color: _filter == value ? AdminColors.primary : AdminColors.textMuted,
            fontSize: 13, fontWeight: FontWeight.w500,
          )),
        ),
      );
}

class _ProviderRow extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _ProviderRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final d = doc.data() as Map<String, dynamic>;
    final isVerified = d['is_verified'] as bool? ?? false;
    final isActive   = d['is_active'] as bool? ?? true;
    final rating     = (d['rating'] as num?)?.toDouble() ?? 5.0;
    final services   = (d['service_types'] as List?)?.cast<String>() ?? [];

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
            backgroundColor: AdminColors.primary.withOpacity(0.2),
            child: Text(
              (d['name'] as String? ?? '?')[0].toUpperCase(),
              style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(d['name'] as String? ?? '-',
                      style: const TextStyle(color: AdminColors.textLight, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  if (isVerified)
                    const Icon(Icons.verified, color: AdminColors.primary, size: 14),
                  if (!isActive) ...[
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
                Text('${d['phone']} • ⭐ ${rating.toStringAsFixed(1)} • ${d['total_interventions'] ?? 0} interventions',
                    style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
                if (services.isNotEmpty)
                  Text(services.join(', '),
                      style: const TextStyle(color: AdminColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // Actions
          if (!isVerified)
            TextButton.icon(
              onPressed: () => _verify(context, doc.id),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Vérifier'),
              style: TextButton.styleFrom(foregroundColor: AdminColors.success),
            ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _toggleBlock(context, doc.id, isActive),
            icon: Icon(isActive ? Icons.block : Icons.check, size: 16),
            label: Text(isActive ? 'Bloquer' : 'Débloquer'),
            style: TextButton.styleFrom(
              foregroundColor: isActive ? AdminColors.error : AdminColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verify(BuildContext context, String uid) async {
    await FirebaseFirestore.instance.collection('providers').doc(uid).update({'is_verified': true});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prestataire vérifié ✅'), backgroundColor: AdminColors.success),
      );
    }
  }

  Future<void> _toggleBlock(BuildContext context, String uid, bool isActive) async {
    await FirebaseFirestore.instance.collection('providers').doc(uid).update({
      'is_active': !isActive, 'is_available': !isActive,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive ? 'Prestataire bloqué' : 'Prestataire débloqué'),
          backgroundColor: isActive ? AdminColors.error : AdminColors.success,
        ),
      );
    }
  }
}
