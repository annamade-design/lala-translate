# Known limitations

- macOS 15 or later is required. The planned prebuilt public Beta initially targets Apple Silicon.
- Apps expose selected text through Accessibility differently. Lala Translate uses a Clipboard fallback when Accessibility cannot read the selection during an explicit translation action; some selections may still be unavailable.
- The current development build uses ad-hoc signing, without Developer ID signing or Apple notarization. Gatekeeper may require manual approval in System Settings → Privacy & Security.
- Rebuilding an ad-hoc signed app can change its code identity and require Accessibility permission to be granted again.
- Translation does not start automatically when text is selected. Use Option + T or the menu bar action.
- v0.1 is optimized for Chinese ↔ English translation. Latin-script text is treated as English, including short words and phrases; other non-Latin languages may still be detected by macOS Natural Language APIs and translated to Simplified Chinese when supported. There is no free selection of arbitrary language pairs.
