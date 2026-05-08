import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/buco_db.dart';
import '../models/buco_record.dart';
import '../widgets/card_box.dart';
import 'edit_page.dart';

class DetailPage extends StatefulWidget {
  final int recordId;
  const DetailPage({super.key, required this.recordId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  BucoRecord? _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await BucoDb.instance.findById(widget.recordId);
    if (!mounted) return;
    setState(() {
      _record = r;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    if (_record == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => EditPage(record: _record)),
    );
    if (updated == true) _load();
  }

  Future<void> _delete() async {
    if (_record == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminare buco?'),
        content:
            const Text('Questa operazione non può essere annullata.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true && _record!.id != null) {
      await BucoDb.instance.delete(_record!.id!);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _openPhoto(int index) {
    if (_record == null || _record!.photos.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PhotoViewer(photos: _record!.photos, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dettaglio')),
        body: const Center(child: Text('Buco non trovato')),
      );
    }
    final r = _record!;
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd MMMM yyyy - HH:mm', 'it_IT');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio buco'),
        actions: [
          IconButton(
            tooltip: 'Modifica',
            onPressed: _edit,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Elimina',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----- HEADER FOTO -----
          if (r.photos.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 240,
                child: PageView.builder(
                  itemCount: r.photos.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openPhoto(i),
                    child: Image.file(
                      File(r.photos[i]),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        size: 56, color: cs.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('Nessuna foto', style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          if (r.photos.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '${r.photos.length} foto - scorri per vederle',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // ----- TITOLO -----
          CardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event,
                        size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Creato: ${dateFmt.format(r.createdAt)}',
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                if (r.updatedAt.difference(r.createdAt).inSeconds.abs() > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.update,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Aggiornato: ${dateFmt.format(r.updatedAt)}',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ----- POSIZIONE -----
          CardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: cs.primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Posizione',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (r.hasLocation)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Latitudine:  ${r.latitude!.toStringAsFixed(6)}\n'
                      'Longitudine: ${r.longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 13),
                    ),
                  )
                else
                  Text('Posizione non disponibile',
                      style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ----- NOTE -----
          CardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: cs.primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Note',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  r.description.isEmpty
                      ? 'Nessuna nota inserita.'
                      : r.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: r.description.isEmpty
                        ? cs.onSurfaceVariant
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ----- AZIONI -----
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit),
                  label: const Text('MODIFICA'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('ELIMINA'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;
  const _PhotoViewer({required this.photos, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initialIndex);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.file(
              File(photos[i]),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
