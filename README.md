# SwiftWebAssembly [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/therealbnut/SwiftWebAssembly/master/LICENSE.md) [![GitHub release](https://img.shields.io/github/release/therealbnut/SwiftWebAssembly.svg)](https://github.com/therealbnut/SwiftWebAssembly/releases)

SwiftWebAssembly has one purpose, to load WebAssembly compiled modules and exposes them to Swift.

## Example

```swift
import SwiftWebAssembly
import JavaScriptCore

let context = JSContext()
let file = URL(fileURLWithPath: "example.wasm")
let data = try! Data(contentsOf: file)

context.loadWebAssemblyModule(
    data: data,
    success: { exports in
        let result = exports?["add"]?.call(withArguments: [1, 2])
        print("result: \(result)") // result: 3
    },
    failure: { error in
        print("oh no!")
    })
```

## Integration

### Swift Package Manager

The package can be installed through SwiftPM.

```swift
  .package(url: "git@github.com:therealbnut/SwiftWebAssembly.git", from: "0.1.0"),
```

A more complete example:

```swift
// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyPackage",
    products: [
        .library(name: "MyProduct", targets: ["MyTarget"]),
    ],
    dependencies: [
        .package(url: "git@github.com:therealbnut/SwiftWebAssembly.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "MyTarget", dependencies: ["SwiftWebAssembly"])
    ]
)
```

### Carthage

Add SwiftWebAssembly to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).
