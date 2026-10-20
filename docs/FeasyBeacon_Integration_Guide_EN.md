# FeasyBeacon iOS Integration Guide

## Package

- [`FeasyBeacon/SDK/`](../FeasyBeacon/SDK) contains `libFeasyBeacon.a`, public headers, SuotaLib resources and Chinese/English interface PDFs.
- [`FeasyBeacon/CallbackSDK/`](../FeasyBeacon/CallbackSDK) contains the companion `libFeasyCallbackSDK.a` and its header.
- Both static libraries contain an arm64 iPhone device slice. Simulator slices and library implementation source are not included.

## Build the demo

Open `FeasyBeacon.xcworkspace`, select scheme `FeasyBeacon` and use a physical iPhone. Pods and the lockfile are included; run `pod install` from the repository root if reinstalling dependencies.

The app target requires iOS 12, version 2.1.8, build 20260917. Its Bundle ID is `com.feasycom.feasybeacon`. Use your own signing team and an available Bundle ID for device deployment. The app target requirement differs from the historical platform declared in the Podfile.

## Integrate the SDK

Add the required libraries, headers and resources to your application. Configure library/header search paths and linker options using the demo Build Settings as a reference. Import `FBSDKPublicHeader.h`.

`FBBluetoothBrowser` separates Beacon, Sensor and Setting scans through `FBBluetoothBrowserType`. Register `FBBluetoothBrowserDelegate` callbacks, wait for Bluetooth and permissions to become available, then call `startScanning`. Stop scanning with `stopScanning` when finished. Configure and request location permissions when required for iBeacon scanning.

Device configuration, sessions and upgrades are declared in `FBPeripheralManager.h`, `FBSession.h` and `FBUpgradeManager.h`. Follow the corresponding app code and use firmware matching the device model and upgrade requirements.

## Reference

- [English SDK interface PDF](<../FeasyBeacon/SDK/FBeacon_iOS-SDK Interface Document.pdf>)
- [Chinese SDK interface PDF](../FeasyBeacon/SDK/FBeacon_iOS_SDK接口文档.pdf)
- [Current public headers](../FeasyBeacon/SDK)
- [SDK revision notes](../FeasyBeacon/SDK/FBReadMe.md)

PDF documentation may describe an earlier SDK revision; check current public headers for exact method signatures. Repository packaging did not include a full app build or hardware functional tests.
