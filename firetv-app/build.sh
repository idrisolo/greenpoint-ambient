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
