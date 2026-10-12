name: Maya App Release & Deployment Pipeline

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  build-and-deploy:
    name: Build Signed Release APK & Deploy
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Java JDK (Version 17)
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.x'
          channel: 'stable'
          cache: true

      - name: Decode Android Release Keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/release.jks
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=release.jks" >> android/key.properties

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Unit & Integration Tests
        run: flutter test

      - name: Build Release APK
        run: flutter build apk --release --split-per-abi

      - name: Package Release Artifacts
        run: |
          mkdir -p build/deploy
          cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk build/deploy/maya-redmi-arm64-v${{ github.ref_name }}.apk

      - name: Upload Artifacts to GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/deploy/maya-redmi-arm64-v${{ github.ref_name }}.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Deploy Manifest to Maya Telemetry Server
        run: |
          curl -X POST https://api.maya-care.com/v1/admin/deploy-manifest \
            -H "Authorization: Bearer ${{ secrets.MAYA_API_SECRET }}" \
            -H "Content-Type: application/json" \
            -d '{
              "version": "${{ github.ref_name }}",
              "apk_url": "https://github.com/${{ github.repository }}/releases/download/${{ github.ref_name }}/maya-redmi-arm64-v${{ github.ref_name }}.apk",
              "mandatory_update": false
            }'