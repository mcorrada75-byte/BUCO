import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const BucoApp());

class BucoApp extends StatelessWidget {
  const BucoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buco',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6F6F6F),
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 3,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6F6F6F),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class BucoRecord {
  final int? id;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  BucoRecord({
    this.id,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'photos': jsonEncode(photos),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BucoRecord.fromMap(Map<String, dynamic> map) => BucoRecord(
        id: map['id'] as int?,
        title: map['title'] ?? 'Buco senza titolo',
        description: map['description'] ?? '',
        latitude: map['latitude'] == null ? null : (map['latitude'] as num).toDouble(),
        longitude: map['longitude'] == null ? null : (map['longitude'] as num).toDouble(),
        photos: List<String>.from(jsonDecode(map['photos'] ?? '[]')),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );

  BucoRecord copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BucoRecord(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        photos: photos ?? this.photos,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class BucoDb {
  static final BucoDb instance = BucoDb._();
  BucoDb._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'buco.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE buche(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            photos TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<BucoRecord>> all() async {
    final db = await database;
    final rows = await db.query('buche', orderBy: 'createdAt DESC');
    return rows.map(BucoRecord.fromMap).toList();
  }

  Future<int> insert(BucoRecord record) async {
    final db = await database;
    return db.insert('buche', record.toMap());
  }

  Future<void> update(BucoRecord record) async {
    final db = await database;
    await db.update('buche', record.toMap(), where: 'id=?', whereArgs: [record.id]);
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('buche', where: 'id=?', whereArgs: [id]);
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  void goList() => setState(() => index = 1);
  void goHome() => setState(() => index = 0);

  @override
  Widget build(BuildContext context) {
    final pages = [HomePage(onNew: () async => openEditor(context), onList: goList), const ListPage()];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Elenco'),
        ],
      ),
      floatingActionButton: index == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF6F6F6F),
              foregroundColor: Colors.white,
              onPressed: () async {
                await openEditor(context);
                setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

Future<void> openEditor(BuildContext context, {BucoRecord? record}) async {
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditBucoPage(record: record)));
}

class HomePage extends StatelessWidget {
  final VoidCallback onNew;
  final VoidCallback onList;
  const HomePage({super.key, required this.onNew, required this.onList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buco'), actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.more_vert))]),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 12),
          Container(
            height: 235,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(colors: [Colors.grey.shade200, Colors.white]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 112, color: Colors.grey.shade600),
                const SizedBox(height: 8),
                const Text('Benvenuto in Buco', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Salva la posizione dei buchi, aggiungi foto e note per ritrovarli facilmente.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          HomeAction(icon: Icons.add, title: 'Nuovo buco', subtitle: 'Rileva posizione, aggiungi foto e note', onTap: onNew),
          const SizedBox(height: 16),
          HomeAction(icon: Icons.list, title: 'Elenco buchi', subtitle: 'Visualizza e gestisci i buchi salvati', onTap: onList),
        ],
      ),
    );
  }
}

class HomeAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const HomeAction({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF777777), borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)]),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.white, foregroundColor: Colors.black87, radius: 28, child: Icon(icon, size: 32)),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 14))])),
          ],
        ),
      ),
    );
  }
}

class EditBucoPage extends StatefulWidget {
  final BucoRecord? record;
  const EditBucoPage({super.key, this.record});

  @override
  State<EditBucoPage> createState() => _EditBucoPageState();
}

