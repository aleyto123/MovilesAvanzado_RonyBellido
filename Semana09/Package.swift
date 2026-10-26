// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BoletaCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "BoletaCore", targets: ["BoletaCore"])],
    targets: [
        .target(name: "BoletaCore"),
        .testTarget(name: "BoletaCoreTests", dependencies: ["BoletaCore"])
    ]
)
