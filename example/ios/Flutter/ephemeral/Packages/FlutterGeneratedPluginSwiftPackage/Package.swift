// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "package_info_plus", path: "/Users/matthewwhitaker/.pub-cache/hosted/pub.dev/package_info_plus-8.3.0/ios/package_info_plus"),
        .package(name: "video_player_avfoundation", path: "/Users/matthewwhitaker/.pub-cache/hosted/pub.dev/video_player_avfoundation-2.7.0/darwin/video_player_avfoundation"),
        .package(name: "webview_flutter_wkwebview", path: "/Users/matthewwhitaker/.pub-cache/hosted/pub.dev/webview_flutter_wkwebview-3.18.4/darwin/webview_flutter_wkwebview")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview")
            ]
        )
    ]
)
