# Data Storage and File Management

## 1. Local Storage

### a. File Storage
- **Where:**
  - Store files in the app’s sandboxed storage for security and privacy.
  - On desktop, use user-specific directories with restricted permissions.
- **How:**
  - Files are saved in their original format (PDF, image, etc.).
  - Use a consistent directory structure (e.g., by collection, date, or tag).
- **Encryption:**
  - All files should be encrypted at rest using a strong algorithm (e.g., AES-256).

### b. Metadata Storage
- **Database:**
  - Use a local database (e.g., SQLite, Realm, Isar) to store metadata: title, date, tags, notes, file path, etc.
  - The database itself should be encrypted.
- **Linking:**
  - Each file entry in the database links to its physical file location.

## 2. Importing Files
- **Sources:**
  - File picker (all platforms)
  - Drag-and-drop (desktop)
  - Camera/photo library (mobile)
  - Email or cloud integration (future improvement)
- **Supported Types:**
  - PDFs, images (JPG, PNG, etc.), text files, and potentially others.
- **Validation:**
  - Check file type and size limits.
  - Scan for malware (optional, advanced).

## 3. Viewing and Exporting Files
- **In-App Viewing:**
  - Use built-in viewers for common formats (PDF, images).
  - For unsupported types, allow opening with external apps.
- **Exporting:**
  - Allow users to copy files out of the app to the filesystem.
  - Optionally, export with or without metadata.

## 4. Organizing Files
- **Collections:**
  - Files can be grouped into collections (e.g., by treatment or event).
- **Nested Collections:**
  - Support for collections of collections (e.g., “Diabetes” > “2025-03-12”).
- **Tagging:**
  - Allow multiple tags per file for flexible organization.

## 5. Cloud Sync/Backup (Not for MVP)
- **Approach:**
  - Optional encrypted cloud backup/sync for files and metadata.
  - User must opt-in; all data encrypted before upload.
- **Providers:**
  - Use a cloud storage provider (e.g., Firebase, AWS S3, custom server).
- **Conflict Resolution:**
  - Handle file and metadata conflicts gracefully (e.g., last-write-wins, user prompt).

## 6. Deletion and Recovery
- **Soft Delete:**
  - Move files to a “trash” before permanent deletion.
- **Recovery:**
  - Allow users to restore accidentally deleted files/collections.

## 7. Scalability
- **Performance:**
  - Lazy load file lists and previews.
  - Paginate or virtualize large collections.
- **Storage Limits:**
  - Warn users as they approach device or app storage limits.

---

## Open Questions
- Which local database to use (SQLite, Realm, Isar, etc.)?
- How will we structure the file directory for organization and security?
- What encryption library/approach will we use for files and metadata?
- What is the maximum file size and supported file types?
- How will we handle file name conflicts and duplicates?
- Will we support any file preview/thumbnail generation for non-image files?

---
*Update this file as decisions are made or requirements change.* 

## Database Evaluation and Recommendation

### Requirements
- Web support is not required for the MVP, but would be nice to have in the future.
- No preference between relational (SQL) and object-oriented models.
- The solution must be open-source and free.

### Evaluation
- **SQLite**: Ubiquitous, open-source, free, cross-platform, supports encryption (with extensions), and has many libraries for both Flutter and React Native. Web support possible via WASM, but not required for MVP.
- **Isar**: Open-source, free, high performance, object-oriented, designed for Flutter/Dart, easy to use and migrate, built-in encryption. Web support is possible, but primary focus is on Flutter/Dart.
- **Realm**: Object-oriented, good performance, built-in encryption, but core is closed-source and some features require a paid plan.
- **Other options** (Hive, WatermelonDB, Core Data) are either less feature-rich, not as cross-platform, or not as mature.

### Recommendation
- **SQLite** (with an ORM/wrapper like Drift or Moor for Flutter, or WatermelonDB for React Native) is the most robust, open-source, and portable choice for the MVP and future expansion.
- **Isar** is a strong alternative if the app is built with Flutter/Dart and you want a modern, object-oriented API with easy encryption and migrations.

---
*Decision: Use SQLite as the default local database for the MVP, with Isar as a potential alternative if the project is Flutter/Dart only and object-oriented storage is preferred.* 

## Directory Structure for Organization and Security

