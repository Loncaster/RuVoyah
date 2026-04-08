# Public GitHub Repository And Release Automation Design

## Goal

Prepare a public GitHub repository for the Voyah Free Russian localization overlays so contributors can propose translation changes through pull requests, maintainers can review and merge them, and stable release archives are built and published automatically after merges to `main`.

## Constraints And Non-Goals

- The original working directory `C:\WinBackup-12.01.2026\RuVoyah_v3` must remain untouched during preparation work.
- The current project is not a git repository, so isolation is achieved through a separate working copy that will become the public repo workspace.
- Public repository contents must include only overlay source code, installer/uninstaller scripts, release packaging assets, and documentation.
- Public repository contents must not include OEM APK files from `native apk`, generated overlay APK files, build outputs, `local.properties`, or the existing `RuVoyah_v3.zip`.
- Preview builds must not appear in shared stable releases for the main public repository.
- The current custom license is retained unless the maintainer later decides to replace it.

## Public Repository Scope

The public repository will contain:

- The seven overlay Android projects currently stored under `source code/`.
- Installation and removal scripts:
  - `install_win.bat`
  - `install_mac.sh`
  - `uninstall_win.bat`
  - `uninstall_mac.sh`
  - `disable-verity_win.bat`
  - `disable-verity_mac.sh`
- Bundled `adb` files used by the installation package.
- Project documentation for users and contributors.
- GitHub Actions workflows for validation, preview packaging, and stable release publication.

The public repository will not contain:

- `native apk/*.apk`
- `overlay apk/*.apk`
- Any `app/build/` directories
- Any `.gradle/` cache directories if present
- Any `local.properties`
- Any release zip archives generated locally

## Repository Layout

The repository keeps the existing `source code/` layout for now to minimize structural churn in the first public version.

Top-level files and directories to add or maintain:

- `README.md`
- `CONTRIBUTING.md`
- `.gitignore`
- `.github/workflows/`
- `docs/`
- existing installer and helper scripts in repository root
- existing `source code/` directory with seven overlay projects

Planned documentation layout:

- `docs/installation.md`
- `docs/contributor-guide.md`
- `docs/release-process.md`

## Contributor Workflow

### Stable Contribution Path

1. Contributor identifies the target OEM application on the vehicle.
2. Contributor extracts the OEM APK from the vehicle manually.
3. Contributor extracts source strings from the OEM APK.
4. Contributor updates the matching overlay project under `source code/`.
5. Contributor validates string length and local behavior expectations.
6. Contributor optionally builds a preview package from their branch or fork for in-car verification.
7. Contributor opens a pull request.
8. Pull request CI verifies all overlay projects build successfully.
9. Maintainer reviews and merges to `main`.
10. Stable release workflow builds all overlays, assembles the install archive, and publishes the new release.

### Translation Rules

Contributor documentation must state the following rules explicitly:

- New translated text should be no longer than the equivalent English or Chinese source text whenever possible.
- If a translated string is longer than the English or Chinese equivalent, the contributor must verify it on a real vehicle before submitting a pull request.
- The pull request description should state whether any longer-than-source strings were tested on the vehicle.
- Contributors should keep terminology consistent across overlays where the same concept appears in multiple apps.

## Documentation Requirements

### User-Facing Installation Documentation

Installation docs must explain:

- prerequisites for connecting to the vehicle
- how to disable verity when needed
- how to install the packaged overlays
- how to uninstall them
- what files are included in the release archive
- where stable releases are downloaded from

### Contributor Documentation

Contributor docs must explain in detail:

- how to identify the target application package name on the vehicle
- how to locate and pull the OEM APK from the vehicle
- how to extract strings from the OEM APK
- how to find the matching overlay project in this repository
- where translated strings belong in the overlay project
- how overlay resources map to target strings
- how to build and test changes
- the translation length rule and in-car verification requirement
- how preview packaging works before pull request creation
- how to open a pull request

The existing `native apk/readme.txt` content is sufficient as source material for the extraction steps, but the public repo should rewrite this into cleaner markdown documentation instead of keeping OEM APK artifacts.

## CI And Release Design

### Pull Request Validation

Trigger:

- `pull_request` against `main`

Behavior:

- build all seven overlay projects
- fail fast on any build failure
- do not publish releases

Purpose:

- ensure translation changes do not break repository buildability before review

### Preview Packaging

Trigger:

- manual `workflow_dispatch`

Behavior:

- build all seven overlay projects from the selected branch
- package overlays together with `adb`, install/uninstall scripts, and short install/remove instructions
- publish the result as a workflow artifact in the main repository
- do not create or update a public GitHub Release in the main repository

Visibility model:

- In the main public repository, preview outputs are workflow artifacts only and are not part of public stable releases.
- Contributors working from forks can run the same workflow in their fork if they want a fork-local preview release history.

Purpose:

- allow contributors to validate changes on a vehicle before opening a pull request or before merge
- keep experimental packages out of the public stable release feed

### Stable Release Publication

Trigger:

- `push` to `main`

Behavior:

- build all seven overlay projects
- collect generated overlay APK files
- assemble a release directory containing:
  - overlays APK files
  - `adb` binaries and companion DLL files
  - installation and removal scripts
  - short install/remove instruction file
- package the release directory into a downloadable archive
- create or update a GitHub Release for the new stable version

Purpose:

- turn every reviewed merge into a downloadable install package for end users

## Release Artifact Design

Each stable release archive must include:

- all built overlay APK files
- Windows and macOS install scripts
- Windows and macOS uninstall scripts
- disable-verity scripts
- bundled `adb` assets already present in the project
- a short installation and removal guide

The release archive must not include:

- OEM APKs
- source-only helper material not required for installation
- preview-only notes

## Script Update Requirements

`install_mac.sh` needs to be reviewed and updated to match the effective logic currently used by `install_win.bat`.

This update should ensure:

- the same overlay files are pushed
- the same permission fixes are applied
- the same cache-clearing and reboot sequence is used where appropriate
- user-visible instructions remain consistent across platforms

The uninstall scripts should also be checked for parity and clarity while preserving current behavior.

## Versioning Strategy

The repository currently includes `version.txt`.

The first public automation pass should:

- keep a simple version source
- use that version for stable release naming if practical
- avoid introducing an overcomplicated tagging scheme in the first iteration

If exact automated semantic versioning is not practical in the first pass, the workflow may use a timestamped build identifier for preview builds and a version-plus-run identifier for stable release drafts, as long as the naming stays consistent and documented.

## Review And Governance

- `main` should be protected.
- Changes should be merged through pull requests only.
- At least one maintainer review should be required before merge.
- Stable release publication happens only from `main`.
- Preview outputs must remain separate from stable release history in the main public repository.

## Implementation Notes

- Preparation work happens in the isolated copy `C:\WinBackup-12.01.2026\RuVoyah_v3_public_repo`.
- Git will be initialized in the isolated copy.
- Work will continue on branch `codex/public-github-prep` until the public repository is ready to publish.
- The original source directory remains the source of truth until the maintainer accepts the public-repo preparation result.

## Open Decisions Already Resolved

- Host platform: GitHub
- Repository visibility target: public
- Published contents: overlay sources, scripts, docs, CI config, release packaging assets
- Excluded contents: OEM APKs, built APKs, build outputs, local machine settings
- Stable releases: automatic after reviewed merges to `main`
- Preview builds: available before PR or merge, but not published into the main repository's public stable releases
