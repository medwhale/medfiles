<!-- abbe7141-8de3-4814-ba34-5cfeab9fcedd cf41742a-675f-49f9-90df-82b58f9a5983 -->

# MedFiles Android MVP Development Plan

## GOAL DEFINITION

**GOAL**: Build a secure, privacy-focused Android mobile application for organizing and managing medical files with end-to-end encryption, enabling users to import, organize, search, and backup sensitive medical documents locally on their device.

**SCOPE**:

- Android mobile application (API 29+)
- Local-only storage (no cloud services in MVP)
- Single-level collections for file organization
- File-level AES-256-GCM encryption
- PIN and biometric authentication (session gating)
- Hardware-backed Keystore–wrapped master key (no mnemonic recovery)

**REQUIREMENTS**:

Functional:

- Import any non-dangerous file type (max 100MB)
- Organize files in single-level collections
- View previews for images, PDFs, and text files
- Add metadata (title, date, tags) to files
- Search and filter files by name, tags, date, type
- Soft delete with trash/recovery system
- Local encrypted backup and restore (separate backup password)
- Material Design 3 UI with light/dark themes

Non-Functional:

- File-level encryption using AES-256-GCM
- PIN (6-digit) authentication required
- Biometric authentication optional
- Hardware-backed Android Keystore protection for master key
- Auto-lock after 5 minutes (configurable)
- WCAG 2.1 AA accessibility compliance
- Support hundreds of files per collection efficiently

**CONSTRAINTS**:

- Solo developer implementation
- Android only for MVP (iOS/desktop post-MVP)
- No cloud services or backend
- Open-source dependencies only
- No third-party analytics or tracking

**SUCCESS CRITERIA**:

- User can complete full file import → organize → search → backup cycle
- All security features work correctly (encryption, authentication, backup password)
- App remains responsive with 200+ files
- All unit, integration, and widget tests pass
- Release build successfully signs and runs on physical devices
- Accessibility features verified with TalkBack

**RISKS IDENTIFIED**:

1. **Encryption Performance**: File-level encryption may impact performance with large files

   - Mitigation: Use hardware acceleration, background processing, chunked operations

2. **SQLCipher Compatibility**: Database encryption may have Android version issues

   - Mitigation: Test on multiple Android versions early, have fallback strategy

3. **Memory Management**: Large files and thumbnails could cause memory issues

   - Mitigation: LRU caching, lazy loading, memory profiling

4. **ProGuard/R8 Issues**: Code obfuscation may break encryption libraries

   - Mitigation: Configure keep rules early, test release builds frequently

5. **Keystore Availability**: Some devices lack StrongBox or have edge-case failures

   - Mitigation: Detect capabilities; fall back to non-StrongBox Keystore; provide rewrap path

**IMPLEMENTATION APPROACH**:

- Bottom-up: Core infrastructure (encryption, database) → Authentication → File management → UI
- Test-driven: Write tests alongside implementation for each component
- Incremental: Small, testable changes with frequent validation
- Security-first: Encryption and authentication established before UI
- Sequential phases: Complete one phase entirely before advancing

---

## PROGRESS TRACKER

### Current Status

| Attribute         | Value       |
| ----------------- | ----------- |
| **Current Phase** | Not Started |
| **Current Step**  | N/A         |
| **Last Updated**  | TBD         |

### Phase Completion Status

- [ ] **PHASE 0**: Project Setup & Configuration (Confidence: 95%)
- [ ] **PHASE 1**: Core Infrastructure (Confidence: 81%)
- [ ] **PHASE 2**: Authentication & Security (Confidence: 73%)
- [ ] **PHASE 3**: File Management (Confidence: 66%)
- [ ] **PHASE 4**: UI Implementation (Confidence: 64%)
- [ ] **PHASE 5**: Data Management (Confidence: 73%)
- [ ] **PHASE 6**: Theming & Accessibility (Confidence: 81%)
- [ ] **PHASE 7**: Release Preparation (Confidence: 73%)

### Implementation Notes

```
[Phase.Step] - [Note]

Add notes about issues encountered, decisions made, or deviations from plan
```

---

## PRE-IMPLEMENTATION BASELINE REQUIREMENTS

**MANDATORY BEFORE STARTING ANY PHASE**:

