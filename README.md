# PicoMart App Architecture

```
lib/
├── core/           # Config, constants, theme, utils
├── features/
│   ├── feature1/
│   │   ├── model/
│   │   ├── view/
│   │   └── viewmodel/
│   └── feature2/
├── main.dart       # App entry point
```

**Notice:**  
- Runs with some uncaught exceptions.  
- MVP ready; some advanced error handling and edge cases are not yet implemented.
