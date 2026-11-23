# Shams Task Design & Specification Rules

Whenever the user asks to design, write, draft, or prepare a task, ticket, issue, or feature assignment for **Shams Mobile App** (`shams_mobile_app`), you **MUST** activate and follow the `shams-task-designer` skill (`.agents/skills/shams-task-designer/SKILL.md`) and output the task in the exact structure below.

## 1. Mandatory Output Sections
Every designed task must be written in English (preserving exact Arabic string literals in quotes when referencing existing UI/DB values) and contain these four exact sections in order:

1. **Header Block**:
   - `## <Emoji> Task: <Clear, Action-Oriented Title>`
   - `Assignee: [@<github_username>](https://github.com/<github_username>)` (use `[@omararef775](https://github.com/omararef775)` if no other assignee is given)
   - `Goal: <Single comprehensive paragraph summarizing the feature/fix under Clean Architecture (app/, core/, features/), the components/providers involved, and architectural constraints>`
2. **`### 📝 Task Checklist`**:
   - Divided into numbered phases (`#### 1. <Phase Name> (<Target Path>)`, `#### 2. ...`) ordered from foundation/domain/data/DI to UI wiring and finally testing.
   - Each bullet group names exact backticked file paths, exact class/method names, DI registrations (`lib/core/di/injection.dart`, `lib/main.dart`, `lib/app/app_providers.dart`), and explicit architectural warnings.
   - The final checklist section **MUST** always be `#### <N>. Testing & Verification Gates (Gate G1 + CI)` specifying unit/widget test paths under `test/` and this exact PowerShell block:
     ```powershell
     flutter pub get
     dart run tool/check_architecture.dart
     flutter analyze
     flutter test
     flutter build apk --debug --dart-define-from-file=env/dev.json
     ```
3. **`### 📂 Key Directory & File Paths`**:
   - Categorized list of bold group names with backticked file/glob paths (marking `(New)` where applicable).
4. **`### 🛠️ Execution Steps (Git Flow)`**:
   - A `powershell` block with 5 numbered steps:
     1. `# 1. Update local main` (`git checkout main`, `git pull origin main`)
     2. `# 2. Create the feature branch` (`git checkout -b <type>/<kebab-case-slug>`)
     3. `# 3. Review status and commit logically (...)` (2–3 atomic Conventional Commits splitting setup/DI/domain/data from UI/tests)
     4. `# 4. Run verification gates before pushing` (`dart run tool/check_architecture.dart`, `flutter analyze`, `flutter test`)
     5. `# 5. Push to remote` (`git push -u origin <type>/<kebab-case-slug>`)

## 2. Mandatory Clean Architecture Guardrails in Every Task
Before writing a task, inspect the codebase so all referenced file paths exist (or follow existing patterns) and never propose changes that violate `tool/check_architecture.dart`:
- **Top-level `lib/` directories**: Only `app/`, `core/`, `features/`, and `main.dart` are permitted directly under `lib/`.
- **Imports**: Always require `package:shams_mobile_app/...` imports (no relative imports).
- **Layer purity**:
  - `lib/features/*/domain/` must never import `package:flutter/`, `/data/`, `/presentation/`, or `/app/` (no `BuildContext`, `AppLocalizations`, or `dart:io File` in `domain/`).
  - `lib/features/*/presentation/` must never import `/data/`.
  - `lib/features/*/data/` must never import `/presentation/`, `/app/`, or another feature's `/data/`.
  - `lib/core/` must never import `/features/` (except `lib/core/di/injection.dart`).
- **SDK confinement**:
  - `Supabase.instance` and `package:supabase_flutter/` are confined to `lib/main.dart`, `lib/core/di/injection.dart`, `lib/core/data/datasources/`, and `lib/features/*/data/datasources/`.
  - `package:shared_preferences/` is confined to `_sharedPrefsAllowedPaths` in `tool/check_architecture.dart` (if adding a new core storage class, include a step to update `_sharedPrefsAllowedPaths`).
- **Localization & RTL/LTR**: Require `AppLocalizations.of(context)!` (`lib/core/l10n/app_ar.arb` & `app_en.arb`) for UI text, preserve raw Supabase DB constants in queries/writes, and require `EdgeInsetsDirectional` / `AlignmentDirectional` without hardcoded `TextDirection.rtl` wrappers.

