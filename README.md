# Lala Translate

**English** | [简体中文](README.zh-CN.md)

A lightweight native macOS translation utility powered by Apple's Translation framework.

**Select text → Option + T → Translate.**

No account. No API key. No third-party translation service.

**[Download v0.1.0 Beta](https://github.com/annamade-design/lala-translate/releases/tag/v0.1.0-beta)**

macOS 15+ · Apple Silicon · Beta

> **Beta:** The current prebuilt release is ad-hoc signed and not notarized by Apple. macOS may require manual approval in System Settings → Privacy & Security on first launch.

![Lala Translate preview](docs/assets/lala-translate-preview.png)

## Quick Start

1. Download the latest Beta release.
2. Unzip `LalaTranslate-v0.1.0-beta-macOS-arm64.zip`.
3. Move `Lala Translate.app` to `/Applications`.
4. Open Lala Translate.
5. Grant Accessibility permission in System Settings → Privacy & Security → Accessibility.
6. Select text in another app.
7. Press **Option + T**.

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
- The current prebuilt Beta targets Apple Silicon (`arm64`). The source uses Swift, SwiftUI, and AppKit.
- **Accessibility permission is required** to read text selected in other apps. After opening Lala Translate, grant it access in System Settings → Privacy & Security → Accessibility.

## If macOS says Apple cannot verify Lala Translate

The current Lala Translate Beta is distributed as a free test build and is not yet signed with an Apple Developer ID or notarized by Apple.

Because of this, macOS may show a warning on first launch saying that Apple cannot verify whether Lala Translate contains malware. This warning means that macOS cannot verify the developer signature and notarization status of this Beta. **It does not mean that macOS has detected malware in Lala Translate.**

If you see this warning:

1. Try opening Lala Translate once.
2. Open **System Settings → Privacy & Security**.
3. Scroll down to the security message for Lala Translate.
4. Click **Open Anyway**.
5. Confirm that you want to open the app.
6. After launch, grant Lala Translate **Accessibility** permission when requested.

You do not need to disable Gatekeeper or run any Terminal security-bypass commands.

## Development build and installation

From the project directory:

```sh
./scripts/build.sh
./scripts/check.sh
```

The build script creates `dist/Lala Translate.app` and applies ad-hoc signing for local development. Install that app in `/Applications` and launch the installed copy. If you rebuild it, macOS may require you to grant Accessibility permission again.

The first translation for a language pair may ask you to download Apple's translation languages. See [known limitations](docs/KNOWN_LIMITATIONS.md) for current scope.

## Privacy

Translation uses Apple's Translation framework. Lala Translate does not create user accounts, use Google, DeepL, OpenAI, or other third-party translation APIs, or save selected text and translations to a history store.

It does not read the clipboard in the background. Clipboard fallback runs only when you explicitly invoke **Translate Selected Text** and Accessibility cannot provide the selection. It attempts to restore the pasteboard contents after reading copied text; some app-specific or lazy pasteboard formats may not be fully restorable.

## License

MIT License. Copyright (c) 2026 Anna Cheung. See [LICENSE](LICENSE).
