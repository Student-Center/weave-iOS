import ProjectDescription

let Services = Target(
    name: "Services",
    platform: .iOS,
    product: .staticFramework,
    bundleId: "com.studentcenter.weaveios.services",
    deploymentTarget: .iOS(targetVersion: "17.0",
                           devices: .iphone,
                           supportsMacDesignedForIOS: false),
    sources: ["Sources/Network/**"],
    dependencies: [
        .project(target: "CoreKit",
                 path: .relativeToRoot("Projects/Core")),
    ]
)

let CoreKit = Target(
    name: "CoreKit",
    platform: .iOS,
    product: .staticFramework,
    bundleId: "com.studentcenter.weaveios.corekit",
    deploymentTarget: .iOS(targetVersion: "17.0",
                           devices: .iphone,
                           supportsMacDesignedForIOS: false),
    sources: ["Sources/CoreKit/**"],
    dependencies: []
)

let project = Project(
    name: "Core",
    organizationName: nil,
    options: .options(),
    packages: [],
    settings: nil,
    targets: [Services, CoreKit],
    schemes: [],
    fileHeaderTemplate: nil,
    additionalFiles: [],
    resourceSynthesizers: []
)

