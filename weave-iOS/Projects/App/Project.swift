import ProjectDescription

let prodTarget = Target(
    name: "weave-ios-prod",
    platform: .iOS,
    product: .app,
    bundleId: "com.studentcenter.weaveios",
    deploymentTarget: .iOS(targetVersion: "17.0",
                           devices: .iphone,
                           supportsMacDesignedForIOS: false),
    infoPlist: .file(path: "Support/weave-ios-Info.plist"),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    entitlements: .file(path: .relativeToCurrentFile("weave-ios.entitlements")),
    dependencies: [
        .project(target: "Services",
                 path: .relativeToRoot("Projects/Core")),
        .project(target: "DesignSystem",
                 path: .relativeToRoot("Projects/DesignSystem")),
        .package(product: "ComposableArchitecture", type: .macro),
        .package(product: "KakaoSDKCommon", type: .macro),
        .package(product: "KakaoSDKAuth", type: .macro),
        .package(product: "KakaoSDKUser", type: .macro),
        .package(product: "KakaoSDKShare", type: .macro),
        .package(product: "KakaoSDKTemplate", type: .macro),
    ],
    settings: .settings(
        base: setEnviroment(to: .prod)
    )
)

let devTarget = Target(
    name: "weave-ios-dev",
    platform: .iOS,
    product: .app,
    bundleId: "com.studentcenter.weaveios",
    deploymentTarget: .iOS(targetVersion: "17.0",
                           devices: .iphone,
                           supportsMacDesignedForIOS: false),
    infoPlist: .file(path: "Support/weave-ios-Info.plist"),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    entitlements: .file(path: .relativeToCurrentFile("weave-ios.entitlements")),
    dependencies: [
        .project(target: "Services",
                 path: .relativeToRoot("Projects/Core")),
        .project(target: "DesignSystem",
                 path: .relativeToRoot("Projects/DesignSystem")),
        .package(product: "ComposableArchitecture", type: .macro),
        .package(product: "KakaoSDKCommon", type: .macro),
        .package(product: "KakaoSDKAuth", type: .macro),
        .package(product: "KakaoSDKUser", type: .macro),
        .package(product: "KakaoSDKShare", type: .macro),
        .package(product: "KakaoSDKTemplate", type: .macro),
    ],
    settings: .settings(
        base: setEnviroment(to: .dev)
    )
)

public enum AppEnviroment: String {
    case dev
    case prod
}

public func setEnviroment(to env: AppEnviroment) -> SettingsDictionary {
    return .init(dictionaryLiteral: ("AppEnviroment", .string(env.rawValue)))
}

let project = Project(
    name: "Weave-ios",
    organizationName: nil,
    options: .options(),
    packages: [
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            requirement: .exact("1.7.2")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .branch("master"))
    ],
    settings: nil,
    targets: [prodTarget, devTarget],
    schemes: [],
    fileHeaderTemplate: nil,
    additionalFiles: [],
    resourceSynthesizers: []
)
