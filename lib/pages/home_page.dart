import 'package:flutter/material.dart';

import '../data/buco_db.dart';
import 'edit_page.dart';
import 'list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();
  }

  Future<void> _refreshCount() async {
    final c = await BucoDb.instance.count();
    if (!mounted) return;
    setState(() => _count = c);
  }

  Future<void> _openNew() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditPage()),
    );
    _refreshCount();
  }

  Future<void> _openList() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ListPage()),
    );
    _refreshCount();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Buco')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 8),
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)]
                    : [Colors.grey.shade200, Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 96, color: cs.primary),
                const SizedBox(height: 6),
                Text(
                  'Benvenuto in Buco',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Text(
                    'Salva la posizione dei buchi, aggiungi foto e note '
                    'per ritrovarli facilmente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_count ${_count == 1 ? "buco salvato" : "buchi salvati"}',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _HomeAction(
            icon: Icons.add_location_alt,
            title: 'Nuovo buco',
            subtitle: 'Rileva posizione, aggiungi foto e note',
            onTap: _openNew,
          ),
          const SizedBox(height: 16),
          _HomeAction(
            icon: Icons.list_alt,
            title: 'Elenco buchi',
            subtitle: 'Visualizza e gestisci i buchi salvati',
            onTap: _openList,
          ),
        ],
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF6F6F6F),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: cs.primary,
                radius: 28,
                child: Icon(icon, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
