// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Luxe",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Luxe", targets: ["Luxe"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "7.0.0"
        )
    ],
    targets: [
        .target(
            name: "Luxe",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ],
            path: "Luxe"
        )
    ]
)
