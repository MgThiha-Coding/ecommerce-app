# PicoMart App Architecture

PicoMart is a Flutter-based e-commerce app supporting English and Myanmar. It features a modular architecture, responsive UI & localizations.

...

```text
lib/
├── core/
│   ├── configs/           # App configuration (stores APP_URL, X_API_TOKEN,)
│   ├── consts/            # Central colors, fonts, and responsive setup
│   ├── images/
│   ├── localizations/
│   ├── network/           # BaseAuthNotifier & RefreshTokenMixin for token management
│   ├── responsive/
│   ├── service/
│   └── storage/
├── features/
│   ├── <feature_name>/
│   │   ├── model/
│   │   │   ├── request/
│   │   │   └── response/
│   │   ├── view/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── viewmodel/
│   │       └── notifier/
├── share/                 # Shared widgets
├── assets/
│   ├── fonts/
│   ├── images/
│   └── translations/      # English & Myanmar supported in-app; other languages present but not implemented
├── main.dart              # App entry point
...
```

## Dependencies

```text
- State management & networking: flutter_riverpod, dio, flutter_secure_storage
- UI & animations: flutter_spinkit, carousel_slider, animations, shimmer, google_fonts, line_icons, badges, dotted_border
- Utilities: flutter_dotenv, device_info_plus, pin_code_fields, permission_handler, path_provider, intl, flutter_image_compress
- Codegen & lint: build_runner, flutter_lints
- Icons: cupertino_icons
...
```

## Notes

```text
- Running with all exceptions enabled may cause crashes (socket patch issues). Run without catching all exceptions for stability.
- Translation assets include multiple languages (German, Spanish, French, Japanese, Dutch, Chinese, Thai) but only English and Myanmar are implemented.
- MVP-ready; some advanced error handling and edge cases are not yet implemented.
...
```

## Developer

```text
Min Thiha Aung
Final deliverable as of November 2025
```
