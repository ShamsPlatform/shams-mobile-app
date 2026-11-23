---
name: shams-task-designer
description: >-
  Designs and generates structured engineering tasks, GitHub issues, and implementation checklists
  for the Shams Mobile App following the official Shams Clean Architecture task template.
  Use this skill whenever the user asks to create, design, write, format, or break down a new task,
  feature spec, refactoring ticket, or bug-fix assignment.
---

# Shams Task Designer (`shams-task-designer`)

Use this skill to design comprehensive, codebase-grounded engineering tasks for **Shams Mobile App** (`shams_mobile_app`) that strictly follow the team's canonical task template and Clean Architecture rules.

---

## 1. Pre-Design Codebase Investigation (Mandatory before writing a task)

Never write a vague or generic task. Before drafting the output, inspect the workspace so every file path, class name, provider, and architectural boundary in the task is real and accurate:

1. **Locate Existing Files**: Search `lib/core/`, `lib/app/`, `lib/features/<feature>/`, and `test/` to identify exact files that will be modified or mirrored.
2. **Verify Architecture Guardrails (`tool/check_architecture.dart`)**:
   - **Allowed top-level items under `lib/`**: Only `app/`, `core/`, `features/`, and `main.dart`. Never propose creating a new top-level folder under `lib/` (e.g., place new cross-cutting modules under `lib/core/<module>/`).
   - **Package Imports Only**: Every Dart file must use `package:shams_mobile_app/...` imports (`always_use_package_imports`). Relative imports (`../` or `./`) are forbidden.
   - **Layer Import Boundaries**:
     - `lib/features/*/domain/` **MUST NOT** import `package:flutter/`, `/data/`, `/presentation/`, or `/app/`. Keep `domain/` pure Dart (entities, repositories, use cases, `Result<T>` / `Failure`, and `String` file paths instead of `dart:io File`).
     - `lib/features/*/presentation/` **MUST NOT** import `/data/`. Presentation communicates through `ChangeNotifier` providers injected with domain use cases via `get_it` (`sl`).
     - `lib/features/*/data/` **MUST NOT** import `/presentation/` or `/app/`, and features **MUST NOT** import another feature's `/data/` layer.
     - `lib/core/` **MUST NOT** import `/features/` (except `lib/core/di/injection.dart`).
     - `lib/app/` **MUST NOT** import `/features/*/data/`.
   - **External SDK Confinement**:
     - `Supabase.instance` and `package:supabase_flutter/` are only allowed in `lib/main.dart`, `lib/core/di/injection.dart`, `lib/core/data/datasources/`, and `lib/features/*/data/datasources/`.
     - `package:shared_preferences/` is only allowed in `lib/core/di/injection.dart`, `lib/core/theme/theme_storage.dart`, `lib/core/l10n/language_storage.dart`, and `lib/features/*/data/datasources/`. If a task introduces a new core storage wrapper using `SharedPreferences`, explicitly include a checklist item to update `_sharedPrefsAllowedPaths` in `tool/check_architecture.dart`.
3. **Check Cross-Cutting Project Conventions**:
   - **DI (`get_it`)**: Registration happens in `lib/core/di/injection.dart` (`_initCore()` or `_init<Feature>()`), root provider wiring in `lib/main.dart` and `lib/app/app_providers.dart`.
   - **Localization & RTL/LTR**: UI strings belong in `lib/core/l10n/app_ar.arb` and `lib/core/l10n/app_en.arb` via `AppLocalizations.of(context)!`. Layouts must use `EdgeInsetsDirectional` and `AlignmentDirectional` without hardcoded `Directionality(textDirection: TextDirection.rtl, ...)`.
   - **Database Constants vs. UI Labels**: Stored Supabase filter/column values (e.g. in `lib/core/constants/app_constants.dart`) must remain unchanged when querying/writing to Supabase; map them to localized labels in the presentation layer.

---

## 2. Mandatory Task Structure & Formatting Rules

Every generated task **MUST** follow the exact 4-part layout below (see [resources/task-template.md](./resources/task-template.md) for the blank skeleton and gold-standard reference example):

### Part A: Header Block
```markdown
## <Emoji> Task: <Action-Oriented Task Title>
Assignee: [@<github_username>](https://github.com/<github_username>)
Goal: <Single comprehensive paragraph explaining what capability/fix is being introduced to the "Shams" platform under Clean Architecture (`app/`, `core/`, `features/`), which core/feature modules and state providers are created or updated, and which architectural or data constraints must be preserved.>
```
- Use a relevant topic emoji in the H2 heading (e.g., `🌍`, `🛠️`, `🔐`, `💬`, `🔔`, `☀️`, `⚡`, `🧪`).
- If the user provides an assignee username, format it as `[@username](https://github.com/username)`. If not specified, default to `[@omararef775](https://github.com/omararef775)` or ask/use the requested assignee.
- Write the task in **English** (keeping exact Arabic string literals in quotes like `'شمس'` or `'عربي'` when referencing existing hardcoded strings or DB constants).

