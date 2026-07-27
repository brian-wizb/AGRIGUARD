# AgriGuard Phased Implementation Plan

## 1. Document Purpose

This document converts the objectives in `agriguard requirements.txt` and the
additional product requirements into an implementation roadmap for AgriGuard.
It is the baseline plan to approve before application development begins.

## 2. Product Vision

AgriGuard will be a farmer-friendly mobile application for smallholder farmers
in Tanzania. A farmer will scan any leaf directly with the camera or choose a
leaf image, receive an AI-assisted disease or pest classification with clear
next actions, save the diagnosis for later reference, and—when appropriate—
send a controlled command to an Arduino-based pest-control trap.

The entire user interface will be available in English and Swahili. The first
release will prioritize Android smartphones, simple navigation, low bandwidth
usage, and locally retained records.

## 3. Objectives and Requirement Traceability

| Source objective or requirement | Planned implementation |
| --- | --- |
| Develop a machine-learning subsystem for crop disease detection | Direct OpenAI vision analysis from the Flutter app, image-quality checks, structured output, and validation |
| Develop a subsystem for crop disease and pest classification | Leaf-first disease and pest classification, confidence/uncertainty handling, and farmer-safe recommendations without requiring crop preselection |
| Develop a mobile subsystem for user interaction | Flutter Android application with camera/gallery input, dashboard, diagnosis results, history, settings, and accessible farmer-focused UI |
| Implement serial communication commands to an Arduino trap | Hardware connection service, explicit command protocol, acknowledgements, timeouts, retries, safety confirmation, and event logging |
| Use SQLite/Hive storage | SQLite as the primary structured local database; lightweight preferences may use Hive only if needed |
| English and Swahili language toggle for the entire app | Flutter localization resources for all user-facing text, saved locale preference, and bilingual AI results |
| Include a login page | Registration/login/logout flow, persisted session, password reset path, and protected application routes |
| Use OpenAI as the AI provider | Direct OpenAI integration from Flutter using a key embedded in the APK for this academic prototype |

## 4. Agreed Scope

### 4.1 Minimum Viable Product

- User registration, login, logout, and session restoration.
- English/Swahili selection on first launch, login, and settings.
- Scan any leaf directly with the camera or choose a leaf image from the phone
  gallery; the user will not select a crop first.
- Detect unsupported, unclear, or unusable images before presenting a result.
- Classify likely diseases/pests affecting Mchicha or spinach.
- Show the crop, likely condition, confidence/uncertainty, observable symptoms,
  recommended response, precautions, and whether a trap action is applicable.
- Save diagnosis records locally and view diagnosis history.
- Connect to the agreed Arduino serial transport.
- Send only allow-listed commands, display device acknowledgement/failure, and
  store a command audit record.
- Work gracefully with intermittent internet access: history and settings remain
  available offline; new OpenAI diagnoses require connectivity.

### 4.2 Not in the Initial MVP

- Fully autonomous pesticide application without user confirmation.
- A custom, locally trained computer-vision model.
- Diagnosis of crops other than Mchicha and spinach.
- Guaranteed diagnosis or replacement of an agronomist/extension officer.
- iOS serial support before the Android hardware path is proven.
- A full extension-officer web portal, marketplace, or social network.

These can be reconsidered after MVP field validation.

## 5. Proposed Technical Architecture

```text
Flutter Android app
  ├─ Login and localized user interface
  ├─ Camera/gallery and image compression
  ├─ SQLite local database
  ├─ Device-local authentication state
  ├─ OpenAI client, response validation, and safety rules
  └─ Arduino connection service
           ├──────── USB OTG or Bluetooth serial ────────> Arduino trap
           └──────── HTTPS ──────────────────────────────> OpenAI API
```

### 5.1 Mobile Application

- Framework: Flutter/Dart (the repository is currently a clean Flutter starter).
- Architecture: feature-first layers with presentation, application/domain, and
  data/infrastructure separation.