class _EditBucoPageState extends State<EditBucoPage> {
  final desc = TextEditingController();
  double? lat;
  double? lng;
  List<String> photos = [];
  bool locating = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    if (r != null) {
      desc.text = r.description;
      lat = r.latitude;
      lng = r.longitude;
      photos = [...r.photos];
    }
  }

  Future<void> locate() async {
    setState(() => locating = true);
    try {
      var service = await Geolocator.isLocationServiceEnabled();
      if (!service) throw Exception('GPS non attivo');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('Permesso posizione negato');
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { lat = pos.latitude; lng = pos.longitude; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
    if (x == null) return;
    final appDir = await getApplicationDocumentsDirectory();
    final dest = p.join(appDir.path, 'buco_${DateTime.now().millisecondsSinceEpoch}${p.extension(x.path)}');
    await File(x.path).copy(dest);
    setState(() => photos.add(dest));
  }

  Future<void> save() async {
    final now = DateTime.now();
    final title = 'Buco ${DateFormat('dd/MM/yyyy HH:mm').format(now)}';
    final record = BucoRecord(
      id: widget.record?.id,
      title: widget.record?.title ?? title,
      description: desc.text.trim(),
      latitude: lat,
      longitude: lng,
      photos: photos,
      createdAt: widget.record?.createdAt ?? now,
      updatedAt: now,
    );
    if (record.id == null) {
      await BucoDb.instance.insert(record);
    } else {
      await BucoDb.instance.update(record);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.record == null ? 'Nuovo buco' : 'Modifica buco'), actions: [IconButton(onPressed: save, icon: const Icon(Icons.check))]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.location_on_outlined), SizedBox(width: 12), Text('Posizione', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 14),
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)), child: Text(lat == null ? 'Nessuna posizione rilevata' : 'Lat: ${lat!.toStringAsFixed(6)}\nLng: ${lng!.toStringAsFixed(6)}')),
            const SizedBox(height: 14),
            FilledButton.icon(onPressed: locating ? null : locate, icon: locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location), label: const Text('RILEVA POSIZIONE')),
          ])),
          const SizedBox(height: 16),
          CardBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.description_outlined), SizedBox(width: 12), Text('Descrizione', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            TextField(controller: desc, maxLines: 5, decoration: const InputDecoration(hintText: 'Aggiungi una descrizione...', border: OutlineInputBorder())),
          ])),
          const SizedBox(height: 16),
          CardBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.camera_alt_outlined), SizedBox(width: 12), Text('Foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              AddPhotoTile(onCamera: () => pickPhoto(ImageSource.camera), onGallery: () => pickPhoto(ImageSource.gallery)),
              ...photos.map((path) => Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(path), width: 92, height: 92, fit: BoxFit.cover)),
                Positioned(right: 0, top: 0, child: InkWell(onTap: () => setState(() => photos.remove(path)), child: const CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.close, size: 18))))
              ])),
            ]),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('SALVA BUCO')),
          ])),
        ],
      ),
    );
  }
}

class CardBox extends StatelessWidget {
  final Widget child;
  const CardBox({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]), child: child);
}

class AddPhotoTile extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const AddPhotoTile({super.key, required this.onCamera, required this.onGallery});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Wrap(children: [ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Scatta foto'), onTap: () { Navigator.pop(context); onCamera(); }), ListTile(leading: const Icon(Icons.photo_library), title: const Text('Scegli da galleria'), onTap: () { Navigator.pop(context); onGallery(); })]))),
    child: Container(width: 92, height: 92, decoration: BoxDecoration(border: Border.all(color: Colors.grey, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 30), Text('Aggiungi\nfoto', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))])),
  );
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<List<BucoRecord>> future;

  @override
  void initState() { super.initState(); reload(); }
  void reload() => future = BucoDb.instance.all();

  Future<void> delete(BucoRecord r) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminare buco?'), content: const Text('Questa operazione non può essere annullata.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elimina'))]));
    if (ok == true && r.id != null) { await BucoDb.instance.delete(r.id!); setState(reload); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elenco buchi'), actions: [IconButton(onPressed: () => setState(reload), icon: const Icon(Icons.refresh))]),
      body: FutureBuilder<List<BucoRecord>>(
        future: future,
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (items.isEmpty) return const Center(child: Text('Nessun buco salvato'));
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = items[i];
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 7)]),
                child: Row(children: [
                  ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)), child: r.photos.isEmpty ? Container(width: 108, height: 108, color: Colors.grey.shade300, child: const Icon(Icons.image, size: 42)) : Image.file(File(r.photos.first), width: 108, height: 108, fit: BoxFit.cover)),
                  Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(r.description.isEmpty ? 'Nessuna descrizione' : r.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(r.latitude == null ? 'Posizione non rilevata' : 'Lat ${r.latitude!.toStringAsFixed(5)} - Lng ${r.longitude!.toStringAsFixed(5)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    Text(DateFormat('dd MMM yyyy - HH:mm', 'it_IT').format(r.createdAt), style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ]))),
                  Column(children: [IconButton(onPressed: () async { await openEditor(context, record: r); setState(reload); }, icon: const Icon(Icons.edit)), IconButton(onPressed: () => delete(r), icon: const Icon(Icons.delete_outline, color: Colors.red))]),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
