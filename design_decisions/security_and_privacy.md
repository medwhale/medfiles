# Security & Privacy: High-Level Proposal

## 1. Encryption
- **At Rest:**
  - All files and database entries are encrypted using AES-256-GCM or equivalent.
  - Encryption keys are derived from user PIN and recovery phrase, stored securely (see Data Storage & File Management).
- **In Transit (not MVP):**
  - All data transfers (sync, backup, sharing) use TLS/SSL for secure communication.
  - End-to-end encryption for any cloud sync or sharing features.

## 2. Authentication & Access Control
- **User Authentication:**
  - Require PIN for access; support biometrics for convenience.
  - Auto-lock app after configurable period of inactivity.
- **Session Management:**
  - Support for session timeout and manual lock.
  - Consider secure logout and re-authentication flows.
- **Multi-User/Shared Device:**
  - For MVP, single-user only; multi-user support may be considered in future versions.

## 3. Data Privacy
- **Data Minimization:**
  - Only store data necessary for app functionality.
- **User Control:**
  - Users can export, delete, or permanently erase their data at any time.
  - No analytics or tracking of sensitive data by default.
- **Transparency:**
  - Clear privacy policy and user consent for any data processing.

## 4. Regulatory Compliance
- **GDPR, HIPAA, etc.:**
  - Design with privacy by default and by design principles.
  - Provide data access, export, and deletion features to support compliance.
  - Maintain audit logs for critical actions (not for MVP).

## 5. Secure Development Practices
- **Coding Standards:**
  - Follow secure coding guidelines and perform regular code reviews.
- **Dependency Management:**
  - Use well-maintained, open-source libraries; monitor for vulnerabilities.
- **Security Audits:**
  - Plan for periodic security reviews and updates.

## 6. Other Security Features
- **Backup & Restore:**
  - Ensure backups are encrypted and can only be restored by the user.
- **File Sharing (not MVP):**
  - If implemented, use secure, time-limited, and revocable sharing links with end-to-end encryption.
- **Malware Protection:**
  - Block dangerous file types, don't implement scanning for known threats.

## Session Management Decisions

- **Auto-Lock Timeout:**
  - Defaults to 5 minutes of inactivity.
  - User can configure the timeout duration in settings.
- **Manual Lock:**
  - Provide a "Lock Now" option in the UI for immediate locking.
- **Backgrounding/Device Sleep:**
  - When the app is backgrounded or the device sleeps, the auto-lock timer is triggered.
  - If the app remains in the background for the duration of the timeout (e.g., 5 minutes), it locks itself and requires re-authentication on return.

---
*Decision: Auto-lock defaults to 5 minutes (user configurable), "Lock Now" option available, and backgrounding/device sleep triggers the auto-lock timeout.*

---
*Update this file as security and privacy decisions are made or requirements change.* 
*Update this section as these questions are answered or new ones arise.* 

## Regulatory Compliance for Local-Only Apps

### Analysis
- **GDPR:**
  - If all data is stored locally and never leaves the user’s device, the app developer typically does not “process” the data in the legal sense—the user is in control. MUST CHECK THIS!!
  - GDPR applies if the app collects analytics, crash reports, or syncs data to a server/cloud.
- **HIPAA:**
  - Applies to healthcare providers and their business associates. If the app is for personal use and data is not transmitted to a third party, HIPAA generally does not apply.
- **Other Jurisdictions:**
  - Most privacy laws focus on data controllers/processors, not end-user-only local storage.

### Summary Table
| Scenario                        | GDPR/HIPAA Applies? | Best Practice                |
|----------------------------------|---------------------|------------------------------|
| Data stays 100% local           | Usually No          | Clear privacy policy, strong security, user control |
| Data syncs to cloud/server      | Yes                 | Full compliance required     |
| Analytics/telemetry sent        | Yes (GDPR)          | Consent, data minimization   |

### Best Practice Recommendation
- Even for local-only apps, provide a clear privacy policy and inform users that their data never leaves their device.
- Allow users to export and delete their data easily.
- Use strong security and privacy practices, as users expect medical data to be protected.
- If cloud sync, analytics, or any server-side processing is added in the future, revisit compliance requirements.

---
*Conclusion: For local-only apps, regulatory compliance is not strictly required, but strong privacy practices and transparency are still expected.* 

## Data Deletion

### Approach
- **Trash/Undo Period:**
  - When a user deletes a file or collection, move it to a “Trash” or “Recently Deleted” area.
  - Allow users to restore items from Trash within a configurable period (default: 30 days).
  - After the undo period, files and metadata are permanently erased.
  - Users can “Empty Trash” to immediately erase all trashed items.
- **Permanent Erase:**
  - Secure File Deletion:
    - On mobile, secure erase is achieved by deleting the file and its encryption key, not by overwriting file data (due to platform and hardware limitations).
    - On desktop, attempt to securely overwrite file data before deletion if possible; otherwise, rely on encryption and key removal.
  - Remove all associated metadata from the encrypted database.
