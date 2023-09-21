// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  GrowingToolsKit
//
//  Created by YoloMao on 2022/11/28.
//  Copyright (C) 2022 Beijing Yishu Technology Co., Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import PackageDescription

let package = Package(
    name: "GrowingToolsKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "GrowingToolsKit",
            targets: ["GrowingToolsKit"]
        ),
        .library(
            name: "GrowingToolsKit_UseInRelease",
            targets: ["GrowingToolsKit", "GrowingToolsKit_UseInRelease"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/growingio/growingio-sdk-ios-performance-ext.git",
            "0.0.15" ..< "1.0.0"
        ),
    ],
    targets: [
        
        // MARK: - GrowingToolsKit Wrapper
        
        .target(
            name: "GrowingToolsKit",
            dependencies: [
                "GrowingToolsKit_Core",
                "GrowingToolsKit_Plugin_SDKInfo",
                "GrowingToolsKit_Plugin_EventsList",
                "GrowingToolsKit_Plugin_XPathTrack",
                "GrowingToolsKit_Plugin_NetFlow",
                "GrowingToolsKit_Plugin_Realtime",
                "GrowingToolsKit_Plugin_CrashMonitor",
                "GrowingToolsKit_Plugin_LaunchTime",
                "GrowingToolsKit_Plugin_Settings",
            ],
            path: "Sources/GrowingToolsKit",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("../Core"),
            ]
        ),
        
        // MARK: - GrowingToolsKit Core
        
        .target(
            name: "GrowingToolsKit_Core",
            dependencies: [],
            path: "Sources/Core",
            exclude: ["UseInRelease/GrowingTKUseInRelease.m"],
            resources: [
                .process("Resources/gio_hybrid.min.js"),
                .process("Resources/giokit_touch.js"),
            ],
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Categories/Foundation"),
                .headerSearchPath("Categories/UIKit"),
                .headerSearchPath("Database"),
                .headerSearchPath("Database/FMDB"),
                .headerSearchPath("PluginCore"),
                .headerSearchPath("Tools"),
                .headerSearchPath("UserInterface"),
                .headerSearchPath("UserInterface/Base/Controller"),
                .headerSearchPath("UserInterface/Base/View"),
                .headerSearchPath("UserInterface/Home"),
                .headerSearchPath("UserInterface/PluginsList"),
                .headerSearchPath("UserInterface/PluginsList/View"),
                .headerSearchPath("UserInterface/SDKCheck"),
                .headerSearchPath("UserInterface/SDKCheck/View"),
            ]
        ),

        // MARK: - GrowingToolsKit Plugins

        .target(
            name: "GrowingToolsKit_Plugin_SDKInfo",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/SDKInfo",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/UserInterface/Base/View"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_Plugin_EventsList",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/EventsList",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("Database"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/Foundation"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/Database"),
                .headerSearchPath("../Core/Database/FMDB"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/UserInterface/Base/View"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_Plugin_XPathTrack",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/XPathTrack",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("Node"),
                .headerSearchPath("Node/WebView"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/Foundation"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_Plugin_NetFlow",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/NetFlow",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("CustomURLProtocol"),
                .headerSearchPath("Database"),
                .headerSearchPath("Util"),
                .headerSearchPath("Util/LZ4"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/Database"),
                .headerSearchPath("../Core/Database/FMDB"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/UserInterface/Base/View"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_Plugin_Realtime",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/Realtime",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/Bubble"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("Util"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/Foundation"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/UserInterface/Base/View"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_APMCore",
            dependencies: [
                "GrowingToolsKit_Core",
                .product(name: "GrowingAPMCore", package: "growingio-sdk-ios-performance-ext"),
            ],
            path: "Sources/APMCore",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/Foundation"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_Plugin_CrashMonitor",
            dependencies: [
                "GrowingToolsKit_APMCore",
                .product(name: "GrowingAPMCrashMonitor", package: "growingio-sdk-ios-performance-ext"),
            ],
            path: "Sources/CrashMonitor",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("Database"),
                .headerSearchPath("../APMCore"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/Foundation"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/Database"),
                .headerSearchPath("../Core/Database/FMDB"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/UserInterface/Base/View"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),
        .target(
            name: "GrowingToolsKit_Plugin_LaunchTime",
            dependencies: [
                "GrowingToolsKit_APMCore",
                .product(name: "GrowingAPMUIMonitor", package: "growingio-sdk-ios-performance-ext"),
            ],
            path: "Sources/LaunchTime",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("Database"),
                .headerSearchPath("../APMCore"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/Foundation"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/Database"),
                .headerSearchPath("../Core/Database/FMDB"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/UserInterface/Base/View"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),

        // MARK: - GrowingToolsKit Settings

        .target(
            name: "GrowingToolsKit_Plugin_Settings",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/Settings",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Controller"),
                .headerSearchPath("Controller/View"),
                .headerSearchPath("../Core"),
                .headerSearchPath("../Core/Categories/UIKit"),
                .headerSearchPath("../Core/PluginCore"),
                .headerSearchPath("../Core/UserInterface/Base/Controller"),
                .headerSearchPath("../Core/Tools"),
            ]
        ),

        // MARK: - GrowingToolsKit Use In Release

        .target(
            name: "GrowingToolsKit_UseInRelease",
            dependencies: [
                "GrowingToolsKit_Core",
            ],
            path: "Sources/Core/UseInRelease",
            sources: ["GrowingTKUseInRelease.m"],
            cSettings: [
                .headerSearchPath(".."),
                .headerSearchPath("../Categories/UIKit"),
                .headerSearchPath("../Tools"),
            ]
        ),
    ]
)
