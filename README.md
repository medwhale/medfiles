# MedFiles (Android MVP)

Secure, local-first medical file organizer. Android MVP built with Flutter and Material Design 3.

## Key Features (MVP)

- PIN + biometric authentication
- File-level AES-256-GCM encryption
- Single-level collections
- Import any non-dangerous file type (<=100MB)
- Previews for images, PDFs, text (using pdfrx for PDFs)
- Soft delete (Trash) and encrypted local backup/restore
- Light/Dark/System theme, accessibility

## Development

- Android min SDK: API 29 (Android 10)
- Flutter stable channel
- CI: GitHub Actions (analyze, test, build)
- Dependency updates: Dependabot

See `design_decisions/` for architecture and security details.