### Decisions
- **App Sandbox/Private Storage:**
  - On mobile, store all files within the app’s private/sandboxed directory (not accessible to other apps).
  - On desktop, use a user-specific application data directory (e.g., `~/Library/Application Support/AppName` on macOS, `%APPDATA%\AppName` on Windows) with restricted permissions.
- **Organizational Structure:**
  - All user files are stored under a single root directory managed by the app.
  - Each collection is a subfolder; nested collections are represented as nested folders (e.g., `Diabetes/2025-03-12/`).
  - Files are stored within their respective collection folders.
- **Security Considerations:**
  - Encryption:
    All files are encrypted before being written to disk, even within the sandbox.
- **File Naming and Conflicts:**
  - File names are obfuscated (UUIDs or hashes) for privacy, with real names stored in the encrypted database. In the app UI, always display the real (user-supplied) names. For export/import, optionally restore real names for user convenience.
  - User-supplied names are sanitized to avoid illegal characters.
  - If a file with the same name exists, append a timestamp or unique ID to ensure uniqueness.
- **Access Control:**
  - On desktop, set directory permissions to user-only.
  - On mobile, rely on OS sandboxing for access control.
- **Backup and Portability:**
  - Allow users to export collections or the entire directory structure as a zip file, with or without encryption.
  - Support importing a previously exported structure.

**Example Structure:**
```
/AppDataRoot/
  /Diabetes/
    /2025-03-12/
      <uuid1>.pdf
      <uuid2>.jpg
    /2025-03-19/
      <uuid3>.pdf
  /Boil 2025-03-24/
    <uuid4>.jpg
    <uuid5>.pdf
```

---
*Update this section as directory structure or security decisions evolve.* 

## Directory Structure Customization

### Decision
- The app will use a fixed directory structure based on collections and nested collections for the MVP.
- Flexibility will be provided through tagging, metadata, and smart collections/search, rather than raw folder customization.

### Rationale
- Simpler for users and developers, reducing confusion and risk of misorganization.
- Ensures consistency, security, and easier support/maintenance.
- Aligns with industry practice for consumer-facing apps.

### Future Consideration
- Limited customization (e.g., custom collection names, reordering, or virtual folders) may be considered in future versions if user demand is high.

---
*Decision: Use a fixed directory structure for the MVP; revisit customization options based on user feedback.* 

## Handling Large Collections

### Decision
- For individual collections, no special handling for large numbers of files is required for the MVP, as it is unlikely any collection will exceed 100 files.
- For the root level (collections list), implement UI virtualization or pagination if the number of collections becomes large.
- Ensure the database is indexed for fast retrieval of collections.
- Advanced handling (e.g., subfolder partitioning, further virtualization) will only be considered if performance issues are observed or user feedback indicates a need.

### Rationale
- Based on expected usage, most collections will have far fewer than 100 files.
- The root level is the only area likely to have a large number of items, so optimization efforts should focus there if needed.
- This approach keeps the implementation simple and focused, while allowing for future optimization if real-world needs arise.

---
*Decision: Optimize for simplicity; only implement advanced handling for large collections where necessary or trivial.* 

## Handling File Name Conflicts and Duplicates

### File Name Conflicts
- If a user adds a file with the same name as an existing file in the same collection, automatically append a unique suffix (e.g., timestamp, incremental number, or short hash) to the new file’s display name.
  - Example: `scan.pdf`, `scan (1).pdf`, `scan (2025-06-01 14-32-10).pdf`
- Notify the user that the file name was changed to avoid confusion.
- On disk, all files are stored with obfuscated names (UUIDs/hashes), so conflicts only matter for display names in the app/database.

### Duplicate File Detection
- For the MVP, do not block or warn about duplicate content (e.g., same file uploaded twice with different names).
- In future versions, consider detecting duplicates by comparing file hashes (e.g., SHA-256) and warning the user or offering to skip/merge.

### User Experience
- Always show the user-supplied (or auto-renamed) name in the app.
- Allow users to rename files within the app, with the same conflict resolution logic applied.
- When exporting, use the display name, ensuring no conflicts in the exported folder (apply the same renaming logic if needed).

### Rationale
- Auto-renaming avoids accidental overwrites and confusion.
- Notifying the user maintains transparency.
- Deferring duplicate content detection keeps the MVP simple, with room for future enhancement.

---
*Decision: Auto-rename files on name conflict, notify the user, and do not detect duplicate content for the MVP.* 

