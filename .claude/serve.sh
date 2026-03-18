#!/usr/bin/env bash
export PORT="${PORT:-5500}"
exec "/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" \
  -ExecutionPolicy Bypass \
  -File "$(dirname "$0")/serve.ps1"
