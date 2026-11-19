---
name: android-app-clone
description: Use when the user wants to "clone", copy, recreate, port or reverse-engineer an Android app – either git-cloning an open-source project to build or extend it, or building their own app that replicates another app's features/look. Decides the right path (git clone, clean-room rebuild, iOS port), sets legal guardrails, and links to the craft-anything and android-app-dev skills.
---

# Cloning Android apps – pick the path first

"Klonen" can mean three different things. Ask one short question only if the request is ambiguous; otherwise pick by this table.

| User wants | Path |
|---|---|
| A **GitHub/F-Droid project** to build, read or extend | **A. git clone** |
| **Their own app that behaves/looks like** another app (a "clone" of a product) | **B. clean-room rebuild** |
| An **iOS app/Swift code** on Android | **C. iOS port** – use the `ios-to-android` skill |
| Understand **how an installed/closed app works** | **D. study** – only under the conditions below |

## A. git clone an open-source app

```bash
scripts/clone-app.sh https://github.com/<owner>/<repo>      # shallow clone into clones/<repo> (gitignored)
cd clones/<repo> && ./gradlew assembleDebug
```

1. Read the **license first** (script prints it). No license file = all rights reserved: build and read locally, do not copy code
   into other projects or redistribute. GPL/AGPL: derived work must stay GPL/AGPL. Apache/MIT/BSD: keep notices.
2. Build as documented in the README/CI config. Older projects need an older Gradle/AGP: use the wrapper they ship; do not
   upgrade as a side effect. If the build needs a JDK/SDK version we lack, install it (setup script / apt) and say so.
3. Changes go on a branch; if the user wants it as their own repo, keep upstream license + attribution and add a fork note.

## B. Clean-room rebuild of an app's functionality ("make me an app like X")

Facts, ideas and user-visible behaviour are free to reimplement. Code, artwork, icons, text, sounds, brand names and trade dress are not.

1. **Spec first** (write `apps/<slug>/SPEC.md`): purpose, user flows, screens, data model, offline/online behaviour. Source the spec from
   the user's description, screenshots they provide, the app's public store listing and documentation – not from decompiled code.
2. **Own identity**: new app name, new package id (`de.twitra.<name>`), new icon and colours, own copy text. Never use the original's
   logo, name or store wording; never ship something that could be mistaken for the original (Google Play impersonation policy).
3. **Scaffold and build** with `scripts/new-app.sh`, then follow `android-app-dev`. Build vertical slices (one flow end to end), keep
   logic testable, render previews.
4. Optional help: `craft-anything` skill (`craft-anything-cli rebuild`) in **clean-room mode** for websites and for apps whose window
   screenshots the user supplies.
5. Backend services of the original (private APIs, accounts) are **not** reimplemented or called without the owner's permission.
   Offer local storage, an open API, or a mock instead.

## C. iOS → Android

Read `.claude/skills/ios-to-android/SKILL.md` (installed by `scripts/android-skills.sh`) and follow it.

## D. Study how a closed app works (APK analysis)

Decompiling or tracing someone else's app can violate copyright law, the app's licence terms, and the store terms; in Germany/EU
decompilation is only allowed narrowly (e.g. §69e UrhG, interoperability). Therefore:

- Ask the user to confirm **(1)** it is their own app, or open source, or they have the owner's permission, and **(2)** the purpose.
  No confirmation → stay in clean-room: use only what is visible (screenshots, store listing, behaviour the user describes).
- With confirmation, use the Android tools of `craft-anything` (`android-package-show`, `android-components-list`,
  `android-resources-read`, …) and Deep mode only for that target. Summarise findings as a **spec**, then rebuild as in path B –
  do not paste decompiled code into the new project.
- Never remove licence checks, DRM, ads or tamper with an app and re-sign it; never help redistribute modified third-party APKs.

## Report to the user

State which path was used, the licence situation, what was built, what was verified (see `android-app-dev` §4), and what the clone
does **not** replicate.