- ✅ Code must compile successfully
- ✅ All existing tests must pass
- ✅ Codebase must be in stable, working state
- ✅ Commit all uncommitted changes (creates rollback point)
- ✅ Document baseline status

**After completing each phase**: Commit changes with descriptive message before advancing to next phase.

---

## VALIDATION STRATEGY

### Step Validation Criteria

**Early Phases (Setup, Infrastructure)**:

- Flutter project builds without errors
- Dependencies resolve successfully
- Basic tests pass (if tests exist)
- Configuration files are syntactically valid

**Middle Phases (Implementation)**:

- All new unit tests pass
- Integration tests pass for completed workflows
- Code analysis shows no critical issues
- Manual smoke testing of new features

**Final Phases (Release)**:

- Complete test suite passes (unit + integration + widget)
- Release build compiles and runs
- All security features verified
- Performance benchmarks met

### Auto-Fix Strategy

- **Scope**: Up to 10 automatic fix attempts for common issues
- **Eligible**: Missing imports, namespace updates, path corrections, version alignments
- **Not Eligible**: Business logic changes, security modifications, architectural decisions
- **Escalation**: Complex issues require developer decision

---

## SEQUENTIAL EXECUTION RULES

**CRITICAL**:

- **ONE PHASE AT A TIME** - Complete all steps in current phase before advancing
- **ONE STEP AT A TIME** - Finish each step fully before starting next
- **NO PARALLEL WORK** - Sequential execution mandatory
- **VALIDATION GATES** - Only advance after validation passes
- **CONFIDENCE CHECKS** - If confidence < 90%, inform developer and request guidance

---

## PHASE 0: Project Setup & Configuration

**Phase Confidence: 95%** (0.95 × 0.95 × 0.95 × 0.95 × 0.95 = 77%)

### Step 0.1: GitHub Repository Setup (Confidence: 95%)

- Create GitHub repository named `medfiles`
- Initialize with README.md (project overview)
- Add .gitignore (Flutter template)
- Add LICENSE file (MIT or Apache 2.0)
- Create initial commit
- **Validation**: Repository accessible, all files present

### Step 0.2: CI/CD & Dependency Management (Confidence: 95%)

- Create `.github/workflows/flutter-ci.yml`
  - Trigger on push and pull requests
  - Build Android APK
  - Run all tests (unit, integration, widget)
  - Run `flutter analyze` for code quality
- Create `.github/dependabot.yml`
  - Monitor pubspec.yaml weekly
  - Auto-create PRs for updates
- **Validation**: CI workflow runs successfully, Dependabot configured

### Step 0.3: Initialize Flutter Project (Confidence: 95%)

- Run `flutter create medfiles`
- Configure for Android API 29+ in `build.gradle`
- Update `pubspec.yaml` with app metadata
- Set up Material Design 3 theme in `main.dart`
- Push to GitHub
- **Validation**: Project builds, runs on emulator/device

### Step 0.4: Dependencies Setup (Confidence: 95%)

Add to `pubspec.yaml`:

- `sqflite: ^2.4.2` and `sqflite_sqlcipher: ^3.4.0`
- `path_provider: ^2.1.5`
- `cryptography: ^2.7.0`
- `flutter_secure_storage: ^9.2.4`
- `local_auth: ^3.0.0`
- `file_picker: ^10.3.3`
- `path: ^1.9.1`
- `uuid: ^4.5.1`
- `image: ^4.5.4`
- `pdfrx: ^2.2.3`
- `provider: ^6.1.5+1` (or `riverpod` if preferred)
- Run `flutter pub get`
- **Validation**: All dependencies resolve, no conflicts

### Step 0.5: Project Structure Creation (Confidence: 95%)

Create folder structure:

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── utils/
│   └── theme/
├── data/
│   ├── models/
│   ├── database/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── services/
    ├── encryption/
    ├── auth/
    ├── file_manager/
    └── backup/
