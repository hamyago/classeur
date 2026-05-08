import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../shared/sidebar.dart';

class InterventionsScreen extends StatefulWidget {
  const InterventionsScreen({super.key});
  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  String _statusFilter = 'all';

  static const _statuses = [
    ('all', 'Toutes'),
    ('pending', 'En attente'),
    ('accepted', 'Acceptées'),
    ('in_progress', 'En cours'),
    ('completed', 'Terminées'),
    ('cancelled', 'Annulées'),
  ];

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
                      stream: _statusFilter == 'all'
                          ? FirebaseFirestore.instance
                              .collection('interventions')
                              .orderBy('created_at', descending: true)
                              .limit(100)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('interventions')
                              .where('status', isEqualTo: _statusFilter)
                              .orderBy('created_at', descending: true)
                              .limit(100)
                              .snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snap.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text('Aucune intervention',
                                style: TextStyle(color: AdminColors.textMuted)),
                          );
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AdminColors.sidebar,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('SERVICE')),
                                DataColumn(label: Text('CLIENT')),
                                DataColumn(label: Text('PRESTATAIRE')),
                                DataColumn(label: Text('ADRESSE')),
                                DataColumn(label: Text('MONTANT')),
                                DataColumn(label: Text('PAIEMENT')),
                                DataColumn(label: Text('STATUT')),
                                DataColumn(label: Text('DATE')),
                              ],
                              rows: docs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                final ts = d['created_at'] as Timestamp?;
                                final status = d['status'] as String? ?? '';
                                final method = d['payment_method'] as String? ?? '';
                                return DataRow(cells: [
                                  DataCell(Text(d['service_type_name'] as String? ?? '-',
                                      style: const TextStyle(color: AdminColors.textLight))),
                                  DataCell(Text(d['user_name'] as String? ?? '-',
                                      style: const TextStyle(color: AdminColors.textLight))),
                                  DataCell(Text(d['provider_name'] as String? ?? 'Non assigné',
                                      style: const TextStyle(color: AdminColors.textMuted))),
                                  DataCell(SizedBox(
                                    width: 140,
                                    child: Text(d['user_address'] as String? ?? '-',
                                        style: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                  )),
                                  DataCell(Text(_fcfa((d['total_price'] as num?)?.toDouble() ?? 0),
                                      style: const TextStyle(color: AdminColors.success, fontWeight: FontWeight.w600))),
                                  DataCell(Text(_paymentLabel(method),
                                      style: const TextStyle(color: AdminColors.textMuted, fontSize: 12))),
                                  DataCell(_StatusBadge(status: status)),
                                  DataCell(Text(
                                      ts != null ? DateFormat('dd/MM HH:mm').format(ts.toDate()) : '-',
                                      style: const TextStyle(color: AdminColors.textMuted, fontSize: 12))),
                                ]);
                              }).toList(),
                            ),
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
            const Text('Interventions', style: TextStyle(color: AdminColors.textLight,
                fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(width: 24),
            ..._statuses.map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _statusFilter = s.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusFilter == s.$1 ? AdminColors.primary.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _statusFilter == s.$1 ? AdminColors.primary : AdminColors.border,
                    ),
                  ),
                  child: Text(s.$2, style: TextStyle(
                    color: _statusFilter == s.$1 ? AdminColors.primary : AdminColors.textMuted,
                    fontSize: 12, fontWeight: FontWeight.w500,
                  )),
                ),
              ),
            )),
          ],
        ),
      );

  String _fcfa(double v) => '${NumberFormat('#,###', 'fr_FR').format(v.round())} F';
  String _paymentLabel(String m) => switch (m) {
    'orange_money' => '🟠 Orange',
    'wave'         => '🔵 Wave',
    'card'         => '💳 Carte',
    _              => m,
  };
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending'     => ('En attente', AdminColors.warning),
      'accepted'    => ('Acceptée',   AdminColors.primary),
      'in_progress' => ('En cours',   AdminColors.primary),
      'completed'   => ('Terminée',   AdminColors.success),
      'cancelled'   => ('Annulée',    AdminColors.error),
      _             => ('Inconnu',    AdminColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
