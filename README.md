# Lala Translate

A lightweight native macOS translation utility powered by Apple's Translation framework.

**Select text → Option + T → Translate.**

No account. No API key. No third-party translation service.

**[Download v0.1.0 Beta](https://github.com/annamade-design/lala-translate/releases/tag/v0.1.0-beta)**

macOS 15+ · Apple Silicon · Beta

> **Beta:** The current prebuilt release is ad-hoc signed and not notarized by Apple. macOS may require manual approval in System Settings → Privacy & Security on first launch.

![Lala Translate preview](docs/assets/lala-translate-preview.png)

## Quick Start

1. Download the latest Beta release.
2. Unzip and move `Lala Translate.app` to `/Applications`.
3. Open the app and grant Accessibility permission.
4. Select text in any supported app.
5. Press **Option + T**.

If Accessibility cannot read the selected text directly, Lala Translate can use its clipboard fallback during an explicit translation action.

## Features

- Global **Option + T** shortcut and a **Translate Selected Text** menu bar action.
- Reads selected text from the active app with macOS Accessibility. If that fails during an explicit translation action, a Clipboard fallback briefly sends Command+C, reads the copied text, and attempts to preserve and restore the original pasteboard items and their types.
- No background clipboard monitoring and no automatic translation on ordinary Command+C.
- v0.1 is optimized for Chinese ↔ English translation: Chinese text translates to English, and English text translates to Simplified Chinese. Latin-script text is treated as English for reliable short-word and short-phrase translation. Other non-Latin languages may still be detected by macOS Natural Language APIs and translated to Simplified Chinese when supported.
- Speak, Copy, and Pin controls in the translation panel; Launch at Login is optional.
- No account, API key, third-party translation API, or saved translation history.

## Requirements

- macOS 15 or later.
- The planned prebuilt Beta release initially targets Apple Silicon. The source uses Swift, SwiftUI, and AppKit.
- **Accessibility permission is required** to read text selected in other apps. After opening Lala Translate, grant it access in System Settings → Privacy & Security → Accessibility.

## Development build and installation

From the project directory:

```sh
./scripts/build.sh
./scripts/check.sh
```

The build script creates `dist/Lala Translate.app` and applies ad-hoc signing for local development. Install that app in `/Applications` and launch the installed copy. If you rebuild it, macOS may require you to grant Accessibility permission again.

The current Beta build has **not** been signed with Developer ID or notarized by Apple. Gatekeeper may require you to allow it manually in System Settings → Privacy & Security before opening it. This is a development/Beta distribution path, not a notarized public release.

The first translation for a language pair may ask you to download Apple's translation languages. See [known limitations](docs/KNOWN_LIMITATIONS.md) for current scope.

## Privacy

Translation uses Apple's Translation framework. Lala Translate does not create user accounts, use Google, DeepL, OpenAI, or other third-party translation APIs, or save selected text and translations to a history store.

It does not read the clipboard in the background. Clipboard fallback runs only when you explicitly invoke **Translate Selected Text** and Accessibility cannot provide the selection. It attempts to restore the pasteboard contents after reading copied text; some app-specific or lazy pasteboard formats may not be fully restorable.

## License

MIT License. Copyright (c) 2026 Anna Cheung. See [LICENSE](LICENSE).
