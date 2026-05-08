import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/services/firestore_admin_service.dart';
import '../../shared/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Column(
                children: [
                  _Header(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('interventions')
                          .orderBy('created_at', descending: true)
                          .limit(200)
                          .snapshots(),
                      builder: (_, snap) {
                        final docs = snap.data?.docs ?? [];
                        int pending = 0, active = 0, completed = 0, cancelled = 0;
                        double gross = 0, commission = 0;
                        for (final d in docs) {
                          final data = d.data() as Map<String, dynamic>;
                          final status = data['status'] as String? ?? '';
                          if (status == 'pending') pending++;
                          if (['accepted', 'in_progress'].contains(status)) active++;
                          if (status == 'completed') {
                            completed++;
                            gross += (data['total_price'] as num?)?.toDouble() ?? 0;
                            commission += (data['commission'] as num?)?.toDouble() ?? 0;
                          }
                          if (status == 'cancelled') cancelled++;
                        }
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vue d\'ensemble',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                                      color: AdminColors.textLight)),
                              const SizedBox(height: 20),
                              // Stats row 1
                              Row(children: [
                                _StatCard(emoji: '🔧', label: 'En attente', value: '$pending',
                                    color: AdminColors.warning),
                                const SizedBox(width: 16),
                                _StatCard(emoji: '🚗', label: 'En cours', value: '$active',
                                    color: AdminColors.primary),
                                const SizedBox(width: 16),
                                _StatCard(emoji: '✅', label: 'Terminées', value: '$completed',
                                    color: AdminColors.success),
                                const SizedBox(width: 16),
                                _StatCard(emoji: '❌', label: 'Annulées', value: '$cancelled',
                                    color: AdminColors.error),
                              ]),
                              const SizedBox(height: 16),
                              // Revenue row
                              Row(children: [
                                _StatCard(emoji: '💰', label: 'Revenus bruts', value: _fcfa(gross),
                                    color: AdminColors.success),
                                const SizedBox(width: 16),
                                _StatCard(emoji: '📊', label: 'Commission Oyop MT', value: _fcfa(commission),
                                    color: AdminColors.primary),
                                const SizedBox(width: 16),
                                _StatCard(emoji: '👥', label: 'Revenus prestataires',
                                    value: _fcfa(gross - commission), color: AdminColors.warning),
                                const SizedBox(width: 16),
                                _UsersProvidersStat(),
                              ]),
                              const SizedBox(height: 28),
                              // Recent interventions
                              const Text('Interventions récentes',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                                      color: AdminColors.textLight)),
                              const SizedBox(height: 12),
                              _RecentInterventions(docs: docs.take(10).toList()),
                            ],
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

  String _fcfa(double v) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(v.round())} FCFA';
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AdminColors.sidebar,
          border: Border(bottom: BorderSide(color: AdminColors.border)),
        ),
        child: Row(
          children: [
            const Text('Tableau de bord',
                style: TextStyle(color: AdminColors.textLight, fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            Text(DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.now()),
                style: const TextStyle(color: AdminColors.textMuted, fontSize: 13)),
          ],
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  final Color color;
  const _StatCard({required this.emoji, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminColors.sidebar,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ]),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
}

class _UsersProvidersStat extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminColors.sidebar,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text('👥', style: TextStyle(fontSize: 20)),
                Spacer(),
                Icon(Icons.people, color: AdminColors.textMuted, size: 16),
              ]),
              const SizedBox(height: 12),
              StreamBuilder<AggregateQuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').count().snapshots(),
                builder: (_, s) => Text('${s.data?.count ?? 0} utilisateurs',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: AdminColors.textLight)),
              ),
              const SizedBox(height: 4),
              StreamBuilder<AggregateQuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('providers').count().snapshots(),
                builder: (_, s) => Text('${s.data?.count ?? 0} prestataires',
                    style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
        ),
      );
}

class _RecentInterventions extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  const _RecentInterventions({required this.docs});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AdminColors.sidebar,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.border),
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('SERVICE')),
            DataColumn(label: Text('UTILISATEUR')),
            DataColumn(label: Text('PRESTATAIRE')),
            DataColumn(label: Text('MONTANT')),
            DataColumn(label: Text('STATUT')),
            DataColumn(label: Text('DATE')),
          ],
          rows: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final status = d['status'] as String? ?? '';
            final ts = d['created_at'] as Timestamp?;
            return DataRow(cells: [
              DataCell(Text(d['service_type_name'] as String? ?? '-',
                  style: const TextStyle(color: AdminColors.textLight))),
              DataCell(Text(d['user_name'] as String? ?? '-',
                  style: const TextStyle(color: AdminColors.textLight))),
              DataCell(Text(d['provider_name'] as String? ?? 'Non assigné',
                  style: const TextStyle(color: AdminColors.textMuted))),
              DataCell(Text(_fcfa((d['total_price'] as num?)?.toDouble() ?? 0),
                  style: const TextStyle(color: AdminColors.success, fontWeight: FontWeight.w600))),
              DataCell(_StatusBadge(status: status)),
              DataCell(Text(ts != null ? DateFormat('dd/MM HH:mm').format(ts.toDate()) : '-',
                  style: const TextStyle(color: AdminColors.textMuted, fontSize: 12))),
            ]);
          }).toList(),
        ),
      );

  String _fcfa(double v) {
    final f = NumberFormat('#,###', 'fr_FR');
    return '${f.format(v.round())} F';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending'     => ('En attente', AdminColors.warning),
      'accepted'    => ('Acceptée', AdminColors.primary),
      'in_progress' => ('En cours', AdminColors.primary),
      'completed'   => ('Terminée', AdminColors.success),
      'cancelled'   => ('Annulée', AdminColors.error),
      _             => ('Inconnu', AdminColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
