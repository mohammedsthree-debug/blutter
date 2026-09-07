# Blutter CI - Oxford Dictionary Flutter Analysis

Automated Blutter reverse engineering pipeline for Flutter apps, running on GitHub Actions.

## Setup

1. Create a new GitHub repo (private recommended)
2. Copy this entire directory to it
3. Place your Flutter app's native libraries in `libs/`:
   - `libs/libapp.so`
   - `libs/libflutter.so`
4. Push and trigger the workflow

## Quick Start

```bash
# This script does it all — just set your GitHub username
./setup_and_push.ps1
```

## What It Does

1. **Compiles Blutter** from source on Ubuntu with g++-13 + cmake + ninja
2. **Analyzes `libapp.so`** to reconstruct Dart classes, methods, and function offsets
3. **Auto-greps** for licensing/premium/purchase/subscription symbols
4. **Uploads artifacts**:
   - `blutter-analysis-*` — Full analysis archive
   - `blutter-asm-*` — Reconstructed Dart ASM files
   - `blutter-frida-*` — Auto-generated Frida hook scripts

## Files

- `.github/workflows/blutter_analysis.yml` — CI workflow
- `libs/` — Place libapp.so + libflutter.so here
- `.gitattributes` — LFS config for large .so files
