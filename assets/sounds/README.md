# Audio Assets

Replace placeholder text files (now removed) with real audio files in this structure:

```
assets/sounds/<species>/<action>.mp3
```

Species folders (already created):
- dog
- cat
- bird
- rabbit
- lion
- giraffe
- penguin
- panda

Recommended action filenames per species (add as available):
- happy.mp3
- sad.mp3
- play.mp3
- sleep.mp3
- eat.mp3
- idle.mp3
- lick.mp3 (where applicable)
- clean.mp3 (if you want a grooming sound)

The code falls back gracefully: if an asset is missing it will play a silent embedded mp3 to avoid runtime errors.

After adding new files, run:
```
flutter pub get
```
(Usually not required unless you add new folders) and then rebuild the app.

Ensure you respect licensing for any third‑party sound effects.