### Part B: `### 📝 Task Checklist`
Break the implementation into **4 to 6 numbered H4 phases** (`#### 1. ...`, `#### 2. ...`) ordered logically by architectural dependency:
1. **Foundation / Setup / Domain Contracts** (Config, `pubspec.yaml`, `core/` setup, or `features/<feature>/domain/` entities, repository interfaces, and use cases).
2. **Data Layer, State Management, Persistence & DI** (Datasources, models, repository implementations, `ChangeNotifier` providers, storage classes, `lib/core/di/injection.dart`, `lib/main.dart`, `lib/app/app_providers.dart`, and `tool/check_architecture.dart` allowlist updates if needed).
3. **App Shell / Core Helpers / Layer-Safe Business Logic** (`lib/app/app.dart`, formatters, constants, error/failure handling without violating `domain/` purity).
4. **Presentation Layer, UI Wiring & Dynamic RTL/LTR Audit** (Exact screen and widget files under `lib/features/<feature>/presentation/` and `lib/core/widgets/`, provider wiring with `context.watch`/`context.read`, `AppLocalizations`, and `EdgeInsetsDirectional`/`AlignmentDirectional`).
5. **Final Section (Always Required): `#### <N>. Testing & Verification Gates (Gate G1 + CI)`**
   - Specify exact unit and widget test files to add or update under `test/` (mirroring `lib/` paths).
   - Always include the required local CI verification block:
     ```powershell
     flutter pub get
     dart run tool/check_architecture.dart
     flutter analyze
     flutter test
     flutter build apk --debug --dart-define-from-file=env/dev.json
     ```

**Checklist Bullet Rules:**
- Start each group bullet with bold component name + backticked path: `- **<Component / Layer Name> (\`path/to/file.dart\`):**`
- Under each group, list concrete sub-bullets specifying exact class names, method signatures, state fields, widget callbacks, and explicit **"do not"** architectural guardrails.
- Include short inline code blocks (`yaml`, `dart`, `sql`) whenever exact configuration or DI registration syntax clarifies the requirement.

### Part C: `### 📂 Key Directory & File Paths`
Group all touched and newly created files by role using bold labels and backticked paths (append `(New)` to categories or files being introduced):
```markdown
### 📂 Key Directory & File Paths
- **Config & Rules:** `...`
- **<Module/Feature> Core (New):** `...`
- **DI & App Shell:** `...`
- **Core Helpers & UI:** `...`
- **<Feature> UI:** `...`
- **Feature UI & Tests:** `...`
```

### Part D: `### 🛠️ Execution Steps (Git Flow)`
Provide a ready-to-run `powershell` script block covering the 5 standard Git Flow steps:
1. `# 1. Update local main` (`git checkout main` + `git pull origin main`)
2. `# 2. Create the feature branch` (`git checkout -b <type>/<kebab-case-task-slug>`, e.g. `feature/...`, `fix/...`, `refactor/...`)
3. `# 3. Review status and commit logically (...)` — split into **2–3 logical, atomic Conventional Commits** (`feat(<scope>): ...`, `fix(<scope>): ...`, `refactor(<scope>): ...`) staging foundation/setup/DI first, then feature UI/extraction/tests.
4. `# 4. Run verification gates before pushing` (`dart run tool/check_architecture.dart`, `flutter analyze`, `flutter test`)
5. `# 5. Push to remote` (`git push -u origin <branch-name>`)

---

## 3. Quality & Validation Checklist (Self-Check Before Outputting)

Before presenting the designed task to the user, verify:
- [ ] Does the header have `## <Emoji> Task: ...`, `Assignee: [@...](https://github.com/...)`, and `Goal: ...`?
- [ ] Are all file paths verified against the actual `shams-mobile-app` directory structure (`lib/app/`, `lib/core/`, `lib/features/`, `test/`, `tool/check_architecture.dart`)?
- [ ] Are architectural boundaries explicitly protected (no `package:flutter/` in `domain/`, no `/data/` in `presentation/`, `package:shams_mobile_app/...` imports, SDK confinement)?
- [ ] Does the last checklist item include the exact 5 PowerShell verification commands (`flutter pub get`, `dart run tool/check_architecture.dart`, `flutter analyze`, `flutter test`, `flutter build apk --debug --dart-define-from-file=env/dev.json`)?
- [ ] Are `### 📂 Key Directory & File Paths` and `### 🛠️ Execution Steps (Git Flow)` complete and tailored to this task's files and branch name?

