import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/buco_db.dart';
import '../models/buco_record.dart';
import 'detail_page.dart';
import 'edit_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<List<BucoRecord>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = BucoDb.instance.all();
    });
  }

  Future<void> _openDetail(BucoRecord r) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailPage(recordId: r.id!)),
    );
    _reload();
  }

  Future<void> _openNew() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditPage()),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elenco buchi'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNew,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo buco'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<BucoRecord>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? const <BucoRecord>[];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.inbox_outlined,
                      size: 84, color: Colors.grey.shade500),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Nessun buco salvato',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tocca "+" per aggiungere il primo buco',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _BucoListItem(
                record: items[i],
                onTap: () => _openDetail(items[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BucoListItem extends StatelessWidget {
  final BucoRecord record;
  final VoidCallback onTap;
  const _BucoListItem({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: record.photos.isEmpty
                    ? Container(
                        width: 108,
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.image_not_supported_outlined,
                            size: 38, color: cs.onSurfaceVariant),
                      )
                    : Image.file(
                        File(record.photos.first),
                        width: 108,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 108,
                          color: cs.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        record.description.isEmpty
                            ? 'Nessuna descrizione'
                            : record.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          Icon(
                            record.hasLocation
                                ? Icons.location_on
                                : Icons.location_off,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.hasLocation
                                  ? '${record.latitude!.toStringAsFixed(4)}, '
                                      '${record.longitude!.toStringAsFixed(4)}'
                                  : 'Posizione non rilevata',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11, color: cs.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd/MM/yy').format(record.createdAt),
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