```

- **Validation**: All directories exist, project still builds

---

## PHASE 1: Core Infrastructure

**Phase Confidence: 81%** (0.90 × 0.90 × 0.90 = 73%)

### Step 1.1: Encryption Service Implementation (Confidence: 90%)

Create `lib/services/encryption/encryption_service.dart`:

- AES-256-GCM encryption/decryption methods
- Random 256-bit master Data Encryption Key (DEK)
- Wrap/unwrap DEK using Android Keystore hardware-backed key (auth-bound)
- Individual file key generation (random 256-bit keys)
- Integration with flutter_secure_storage for storing wrapped DEK
- **Validation**: Service instantiates, methods callable

### Step 1.2: Encryption Service Tests (Confidence: 90%)

Create `test/services/encryption/encryption_service_test.dart`:

- Test key generation produces valid keys
- Test encryption/decryption round-trip
- Test DEK wrap/unwrap via Keystore abstraction
- Test invalid inputs handled gracefully
- **Validation**: All tests pass

### Step 1.3: Database Schema & Repository (Confidence: 90%)

Create `lib/data/database/app_database.dart`:

- SQLite database with SQLCipher encryption
- Tables: users, collections, files, file_keys
- CRUD methods for each table
- Create `lib/data/repositories/` for each entity
- **Validation**: Database creates, tables exist

### Step 1.4: Database Tests (Confidence: 90%)

Create `test/data/database/` test files:

- Test database creation and migration
- Test CRUD operations for each table
- Test encryption at database level
- Test repository methods
- **Validation**: All database tests pass

### Step 1.5: File Manager Service (Confidence: 90%)

Create `lib/services/file_manager/file_manager_service.dart`:

- File import with validation (block .exe, .bat, .sh, .app, .js, .py, .rb)
- UUID generation for file obfuscation
- Directory creation: `/AppDataRoot/{collection_uuid}/{file_uuid}.ext`
- File encryption on import
- File decryption on read
- Max 100MB size validation
- **Validation**: Service methods callable

### Step 1.6: File Manager Tests (Confidence: 90%)

Create `test/services/file_manager/` test files:

- Unit tests: File validation, UUID generation, size checks
- Integration tests: Import → encrypt → store → decrypt → read cycle
- Test dangerous file types blocked
- Test large file handling
- **Validation**: All file manager tests pass

---

## PHASE 2: Authentication & Security

**Phase Confidence: 73%** (0.90 × 0.85 × 0.85 × 0.90 = 58%)

### Step 2.1: Onboarding Screens (Confidence: 90%)

Create `lib/presentation/screens/onboarding/`:

- Welcome screen
- PIN creation screen (6-digit with confirmation)
- Biometric opt-in screen
- **Validation**: Navigation flows work, screens display

### Step 2.2: Onboarding Logic & Tests (Confidence: 85%)

Create `lib/services/auth/onboarding_service.dart`:

- PIN validation (6 digits, confirmation match)
- Unit tests for validation logic
- Widget tests for each screen
- **Validation**: All onboarding tests pass

### Step 2.3: Authentication Service (Confidence: 85%)

Create `lib/services/auth/auth_service.dart`:

- PIN entry and validation
- Biometric authentication integration (local_auth)
- Auth state management (locked/unlocked)
- Session management
- **Validation**: Service methods work

### Step 2.4: Auto-Lock Implementation & Tests (Confidence: 90%)

Extend auth service:

- Auto-lock timer (default 5 min, configurable)
- Background/sleep triggers
- "Lock Now" manual function
- (No mnemonic recovery)
- Unit tests for auto-lock logic
- Widget tests for PIN entry, biometric prompt
- Integration tests for full auth flow
- **Validation**: All auth tests pass, timer works

---

## PHASE 3: File Management

**Phase Confidence: 66%** (0.85 × 0.80 × 0.85 = 58%)

### Step 3.1: Collection Management (Confidence: 85%)

Create `lib/data/repositories/collection_repository.dart`:

- Create collection (name, optional date)
- List collections with file counts
- Update collection
- Soft delete collection (mark deleted, move to trash)
- Collection search/filter
- Unit tests for repository
- Widget tests for collection UI
- **Validation**: Collection operations work, tests pass

### Step 3.2: File Operations (Confidence: 80%)

Create `lib/services/file_manager/file_operations_service.dart`:

- Import from file picker
- Import from camera (images only)
- File type detection
- Display file list (virtualized)
- File preview (images, PDF, text)
- Metadata editing (title, date, tags)
- Soft delete file
- Export file (decrypt, save to user location)
- Unit tests for operations
- Widget tests for file list, metadata editor
- Integration tests for import → display → export
- **Validation**: All file operations work, tests pass

### Step 3.3: Thumbnail Generation (Confidence: 85%)

Create `lib/services/file_manager/thumbnail_service.dart`:

- Background image thumbnail generation
- PDF first page thumbnail extraction
- Encrypted disk cache for thumbnails
- LRU memory cache (50-100MB)
- Cache invalidation on file changes
- Unit tests for generation and caching
- Integration tests for async loading
- **Validation**: Thumbnails generate, cache works, tests pass

---

## PHASE 4: UI Implementation

**Phase Confidence: 64%** (0.85 × 0.80 × 0.80 × 0.80 × 0.85 = 37%)

### Step 4.1: Main Navigation (Confidence: 85%)

Create `lib/presentation/navigation/`:

- Bottom navigation bar
- Routes: Home/Collections, Search, Settings, Trash
- Navigation state management
- Widget tests for navigation flows
- **Validation**: Navigation works, tests pass

### Step 4.2: Collections Screen (Confidence: 80%)

Create `lib/presentation/screens/collections/`:

- Grid/list view toggle
- Collection cards (name, date, file count, thumbnails)
- Create collection FAB
- Pull-to-refresh
- Empty state
- Widget tests for UI elements
- **Validation**: Screen displays, interactions work, tests pass

### Step 4.3: Collection Detail Screen (Confidence: 80%)

Create `lib/presentation/screens/collection_detail/`:

- Virtualized file list
- File cards (thumbnail, name, date, size)
- Add files FAB
- Sort/filter options (date, name, type)
- Batch selection mode
- Widget tests for list, sort/filter, batch operations
- **Validation**: Screen works, tests pass

### Step 4.4: File Preview Screen (Confidence: 80%)

Create `lib/presentation/screens/file_preview/`:

- Full file preview (type-specific)
- Metadata display and editing
- Tags management
- Export/delete options
- Widget tests for preview, forms
- **Validation**: Previews work, metadata edits save, tests pass

### Step 4.5: Settings Screen (Confidence: 85%)

Create `lib/presentation/screens/settings/`:

- Auto-lock timeout selector
- Theme selector (Light/Dark/System)
- Biometric toggle
- Change PIN flow
- (Remove mnemonic items)
- Storage usage display
- Clear cache button
- About/licenses
- Widget tests for forms, PIN change
- **Validation**: All settings work, tests pass

---

## PHASE 5: Data Management

**Phase Confidence: 73%** (0.85 × 0.85 × 0.85 = 61%)

### Step 5.1: Trash System (Confidence: 85%)

Create `lib/services/file_manager/trash_service.dart`:

- Soft delete implementation (mark deleted, keep data)
- Trash view screen
- Restore from trash
- Empty trash (permanent delete with key removal)
- 30-day auto-cleanup background task
- Unit tests for soft delete, auto-cleanup
- Widget tests for trash view, restore
- Integration tests for delete → restore flow
- **Validation**: Trash operations work, tests pass

### Step 5.2: Backup & Restore (Confidence: 85%)

Create `lib/services/backup/backup_service.dart`:

- Create encrypted ZIP backup (AES-256-GCM)
- Include encrypted files + database export
- Ask user for a separate backup password; derive key (Argon2id/PBKDF2-strong)
- Save to user-selected location
- Restore from backup (with backup password)
- Integrity validation (checksum)
- Unit tests for backup creation, restore, validation
- Integration tests for full backup → restore cycle
- **Validation**: Backup/restore works, tests pass

### Step 5.3: Search & Filter (Confidence: 85%)

Create `lib/services/search/search_service.dart`:

- Search by name, tags, date
- Filter by file type, collection
- Search result screen with highlights
- Unit tests for search algorithms, filter logic
- Widget tests for search UI, results
- **Validation**: Search/filter works, tests pass

---

## PHASE 6: Theming & Accessibility

**Phase Confidence: 81%** (0.90 × 0.90 = 81%)

### Step 6.1: Material Design 3 Themes (Confidence: 90%)

Create `lib/core/theme/`:

- Light theme: professional blues (#0066CC), grays (#F5F5F5, #424242), whites
- Dark theme: deep blues (#1A1A2E), soft grays (#2D2D3A, #E0E0E0)
- System theme detection
- Theme switcher
- Consistent typography (Roboto)
- Widget tests for theme switching, colors
- **Validation**: Themes display correctly, tests pass

### Step 6.2: Accessibility Features (Confidence: 90%)

Enhance all screens:

- Semantic labels for screen readers
- Minimum 48dp touch targets
- High contrast support
- Font scaling (up to 200%)
- Keyboard navigation
- Widget tests for accessibility annotations, sizes
- Manual testing with TalkBack
- **Validation**: Accessibility tests pass, TalkBack navigation works

---

## PHASE 7: Release Preparation

**Phase Confidence: 73%** (0.85 × 0.85 × 0.85 × 0.90 = 56%)

### Step 7.1: Performance Optimization (Confidence: 85%)

- Profile encryption/decryption with Flutter DevTools
- Optimize thumbnail generation
- Test with 200+ files
- Memory leak detection
- Fix performance bottlenecks
- **Validation**: App responsive with 200+ files, no memory leaks

### Step 7.2: Android Configuration (Confidence: 85%)

Configure `android/app/`:

- Add permissions: CAMERA, WRITE_EXTERNAL_STORAGE, USE_BIOMETRIC
- Create ProGuard/R8 rules for cryptography libraries
- Configure secure storage for release
- Set up signing keystore
- **Validation**: Release build compiles

### Step 7.3: Release Build & Testing (Confidence: 85%)

- Generate signed APK/AAB
- Test on multiple physical devices (different Android versions)
- Verify all security features in release mode
- Verify ProGuard doesn't break functionality
- Test backup/restore on real devices
- **Validation**: Release build works correctly

### Step 7.4: Documentation (Confidence: 90%)

Create:

- README.md with setup instructions
- docs/architecture.md with design decisions
- Privacy policy for Play Store
- docs/user-guide.md for basic operations
- CONTRIBUTING.md guidelines
- **Validation**: All docs complete and accurate

---

## MVP Feature Checklist

- [ ] PIN authentication with biometric option
- [ ] Keystore-wrapped master key
- [ ] File-level AES-256-GCM encryption
- [ ] Single-level collections
- [ ] File import (any non-dangerous type, 100MB limit)
- [ ] File preview (images, PDF, text)
- [ ] Thumbnail generation (images, PDF)
- [ ] File metadata (title, date, tags)
- [ ] Search and filter
- [ ] Trash/soft delete with 30-day retention
- [ ] Local encrypted backup/restore (separate backup password)
- [ ] Material Design 3 UI
- [ ] Light/Dark/System theme
- [ ] Auto-lock (5 min configurable)
- [ ] Accessibility support

---

## Post-MVP Enhancements

- Nested collections support
- Advanced file viewers
- OCR for scanned documents
- Cloud backup/sync
- Multi-user support
- iOS/macOS/Windows support

### To-dos

- [ ] Initialize Flutter project with Material Design 3 and configure dependencies
- [ ] Implement AES-256-GCM encryption service with DEK and Keystore wrap/unwrap
- [ ] Create encrypted SQLite database with schema for users, collections, files, and keys
- [ ] Build file manager service for import, encryption, storage, and access
- [ ] Create onboarding flow with PIN creation and biometric opt-in (no recovery phrase)
- [ ] Implement authentication with PIN, biometric, and auto-lock (no mnemonic recovery)
- [ ] Build collection CRUD operations and UI
- [ ] Implement file import, preview, metadata editing, and export
- [ ] Create thumbnail generation and caching for images and PDFs
- [ ] Build main navigation structure with Material Design 3
- [ ] Implement collections, detail, preview, and settings screens
- [ ] Build trash system with soft delete, restore, and auto-cleanup
- [ ] Implement encrypted local backup and restore functionality (backup password)
- [ ] Add search and filter functionality for files and collections
- [ ] Implement light/dark themes with medical color palette
- [ ] Add accessibility features (screen reader, touch targets, contrast)
- [ ] Write unit, integration, and widget tests for core functionality
- [ ] Optimize performance, configure Android build, and create release build
