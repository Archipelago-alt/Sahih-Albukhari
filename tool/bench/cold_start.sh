#!/usr/bin/env bash
# Startup measurement on a connected Android device or emulator.
#
#   flutter build apk --release --split-per-abi
#   tool/bench/cold_start.sh            # x86_64 APK on emulator-5554
#   ABI=arm64-v8a DEVICE=<serial> tool/bench/cold_start.sh
#
# Installs the release APK (replacing any build with the same package name),
# times the first launch after clearing app data (which copies and
# SHA-256-checks the content database) and five ordinary cold starts.
# Prints raw numbers; nothing is estimated. Results: docs/PERFORMANCE.md.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
ADB="${ADB:-${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb}"
DEVICE="${DEVICE:-emulator-5554}"
ABI="${ABI:-x86_64}"
PKG=io.github.archipelagoalt.sahih_albukhari
ACT="$PKG/.MainActivity"
APK="$REPO/build/app/outputs/flutter-apk/app-$ABI-release.apk"
DUMP=/sdcard/window_dump.xml

[ -f "$APK" ] || { echo "FAIL: $APK not found (build with --split-per-abi first)"; exit 3; }
"$ADB" -s "$DEVICE" get-state >/dev/null 2>&1 || { echo "FAIL: device $DEVICE not available"; exit 4; }
A() { "$ADB" -s "$DEVICE" "$@"; }

A uninstall "$PKG" >/dev/null 2>&1
A install -r "$APK" 2>&1 | tail -1 | grep -q Success || { echo "FAIL: install failed"; A install -r "$APK" 2>&1 | tail -3; exit 5; }
echo "installed: $(basename "$APK") ($(stat -c %s "$APK") bytes)"
sleep 3

total_time() { A shell am start -W -n "$ACT" 2>/dev/null | tr -d '\r' | awk -F': ' '/^TotalTime/ {print $2}'; }

# Wait (approximately, ~1 s granularity) until the home screen's «الكتب» is
# on screen. uiautomator reads Flutter's semantics tree.
wait_home() {
  local start=$1
  for _ in $(seq 1 60); do
    A shell uiautomator dump "$DUMP" >/dev/null 2>&1
    if A shell cat "$DUMP" 2>/dev/null | grep -q 'الكتب'; then
      echo $(( $(date +%s%3N) - start ))
      return 0
    fi
    sleep 0.5
  done
  echo "not-detected"
}

# 1. First launch after clearing app data: copies and verifies the database.
A shell pm clear "$PKG" >/dev/null 2>&1
t0=$(date +%s%3N)
first=$(total_time)
home=$(wait_home "$t0")
echo "first launch: am-start TotalTime=${first:-n/a} ms; home screen visible after ~${home} ms (wall clock, includes polling)"

# App data size after the first launch (needs root, e.g. a non-Google emulator image).
if A root >/dev/null 2>&1 && sleep 2 && A shell du -sk "/data/data/$PKG" >/dev/null 2>&1; then
  echo "app data after first launch: $(A shell du -sk "/data/data/$PKG" | tr -d '\r' | awk '{print $1}') KiB"
else
  echo "app data size: not measured (no root)"
fi

# 2. Five ordinary cold starts (database already installed).
vals=()
for i in 1 2 3 4 5; do
  A shell am force-stop "$PKG"
  sleep 2
  v=$(total_time)
  echo "cold start $i: TotalTime=${v:-n/a} ms"
  [ -n "$v" ] && vals+=("$v")
  sleep 3
done
if [ ${#vals[@]} -gt 0 ]; then
  printf '%s\n' "${vals[@]}" | sort -n | awk '{a[NR]=$1} END {print "cold start median: " a[int((NR+1)/2)] " ms (n=" NR ")"}'
fi
A shell am force-stop "$PKG"