- State management and routing will be selected during Phase 1 and used
  consistently thereafter.
- Target: Android first; code should remain portable where platform hardware
  limitations allow.

### 5.2 Storage

SQLite will be the default because diagnoses, users, device events, and command
logs are relational and need querying. Hive may be used for simple cached
preferences only; it will not duplicate SQLite business records.

Passwords will not be stored as plaintext. For this offline academic prototype,
users and password hashes will be stored locally in SQLite. The selected
password-hashing approach will include a unique salt per user. This login is
device-local and does not provide account recovery or synchronization between
phones.

### 5.3 OpenAI Integration

- The Flutter app will call the OpenAI Responses API directly with image input
  and request a strict structured result rather than unrestricted prose.
- For this final-year project, the OpenAI API key will be provided to the Flutter
  build and embedded in the APK.
- An embedded key can be recovered by anyone who obtains the APK. Therefore, the
  project key must be separate from personal/production keys, have a low project
  budget/usage limit, and be rotated or revoked after the demonstration.
- The AI response will be validated locally against an application-owned schema and an
  allow-listed crop/condition catalog before display or hardware action.
- Model name, prompt version, request identifier, latency, and token usage will
  be logged locally without storing the API key or unnecessarily retaining
  farmer images.
- Rate limits, timeouts, retry/backoff, image-size limits, and budget controls
  will be implemented.
- English and Swahili output will use the same stable diagnosis codes. The app
  will localize known interface/taxonomy text; AI explanatory text will be
  requested in the user's selected language.
- Low-confidence, conflicting, or unsupported results will instruct the user to
  retake the photo or contact an agricultural expert.

Proposed diagnosis response fields:

```text
diagnosisId, cropCode, conditionCode, category, confidenceBand,
symptoms, recommendedActions, precautions, trapActionApplicable,
proposedHardwareCommand, userLanguage, model, promptVersion
```

`proposedHardwareCommand` is advisory only. The application safety layer makes
the final decision and requires confirmation before transmission.

### 5.4 Arduino Communication

The project must select one initial physical transport:

- USB serial through Android USB OTG; or
- Bluetooth Classic/BLE with a serial-capable Arduino module.

The selection will be made in Phase 1 after testing the actual phone, Arduino,
and adapter/module. The protocol will use versioned, allow-listed commands,
message framing, device acknowledgements, timeout/retry behavior, and duplicate
command protection.

Example protocol for discussion, not yet final:

```text
APP -> TRAP: AGRI|1|CMD|ACTIVATE|<duration>|<request-id>|<checksum>
TRAP -> APP: AGRI|1|ACK|<request-id>|OK
```

Commands such as `STATUS`, `ACTIVATE`, and `STOP` will be mapped to safe,
hardware-approved behavior. Free-form AI text will never be sent to the Arduino.

## 6. Core User Flow

1. User opens the app and chooses English or Swahili.
2. User registers or logs in.
3. User scans any leaf with the camera or chooses a leaf image. No crop
   preselection is required.
4. App checks image type/size and asks for confirmation.
5. App sends the compressed image directly to OpenAI over HTTPS.
6. App validates the structured OpenAI response against the approved taxonomy.
7. App presents the diagnosis, uncertainty, recommendations, and precautions in
   the selected language.
8. App saves the record locally.
9. If a trap action is applicable, the app displays the exact action and asks
   for explicit user confirmation.
10. App sends the allow-listed command and records acknowledgement or failure.

## 7. Data Model Baseline

| Entity | Important fields |
| --- | --- |
| UserProfile | local ID, display name, username/email identifier, salted password hash, preferred language, created/updated timestamps |
| AuthSession | local user ID, login state, last authenticated timestamp |
| Diagnosis | ID, user ID, crop code, condition code, category, confidence band, symptoms, recommendations, precautions, local image reference, status, model/prompt version, timestamps |
| HardwareDevice | ID, name, transport, address/USB identity, protocol version, last connected timestamp |
| HardwareCommand | ID, diagnosis ID, device ID, command type, safe parameters, request ID, acknowledgement, status, error, timestamps |
| AppPreference | language, onboarding state, privacy choices |

