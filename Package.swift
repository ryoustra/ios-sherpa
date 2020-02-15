// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Sherpa",
	platforms: [.iOS("8.4")],
    products: [
        .library(name: "Sherpa", targets: ["Sherpa"])
    ],
    targets: [
        .target(
            name: "Sherpa",
			dependencies: [],
            path: "src/Sherpa"
        )
    ]
)