- **User Experience:**
  - Provide clear warnings before permanent deletion that the action is irreversible.
  - Allow users to delete or restore multiple items at once (bulk actions).
- **Best Practices:**
  - Ensure deleted files are also removed from any backups or exports if possible.
  - Since files are encrypted, deleted files are not easily recoverable, but secure deletion is still best practice.

### Rationale
- Trash/undo period prevents accidental data loss and improves user experience.
- Secure deletion (via encryption key removal) aligns with mobile platform best practices and security models.
- Clear warnings and bulk actions empower users to manage their data confidently.

---
*Decision: Use a Trash/undo period for soft deletes, provide permanent erase with secure deletion (encryption key removal on mobile), and ensure clear user experience and best practices.* 

## Multi-User/Shared Device Support

### MVP Approach
- Support only a single user per device/app installation for the MVP.
- All data, authentication, and settings are tied to this single user.

### Design for Future Multi-User Support
- Architect the data storage layer so that all files, metadata, and settings are associated with a user ID (even if only one user exists in the MVP).
- Use a user-specific root directory or database namespace.
- Design authentication and session management to allow for multiple user credentials in the future (e.g., PIN/biometric per user).
- Keep the UI modular so that a user switcher or login screen can be added later without major refactoring.
- Each user should have their own encryption key, derived from their PIN/recovery phrase. Ensure the key management system can support multiple keys in the future.

### Implementation Principle
- Do not implement user switching, multi-user UI, or shared device logic for the MVP.
- Only add abstraction layers (e.g., user ID in data models) if they do not significantly increase implementation complexity.

### Rationale
- Keeps the MVP simple and focused.
- Lays the groundwork for future multi-user/shared device support with minimal rework.

---
*Decision: MVP is single-user only, but design data and authentication layers to allow for future multi-user/shared device support if it does not significantly increase complexity.* 

## Secure Backup & Restore

### MVP Approach: Local Backup Only
- **Backup Location:**
  - Allow users to create encrypted local backups of all app data (files, metadata, settings) to a user-specified location (e.g., device storage, SD card, or desktop folder).
- **Backup Format:**
  - Use a single encrypted archive (e.g., ZIP or TAR with AES-256 encryption) containing all files and a database export.
  - The backup is protected with the user’s PIN or recovery phrase.
- **Restore:**
  - Allow users to restore from a local backup by providing the correct PIN or recovery phrase.
  - Validate backup integrity and version compatibility before restoring.

### Security Considerations
- **Encryption:**
  - All backup data must be encrypted at rest using strong encryption (AES-256-GCM or equivalent).
- **Key Management:**
  - The backup encryption key is derived from the user’s PIN or recovery phrase.
- **No Cloud Storage:**
  - For the MVP, do not support cloud backup or sync.
- **User Control:**
  - Users can create, store, and delete backups as they wish.
  - Warn users that losing their recovery phrase/PIN will make backups unrecoverable.

### User Experience
- **Simple UI:**
  - Provide clear options to “Create Backup” and “Restore from Backup.”
  - Show backup creation date, size, and location.
- **Warnings:**
  - Warn users to store backups and recovery phrases securely.
  - Confirm before overwriting existing data during restore.

### Future Considerations
- Add optional cloud backup/sync in future versions, with end-to-end encryption.
- Support for automatic scheduled backups.

---
*Decision: MVP supports only encrypted local backup/restore, no cloud backup. All backup data is encrypted and protected by the user’s PIN or recovery phrase.* 

## Dependency Management

### Approach
- **Use Well-Maintained Libraries:**
  - Only use open-source libraries with active maintenance, good documentation, and a history of security responsiveness.
- **Minimal Dependencies:**
  - Prefer fewer dependencies to reduce the attack surface and maintenance burden.
- **Track and Audit Dependencies:**
  - Use automated tools to track dependencies and check for known vulnerabilities (e.g., dependabot, GitHub security alerts, npm audit, pip-audit, or equivalents for your stack).
- **Automated Vulnerability Checks:**
  - Integrate automated vulnerability checks as part of CI/CD pipelines, or use dependabot/GitHub alerts for continuous monitoring and updates.
- **Update Regularly:**
  - Regularly update dependencies to the latest secure versions, especially for security-critical libraries (encryption, storage, authentication).
- **Review Before Adding:**
  - Review the code, license, and reputation of any new dependency before adding it to the project.
- **Lockfile Management:**
  - Use lockfiles (e.g., package-lock.json, pubspec.lock) to ensure reproducible builds and prevent accidental upgrades.
- **Remove Unused Dependencies:**
  - Periodically audit and remove unused or obsolete libraries.

### User Experience
- **Transparency:**
  - Optionally, provide a list of key open-source dependencies in the app’s About or Privacy section for transparency.

### Future Considerations
- Consider periodic third-party security audits for critical releases.

---
*Decision: Use well-maintained libraries, minimal dependencies, regular updates, and automated vulnerability checks as part of CI/CD (or dependabot/GitHub alerts) for secure dependency management.* 