## Encryption, PIN/Biometric Login, and Key Recovery/Reset

### Approach
- **Encryption:**
  - Use AES-256-GCM for file and database encryption.
  - Encryption keys are derived from a user-set PIN and a recovery phrase.
- **PIN Requirement:**
  - Users must set a PIN during setup.
- **Biometric Login:**
  - Users can enable biometrics (Face ID, Touch ID, Android Biometrics) for convenience, but not as a sole recovery method.
- **Key Recovery/Reset:**
  - On setup, generate and display a random recovery phrase (e.g., 12–24 words) for the user to write down securely.
  - The recovery phrase is used to derive the master encryption key.
  - If the user forgets their PIN, they can reset it by entering the recovery phrase.
  - PIN can be changed/reset with the recovery phrase, but not the other way around.

### Recommended Flow
1. **On Setup:**
   - User sets a PIN (required).
   - User is shown a recovery phrase and instructed to write it down securely.
   - Optionally, user enables biometrics for convenience.
2. **On Unlock:**
   - User enters PIN or uses biometrics (if enabled).
3. **On PIN Reset:**
   - User selects “Forgot PIN?”
   - User is prompted to enter the recovery phrase.
   - If correct, user can set a new PIN.

### Security Notes
- Never store the recovery phrase or master key in plain text.
- Make it clear to users: if they lose the recovery phrase, their data cannot be recovered.
- Biometrics are for convenience only, not for recovery.
- Optionally, allow users to regenerate a new recovery phrase (with a warning that old backups become invalid).

---
*Decision: Require a PIN, allow biometric login for convenience, and use a recovery phrase for secure key recovery/reset.* 

## Supported File Types and Maximum File Size

### File Type Policy
- **Uploading:**
  - Allow uploading of any file type that is not potentially dangerous (e.g., executables, scripts, system files).
  - This ensures users can upload rare or unforeseen medical file types (e.g., specialized imaging formats).
- **Blocked Types:**
  - Block executables (.exe, .bat, .sh, .app, etc.), scripts (.js, .py, .rb, etc.), and other known dangerous types.
  - Optionally, block files with double extensions (e.g., .pdf.exe).
- **Viewing/Previewing:**
  - Support in-app viewing for PDF, images (jpg, png, bmp, gif, tiff, heic), text (txt, rtf), and common office documents (doc, docx, xls, xlsx, ppt, pptx).
  - For other file types, allow upload and storage, but require export or opening with an external app for viewing.

### Maximum File Size
- **Default Maximum:** 100 MB per file for the MVP (configurable in future versions).
- **Minimum File Size:** No minimum, but warn if a file is empty or suspiciously small.

### User Experience
- Show clear error messages if a file is unsupported or too large.
- Indicate which files are viewable in-app and which require export/external app.
- Warn or block if a user attempts to upload a dangerous file type.

### Rationale
- Allows flexibility for users to store any relevant medical file, including rare or unforeseen types.
- Maintains security by blocking potentially dangerous files.
- Ensures a good user experience by previewing common formats and providing clear feedback for others.

---
*Decision: Allow uploading of any non-dangerous file type, block executables/scripts, support in-app viewing for common formats, and require export/external app for others. Set a 100 MB per file size limit for the MVP.* 

## File Preview/Thumbnail Generation for Non-Image Files

### Approach
- **Images:** Show real thumbnails in lists and grids.
- **PDFs:** Generate and show a thumbnail of the first page.
- **Text files:** Show a snippet (first few lines) and a generic text file icon.
- **Office documents, DICOM, and other specialized types:** Use generic icons only for the MVP.
- **Unknown file types:** Use a generic file icon, no preview.

### User Experience
- Always show a thumbnail or icon in file lists for quick identification.
- For supported types (images, PDFs), show a real preview/thumbnail.
- For unsupported types, use a clear, descriptive icon and optionally a snippet (for text).

### Rationale
- Provides a visually informative and user-friendly experience for common file types.
- Keeps the MVP simple and performant by limiting real previews to images and PDFs.
- Allows for future expansion to support more file types as needed.

### Future Considerations
- Add real previews for more file types based on user demand and available libraries.
- Consider user settings to enable/disable thumbnail generation for privacy or performance.

---
*Decision: For the MVP, generate real thumbnails for images and PDFs, show snippets for text files, and use generic icons for other file types.* 