Database migrations and indexes will be versioned from the first implementation.
Image files will be stored in application-controlled file storage, with only
their references and metadata in SQLite.

## 8. Implementation Phases

### Phase 0 — Provisional Discovery (Non-blocking)

**Goal:** record reasonable assumptions now and refine them as project evidence,
hardware, and stakeholder feedback become available. Phase 0 does not block
Phase 1 implementation.

Tasks:

- Start with general leaf recognition and record the detected crop/plant as part
  of the AI result; prioritize Mchicha and spinach during evaluation.
- Maintain a provisional disease/pest taxonomy and refine it with a qualified
  agricultural source when available.
- Define what counts as disease detection, pest classification, and "unknown."
- Obtain representative test images and expected labels with permission to use
  them.
- Assume Android-first and intermittent connectivity until the supported device
  range is confirmed.
- Keep USB OTG and Bluetooth behind a transport interface until the actual
  Arduino connection is confirmed.
- Define the Arduino firmware command set, duration limits, acknowledgements,
  emergency stop, and failure behavior.
- Decide whether the local login identity is email, username, or phone number.
- Approve image retention, deletion, consent, and privacy rules.

Provisional deliverables:

- Working assumptions register and change log.
- Draft taxonomy and an incrementally growing labeled evaluation set.
- Draft hardware protocol and authentication/data-retention decisions.
- Updated acceptance criteria and risk register as details are confirmed.

Progression rule:

- Begin Phase 1 immediately. Use interfaces and configuration boundaries for
  unresolved decisions so later requirement updates do not require rebuilding
  the entire application.

### Phase 1 — Project Foundation and UX Specification

**Goal:** establish an implementation-ready application skeleton.

Tasks:

- Organize the Flutter codebase into feature modules.
- Configure development, test, and demonstration builds.
- Establish navigation, state management, error handling, logging, and themes.
- Produce low-fidelity screens and bilingual content inventory.
- Configure Flutter localization with English and Swahili resource files.
- Define SQLite schema, migrations, repositories, password hashing, and local
  login-state storage.
- Establish the direct OpenAI client, build-time key injection, and response
  validation boundaries.
- Add linting and unit-test setup. Keep the real key out of screenshots, logs,
  documentation, and test fixtures even though it is embedded in the demo APK.

Deliverables:

- Navigable application shell.
- Approved screen flow and bilingual terminology glossary.
- Database and API contracts.
- Backend skeleton with no key committed to source control.

Exit criteria:

- App starts successfully, changes language without restart, and passes baseline
  static analysis/tests.

### Phase 2 — Authentication, Localization, and Local Data

**Goal:** deliver the complete entry and persistence experience.

Tasks:

- Build first-launch language selection and an always-available language toggle.
- Implement login, registration, validation, logout, session expiry, protected
  routes, loading states, and understandable bilingual error messages.
- Implement SQLite migrations and repositories.
- Add user settings and session restoration.
- Verify every screen, dialog, validation message, permission explanation, and
  accessibility label in English and Swahili.

Deliverables:

- Working bilingual authentication flow.
- Persistent local profile, preferences, and login state.
- Automated localization and repository tests.

Exit criteria:

- A user can register/login, switch language across the entire app, restart the
  app, and retain the correct authenticated/localized state.

### Phase 3 — Image Capture and OpenAI Diagnosis

**Goal:** produce safe, structured, usable crop diagnoses.

Tasks:

- Implement camera/gallery permissions, capture, preview, crop/rotate, and image
  compression.
- Implement direct OpenAI requests with progress/cancellation states.
- Add the demonstration API key through build configuration and ensure it is
  never printed in application logs or error messages.
