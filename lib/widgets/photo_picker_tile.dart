import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerTile extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const PhotoPickerTile({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scatta foto'),
                onTap: () {
                  Navigator.pop(context);
                  onCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Scegli da galleria'),
                onTap: () {
                  Navigator.pop(context);
                  onGallery();
                },
              ),
            ],
          ),
        ),
      ),
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 28, color: cs.onSurface),
            const SizedBox(height: 4),
            Text(
              'Aggiungi\nfoto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper centralizzato per scegliere immagini.
class PhotoPickerHelper {
  static Future<XFile?> pick(ImageSource source) async {
    final picker = ImagePicker();
    return picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
  }
}
