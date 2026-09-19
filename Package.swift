// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "LalaTranslate", platforms: [.macOS(.v15)], products: [.executable(name: "LalaTranslate", targets: ["LalaTranslate"])], targets: [.executableTarget(name: "LalaTranslate"), .testTarget(name: "LalaTranslateTests", dependencies: ["LalaTranslate"])], swiftLanguageModes: [.v5])