- Design and version the prompt and structured response schema.
- Enforce supported crop/condition codes and reject malformed responses.
- Add confidence/uncertainty behavior and actionable bilingual results.
- Save diagnosis metadata/history locally and support offline history browsing.
- Add request limits, cost telemetry, retry rules, and privacy-conscious logs.

Deliverables:

- End-to-end diagnosis flow.
- Diagnosis history and detail screens.
- Versioned prompt/schema and evaluation report.

Exit criteria:

- The available evaluation set meets the latest agreed accuracy threshold.
- Unsupported or unclear inputs fail safely.
- The dedicated demonstration key works from the APK, has a low API project
  budget limit, and can be revoked immediately after assessment.

### Phase 4 — Arduino Serial Integration

**Goal:** connect validated diagnoses to a safe physical response.

Tasks:

- Implement device discovery/selection, connect/disconnect, and connection state.
- Implement the versioned serial protocol, framing, checksum if required,
  acknowledgement, timeout, retry, and duplicate protection.
- Map only approved diagnosis/action codes to allow-listed hardware commands.
- Require a clear confirmation screen before activation.
- Implement `STOP`, duration limits, disconnected-device behavior, and visible
  failure recovery.
- Store command and acknowledgement logs in SQLite.
- Test with the real Arduino trap rather than only a software mock.

Deliverables:

- Hardware connection and status screen.
- Safe command service and audit history.
- Hardware-in-the-loop test report.

Exit criteria:

- Every command is traceable, invalid/free-form commands are blocked, timeouts
  are safe, and the trap acknowledges successful commands.

### Phase 5 — Integration, Quality, Security, and Field Pilot

**Goal:** validate AgriGuard in realistic farmer and field conditions.

Tasks:

- Run unit, widget, integration, OpenAI-contract, and hardware tests.
- Test poor lighting, blurry images, wrong crops, no internet, expired sessions,
  API failures, serial disconnects, and duplicate taps.
- Conduct usability sessions in both English and Swahili.
- Review local authentication, embedded-key exposure, local data, transport
  security, logs, and image privacy.
- Measure classification quality by crop and condition, not only overall.
- Measure API latency/cost, task completion, hardware success, and user
  comprehension.
- Fix release-blocking findings and prepare support/troubleshooting content.

Deliverables:

- Test and security reports.
- Pilot findings and resolved issue list.
- Release candidate.

Exit criteria:

- Approved functional, accuracy, safety, usability, performance, and privacy
  thresholds are met.

### Phase 6 — Demonstration Packaging and Handover

**Goal:** package a stable academic demonstration and control API expenditure.

Tasks:

- Configure a dedicated OpenAI project key with a low budget/usage limit and
  monitoring.
- Create a signed demonstration Android build and release notes.
- Publish privacy information, consent text, support process, and deletion path.
- Monitor errors, OpenAI usage/cost, diagnosis uncertainty, and hardware command
  failure rates.
- Establish prompt/model change control with regression evaluation before the
  final demonstration.
- Revoke or rotate the embedded key after assessment or whenever the APK leaves
  the intended testing group.

Deliverables:

- Demonstration MVP.
- Demonstration runbook and clean rebuild/key-rotation procedure.
- Prioritized post-pilot backlog.

Exit criteria:

- Demonstration monitoring, rollback, support ownership, and budget controls are
  active.

## 9. Testing Strategy

- **Unit tests:** validation, localization lookup, database repositories,
  diagnosis parsing, safe command mapping, and protocol framing.
- **Widget tests:** login, language toggle, image flow, diagnosis display,
  confirmation, and error/empty states.
- **Integration tests:** authentication, upload-to-diagnosis, offline history,
  session expiry, and hardware command logging.
- **OpenAI client tests:** schema validation, mocked rate limits, timeouts,
  malformed output, and duplicate-request protection.
- **AI evaluation:** labeled images split by crop, condition, lighting, camera
  quality, and unknown/unsupported inputs; track precision, recall, confusion,
  abstention, and unsafe recommendation rate.
