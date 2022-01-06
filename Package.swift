// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuiteGoodNetworking",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11),
        .watchOS(.v7)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "QuiteGoodNetworking",
            targets: ["QuiteGoodNetworking"]),
    ],
    dependencies: [.package(url: "https://github.com/Alamofire/Alamofire.git", .exact("5.4.4"))],
    targets: [.target(name: "QuiteGoodNetworking",
                      dependencies: ["Alamofire"],
                      path: "QuiteGoodNetworking/Classes",
                      publicHeadersPath: "QuiteGoodNetworking")],
    swiftLanguageVersions: [.v5]
)
