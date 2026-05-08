# Buco - Flutter App

App Android Flutter per salvare buche/posizioni con GPS, foto e note.

## Funzioni
- Home moderna grigia
- Nuovo buco con rilevamento posizione GPS
- Descrizione testuale
- Foto multiple dalla fotocamera o galleria
- Database locale SQLite
- Elenco buchi salvati
- Modifica e cancellazione

## Come compilare APK
Da terminale:

```bash
flutter create .
flutter pub get
flutter build apk --release
```

APK generato in:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Permessi Android
L'app usa:
- posizione GPS
- fotocamera
- lettura immagini