- **Hardware-in-the-loop tests:** valid/invalid commands, disconnects, retries,
  duplicate requests, `STOP`, maximum duration, and acknowledgement.
- **Localization review:** native or proficient Swahili review of terminology,
  truncation, interpolation, error text, and action clarity.

Numerical acceptance thresholds will be refined as the provisional dataset and
hardware behavior become known; they should not be invented before measurement.

## 10. Security, Privacy, and Safety Controls

- Do not commit, log, or display the OpenAI API key. It may be packaged only in
  the demonstration APK as explicitly accepted for this project.
- Use HTTPS for all OpenAI requests.
- Use a dedicated, revocable, budget-limited demonstration key; never reuse a
  personal or production key.
- Store only salted password hashes for device-local users.
- Collect only required personal data and image metadata.
- Obtain consent before uploading images; define retention and deletion.
- Strip unnecessary image metadata where practical.
- Treat AI output as decision support, show uncertainty, and provide an expert
  escalation path.
- Keep the condition-to-command map in controlled application logic.
- Require user confirmation for physical activation and support immediate stop.
- Apply maximum activation duration and safe device defaults independently in
  Arduino firmware, so mobile application failure cannot leave the trap active.

## 11. Key Risks and Mitigations

| Risk | Mitigation |
| --- | --- |
| OpenAI general vision may not reliably distinguish locally relevant diseases | Build an expert-labeled evaluation set, use constrained taxonomy, allow abstention, pilot before release, and consider a specialized model later |
| Poor connectivity or API latency/cost | Compress images, expose progress/retry, keep history offline, enforce request/budget limits, and monitor cost |
| API key extraction from the APK | Accepted for this academic prototype; use a dedicated low-budget key, limit APK distribution, monitor usage, and revoke/rotate after the demonstration |
| Unsafe or fabricated treatment advice | Curated recommendations, structured codes, output validation, uncertainty handling, and expert review |
| Wrong AI result triggering hardware | No direct AI-to-serial path; allow-list mapping, confirmation, duration limit, acknowledgement, and firmware failsafes |
| USB/Bluetooth behavior differs by device | Resolve transport in Phase 0 and test against a supported-device matrix |
| Swahili agricultural terms become unclear or inconsistent | Maintain a reviewed bilingual glossary and localize stable taxonomy in-app |
| Local-only accounts do not support recovery or multiple phones | Document this MVP limitation; a backend authentication service would be required if the project later expands |

## 12. Definition of Done for the MVP

The MVP is complete when:

- A supported Android user can register/login and securely restore a session.
- Every user-facing app string is available in English and Swahili, and the
  chosen language persists.
- A user can capture/select a Mchicha or spinach image and receive a validated,
  comprehensible diagnosis or a safe "unable to determine" result.
- Diagnosis history is stored in SQLite and remains viewable offline.
- The dedicated OpenAI demonstration key is embedded through build configuration,
  is not exposed in UI/logs/source control, and has a low usage limit.
- Applicable results can generate only approved Arduino commands after explicit
  confirmation.
- Device acknowledgement/failure and the command audit trail are visible.
- Automated, AI evaluation, hardware, bilingual usability, security, and field
  acceptance criteria agreed during project discovery are satisfied.

## 13. Decisions Required Before Implementation

1. Which exact Mchicha/spinach diseases and pests are in the first-release
   taxonomy?
2. Is the initial Arduino connection USB OTG, Bluetooth Classic, or BLE?
3. What exact trap actions, parameters, maximum durations, and acknowledgements
   does the Arduino firmware support?
4. Will local users log in with phone number, email, or username?
5. What API spending limit should be placed on the dedicated demonstration key?
6. May crop images be retained for model evaluation, and for how long?
7. Who will approve Swahili agricultural terminology and treatment guidance?
8. What measured diagnosis, latency, hardware reliability, and usability
   thresholds will authorize the field pilot and MVP release?
