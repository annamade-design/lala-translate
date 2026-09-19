# Known limitations

- macOS 15 or later is required. The planned prebuilt public Beta initially targets Apple Silicon.
- Apps expose selected text through Accessibility differently. Lala Translate uses a Clipboard fallback when Accessibility cannot read the selection during an explicit translation action; some selections may still be unavailable.
- The current development build uses ad-hoc signing, without Developer ID signing or Apple notarization. Gatekeeper may require manual approval in System Settings → Privacy & Security.
- Rebuilding an ad-hoc signed app can change its code identity and require Accessibility permission to be granted again.
- Translation does not start automatically when text is selected. Use Option + T or the menu bar action.
- Language routing defaults to Chinese ↔ English use cases: Chinese goes to English, while English and other recognized languages go to Simplified Chinese. There is no free selection of arbitrary language pairs.
