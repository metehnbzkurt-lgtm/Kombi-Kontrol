name: Build APK

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Zip'i aç
        run: unzip -o kombi-app.zip -d app

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - name: Bağımlılıkları kur
        working-directory: app
        run: npm install

      - name: Android projesini oluştur
        working-directory: app
        run: npx cap add android

      - name: Yerel ağ (http) trafiğine izin ver
        working-directory: app
        run: sed -i 's/<application/<application android:usesCleartextTraffic="true"/' android/app/src/main/AndroidManifest.xml

      - name: Web dosyalarını eşitle
        working-directory: app
        run: npx cap sync android

      - name: APK derle
        working-directory: app/android
        run: |
          chmod +x gradlew
          ./gradlew assembleDebug

      - uses: actions/upload-artifact@v4
        with:
          name: kombi-kontrol-apk
          path: app/android/app/build/outputs/apk/debug/app-debug.apk
