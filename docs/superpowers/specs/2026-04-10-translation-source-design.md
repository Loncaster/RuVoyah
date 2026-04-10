# Design: Single Translation Source Per App

## Summary

The repository will move from manual editing of three duplicate Android resource files per overlay project to a single canonical translation file per application.

Users will edit only:

- `translations/setting/strings.xml`
- `translations/launcher/strings.xml`
- `translations/vehicle/strings.xml`
- `translations/vehiclesetting/strings.xml`
- `translations/hiboard/strings.xml`
- `translations/bluetoothphone/strings.xml`
- `translations/dvr/strings.xml`

Before build, a repository script will copy each canonical file into the matching overlay project's:

- `app/src/main/res/values/strings.xml`
- `app/src/main/res/values-en/strings.xml`
- `app/src/main/res/values-zh/strings.xml`

These generated files will no longer be the user-facing edit surface.

## Goals

- Make translation changes understandable to a casual GitHub contributor.
- Remove the need to edit the same string in three folders.
- Keep local build flow and CI flow identical.
- Preserve the existing overlay build structure in `source code/`.
- Keep the solution simple enough to maintain without Gradle-specific customization in every overlay project.

## Non-Goals

- Changing overlay package names or Android package names.
- Replacing the existing Gradle projects.
- Automatically discovering new overlay projects from disk.
- Supporting different text per `values`, `values-en`, and `values-zh`.

## User Workflow

### GitHub contributor workflow

1. Open the app-specific file under `translations/<app>/strings.xml`.
2. Add or edit the needed `<string>` entries there.
3. Open a pull request.

The contributor does not need to touch `source code/.../res/values*/strings.xml`.

### Local verification workflow

For local build and later installation on the car, the contributor runs one command:

```powershell
.\scripts\build-overlay.ps1 -App setting
```

This command will:

1. Validate the requested app name.
2. Copy `translations/<app>/strings.xml` into the three target `values*` directories of the mapped overlay project.
3. Build the matching overlay project.
4. Print the APK path for manual installation on the car.

### Full build workflow

For CI and release packaging, repository scripts will first synchronize translations and only then build all overlays.

## Directory and Naming Design

### Canonical translation directory

New root directory:

```text
translations/
```

Subdirectories are named for user readability, not for internal overlay project names:

- `setting`
- `launcher`
- `vehicle`
- `vehiclesetting`
- `hiboard`
- `bluetoothphone`
- `dvr`

Each subdirectory contains exactly one canonical file:

```text
translations/<app>/strings.xml
```

### Internal mapping

Build scripts will maintain an explicit map:

- `setting` -> `ruvoyahoverlaysetting`
- `launcher` -> `ruvoyahoverlaylauncher`
- `vehicle` -> `ruvoyahoverlayvehicle`
- `vehiclesetting` -> `ruvoyahoverlayvehiclesetting`
- `hiboard` -> `ruvoyahoverlayhiboard`
- `bluetoothphone` -> `ruvoyahoverlaybluetoothphone`
- `dvr` -> `ruvoyahoverlaydvr`

This keeps the user-facing structure simple while preserving existing project layout.

## Script Design

### `scripts/sync-translations.ps1`

Responsibility:

- Copy all canonical translation files into generated `values`, `values-en`, and `values-zh` resource files.

Behavior:

1. Validate that every expected `translations/<app>/strings.xml` file exists.
2. Validate that the destination overlay project directories exist.
3. Copy the canonical XML file byte-for-byte into all three destination directories.
4. Fail fast with a clear error if an app name, source file, or destination path is missing.

The script should not build anything.

### `scripts/build-overlay.ps1`

Responsibility:

- Provide the simplest local path for a contributor who wants to build one app after editing a translation.

Behavior:

1. Accept `-App <name>`.
2. Validate the app name against the mapping table.
3. Synchronize only that app's canonical file into the three destination folders.
4. Run Gradle for the mapped overlay project.
5. Print the resulting APK path.

This script is the recommended local command in documentation because it minimizes user decisions.

### `scripts/build-all-overlays.ps1`

Responsibility:

- Build all overlays for CI and release packaging.

Behavior change:

1. Run `scripts/sync-translations.ps1`.
2. Build all overlay projects as today.

## Generated Files Policy

Files under `source code/<overlay>/app/src/main/res/values*/strings.xml` become generated build inputs, not committed source files.

Repository documentation must say clearly:

- edit only `translations/<app>/strings.xml`
- do not manually edit generated `values*/strings.xml`

Implementation should remove these files from Git tracking and ignore them so pull requests stay focused on canonical translation files.

If someone edits generated files directly in a local working tree, the next sync or build will overwrite those changes.

## Migration Plan

1. Create the `translations/` directory tree.
2. Initialize each `translations/<app>/strings.xml` from one existing resource file in the corresponding overlay project.
   - Use current `values/strings.xml` as the baseline source.
3. Add synchronization script(s).
4. Remove generated `values*/strings.xml` from Git tracking and add ignore rules for them.
5. Update build scripts so synchronization always happens before build.
6. Update documentation and `AGENTS.md`.
7. Verify that synchronized output matches the old duplicated layout.

## Error Handling

- Unknown app name: fail with allowed app names listed.
- Missing canonical file: fail with the exact expected path.
- Missing overlay project path: fail with the mapped overlay path.
- Build failure: surface Gradle failure after synchronization has completed.

The scripts should not silently skip apps or auto-create incomplete files.

## Testing Strategy

### Script-level verification

- Run synchronization and confirm the three generated files for one app match the canonical file content.
- Run full synchronization and confirm all expected target files are updated.
- Run single-app build via `build-overlay.ps1`.
- Run full build via `build-all-overlays.ps1`.

### Regression checks

- Verify that a contributor can complete a translation change by editing only one file.
- Verify that documentation references only the new edit surface.

## Documentation Changes Required

Update these files:

- `AGENTS.md`
- `README.md`
- `CONTRIBUTING.md`
- `docs/contributor-guide.md`

Required documentation updates:

- canonical translation files now live in `translations/<app>/strings.xml`
- local contributors should run `.\scripts\build-overlay.ps1 -App <app>`
- full repository builds and CI synchronize translations automatically before building
- generated files in `source code/.../res/values*` are not meant for manual edits and are recreated by scripts

`AGENTS.md` must also preserve the existing repository rules:

- read `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, and `docs/contributor-guide.md` before work
- do not create unnecessary service files in the repository
- keep temporary files out of the repository root
- for local verification on the car, the documented flow should point users to the new build script before installation steps

## Rationale

This design intentionally avoids embedding translation generation into each Gradle project. A repo-level PowerShell workflow is easier to understand, easier to debug, and better aligned with the current repository structure and contributor profile.

It also keeps GitHub contribution simple: one app, one file, one obvious place to edit.
