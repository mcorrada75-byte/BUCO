import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/buco_db.dart';
import '../models/buco_record.dart';
import '../widgets/card_box.dart';
import '../widgets/photo_picker_tile.dart';

class EditPage extends StatefulWidget {
  final BucoRecord? record;
  const EditPage({super.key, this.record});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _lat;
  double? _lng;
  final List<String> _photos = [];
  bool _locating = false;
  bool _saving = false;

  bool get _isEdit => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    if (r != null) {
      _titleCtrl.text = r.title;
      _descCtrl.text = r.description;
      _lat = r.latitude;
      _lng = r.longitude;
      _photos.addAll(r.photos);
    } else {
      _titleCtrl.text =
          'Buco ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        throw Exception('Servizio GPS non attivo. Attivalo dalle impostazioni.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permesso posizione negato.');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posizione rilevata')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final x = await PhotoPickerHelper.pick(source);
      if (x == null) return;
      final appDir = await getApplicationDocumentsDirectory();
      final dest = p.join(
        appDir.path,
        'buco_${DateTime.now().millisecondsSinceEpoch}${p.extension(x.path)}',
      );
      await File(x.path).copy(dest);
      if (!mounted) return;
      setState(() => _photos.add(dest));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }

  void _removePhoto(String path) {
    setState(() => _photos.remove(path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final record = BucoRecord(
      id: widget.record?.id,
      title: _titleCtrl.text.trim().isEmpty
          ? 'Buco ${DateFormat('dd/MM/yyyy HH:mm').format(now)}'
          : _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: _lat,
      longitude: _lng,
      photos: List<String>.from(_photos),
      createdAt: widget.record?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      if (record.id == null) {
        await BucoDb.instance.insert(record);
      } else {
        await BucoDb.instance.update(record);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Salvataggio fallito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifica buco' : 'Nuovo buco'),
        actions: [
          IconButton(
            tooltip: 'Salva',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ----- TITOLO -----
            CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                      icon: Icons.title, text: 'Titolo'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleCtrl,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      hintText: 'Es. Buco in via Roma',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Inserisci un titolo' : null,
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
                  const _SectionHeader(
                      icon: Icons.location_on_outlined, text: 'Posizione'),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _lat == null
                          ? 'Nessuna posizione rilevata'
                          : 'Latitudine:  ${_lat!.toStringAsFixed(6)}\n'
                              'Longitudine: ${_lng!.toStringAsFixed(6)}',
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _locating ? null : _locate,
                    icon: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(_lat == null
                        ? 'RILEVA POSIZIONE'
                        : 'AGGIORNA POSIZIONE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ----- NOTE -----
            CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                      icon: Icons.description_outlined, text: 'Note'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Aggiungi una descrizione...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ----- FOTO -----
            CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Icons.camera_alt_outlined,
                    text: 'Foto (${_photos.length})',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PhotoPickerTile(
                        onCamera: () => _pickPhoto(ImageSource.camera),
                        onGallery: () => _pickPhoto(ImageSource.gallery),
                      ),
                      ..._photos.map(
                        (path) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(path),
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 92,
                                  height: 92,
                                  color: cs.surfaceContainerHighest,
                                  child:
                                      const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -6,
                              top: -6,
                              child: InkWell(
                                onTap: () => _removePhoto(path),
                                child: const CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.redAccent,
                                  child: Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? 'AGGIORNA BUCO' : 'SALVA BUCO'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionHeader({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
