#!/bin/bash
# Builds greenpoint-ambient.apk without Gradle. Requires: Homebrew openjdk, android-commandlinetools
# with "platforms;android-30" and "build-tools;34.0.0".
set -euo pipefail
cd "$(dirname "$0")"
export JAVA_HOME=${JAVA_HOME:-/opt/homebrew/opt/openjdk}
export PATH="$JAVA_HOME/bin:$PATH"
SDK=${ANDROID_SDK_ROOT:-/opt/homebrew/share/android-commandlinetools}
BT=$SDK/build-tools/34.0.0
JAR=$SDK/platforms/android-30/android.jar
OUT=build
rm -rf $OUT && mkdir -p $OUT/res $OUT/classes $OUT/dex

# Private settings live in git-ignored files, so they never reach the public repo:
#   personal.txt  first line: your first name (for greetings)
#   private.txt   key=value lines: tm=<Ticketmaster key>, wifi_ssid=..., wifi_pass=..., wifi_type=WPA
# They are baked into the app and passed to the page after "#", which browsers never send to a server.
mkdir -p $OUT/gen/com/greenpoint/ambient
python3 -I - "$OUT/gen/com/greenpoint/ambient/Personal.java" <<'PY'
import sys, json, urllib.parse, os
vals = {}
if os.path.exists("personal.txt"):
    n = open("personal.txt").readline().strip()
    if n: vals["name"] = n
if os.path.exists("private.txt"):
    for line in open("private.txt"):
        if "=" in line and not line.lstrip().startswith("#"):
            k, v = line.rstrip("\n").split("=", 1)
            key = {"tm": "tm", "wifi_ssid": "ws", "wifi_pass": "wp", "wifi_type": "wt"}.get(k.strip())
            if key and v.strip(): vals[key] = v.strip()
frag = "&".join(k + "=" + urllib.parse.quote(v, safe="") for k, v in vals.items())
open(sys.argv[1], "w").write("package com.greenpoint.ambient;\nfinal class Personal { static final String FRAGMENT = %s; }\n" % json.dumps(frag))
print("Private settings included:", ", ".join(sorted(vals)) or "none")
PY

$BT/aapt2 compile --dir res -o $OUT/res.zip
$BT/aapt2 link -o $OUT/unsigned.apk -I $JAR --manifest AndroidManifest.xml $OUT/res.zip --java $OUT/gen
javac -nowarn -source 8 -target 8 -bootclasspath $JAR -classpath $JAR -d $OUT/classes \
  $(find src $OUT/gen -name '*.java') 2>&1 | grep -v "warning:" || true
$BT/d8 --min-api 22 --lib $JAR --output $OUT/dex $(find $OUT/classes -name '*.class')
cp $OUT/unsigned.apk $OUT/with-dex.apk
(cd $OUT/dex && zip -q ../with-dex.apk classes.dex)
$BT/zipalign -f 4 $OUT/with-dex.apk $OUT/aligned.apk

KS=${KEYSTORE:-$HOME/.android/greenpoint-ambient.jks}
if [ ! -f "$KS" ]; then
  mkdir -p "$(dirname "$KS")"
  keytool -genkeypair -keystore "$KS" -alias ambient -keyalg RSA -keysize 2048 -validity 20000 \
    -storepass ambient-local -keypass ambient-local -dname "CN=Greenpoint Ambient" >/dev/null 2>&1
fi
$BT/apksigner sign --ks "$KS" --ks-pass pass:ambient-local --key-pass pass:ambient-local \
  --out greenpoint-ambient.apk $OUT/aligned.apk
$BT/apksigner verify greenpoint-ambient.apk && echo "Built $(pwd)/greenpoint-ambient.apk"
