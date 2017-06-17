extension Classification {
    public static let Security = Classification(appleIdentifier: 1, name: "Security")
    public static let Crash = Classification(appleIdentifier: 2, name: "Crash/Hang/Data Loss")
    public static let Power = Classification(appleIdentifier: 3, name: "Power")
    public static let Performance = Classification(appleIdentifier: 4, name: "Performance")
    public static let UI = Classification(appleIdentifier: 5, name: "UI/Usability")
    public static let SeriousBug = Classification(appleIdentifier: 7, name: "Serious Bug")
    public static let OtherBug = Classification(appleIdentifier: 8, name: "Other Bug")
    public static let Feature = Classification(appleIdentifier: 10, name: "Feature (New)")
    public static let Enhancement = Classification(appleIdentifier: 11, name: "Enhancement")

    public static let All: [Classification] = [
        .Security, .Crash, .Power, .Performance, .UI, .SeriousBug, .OtherBug, .Feature, .Enhancement
    ]
}

extension Reproducibility {
    public static let Always = Reproducibility(appleIdentifier: 1, name: "Always")
    public static let Sometimes = Reproducibility(appleIdentifier: 2, name: "Sometimes")
    public static let Rarely = Reproducibility(appleIdentifier: 3, name: "Rarely")
    public static let Unable = Reproducibility(appleIdentifier: 4, name: "Unable")
    public static let DidntTry = Reproducibility(appleIdentifier: 5, name: "I didn't try")
    public static let NotApplicable = Reproducibility(appleIdentifier: 6, name: "Not Applicable")

    public static let All: [Reproducibility] = [
        .Always, .Sometimes, .Rarely, .Unable, .DidntTry, .NotApplicable
    ]
}

extension Area {
    private init(_ appleIdentifier: Int, _ name: String) {
        self.appleIdentifier = appleIdentifier
        self.name = name
    }

    public static func areas(for product: Product) -> [Area] {
        switch product {
        case Product.iOS:
            return self.AlliOSAreas
        case Product.macOS:
            return self.AllmacOSAreas
        case Product.tvOS:
            return self.AlltvOSAreas
        case Product.watchOS:
            return self.AllwatchOSAreas
        default:
            return []
        }
    }

    private static let AlliOSAreas: [Area] = [
        Area(1, "Accelerate Framework"), Area(2, "Accessibility"), Area(3, "Accounts Framework"),
        Area(4, "App Store"), Area(5, "App Switcher"), Area(6, "Audio"), Area(7, "Audio Toolbox"),
        Area(8, "AVFoundation"), Area(9, "AVKit"), Area(10, "Battery Life"), Area(11, "Bluetooth"),
        Area(12, "Calendar"), Area(13, "CallKit"), Area(14, "CarPlay"),
        Area(15, "Cellular Service (Calls / Data)"), Area(16, "CFNetwork Framework"), Area(17, "CloudKit"),
        Area(18, "Contacts"), Area(19, "Contacts Framework"), Area(20, "Control Center"),
        Area(21, "Core Animation"), Area(22, "Core Bluetooth"), Area(23, "Core Data"),
        Area(24, "Core Foundation"), Area(25, "Core Graphics"), Area(26, "Core Image"),
        Area(27, "Core Location"), Area(28, "Core Media"), Area(29, "Core Motion"),
        Area(30, "Core Spotlight"), Area(31, "Core Telephony Framework"), Area(32, "Core Video"),
        Area(33, "EventKit"), Area(34, "External Accessory Framework"), Area(35, "FaceTime"),
        Area(36, "Foundation"), Area(37, "GameplayKit"), Area(38, "GLKit"), Area(39, "Health App"),
        Area(40, "HealthKit"), Area(41, "Home App"), Area(42, "Home Screen"), Area(43, "HomeKit"),
        Area(44, "iCloud"), Area(45, "Image I/O"), Area(46, "Intents Framework"), Area(47, "IOKit"),
        Area(48, "iPod Accessory Protocol (iAP)"), Area(49, "iTunes Connect"), Area(50, "iTunes Store"),
        Area(51, "Keyboard"), Area(52, "Local Authentication Framework"), Area(53, "Location Services"),
        Area(54, "Lock Screen"), Area(55, "Mail"), Area(56, "MapKit"), Area(57, "Maps"), Area(58, "MDM"),
        Area(59, "Media Player Framework"), Area(60, "Messages"), Area(61, "Messages Framework"),
        Area(62, "Metal"), Area(63, "Model I/O"), Area(64, "Multipeer Connectivity Framework"),
        Area(65, "Music"), Area(66, "Network Extensions Framework"), Area(67, "Notes"),
        Area(68, "Notification Center"), Area(69, "NotificationCenter Framework"), Area(70, "Notifications"),
        Area(71, "PassKit"), Area(72, "Phone App"), Area(73, "Photos"), Area(74, "Photos Framework"),
        Area(75, "Profiles"), Area(76, "PushKit"), Area(77, "QuickLook Framework"), Area(78, "Reminders"),
        Area(79, "ReplayKit"), Area(80, "Safari"), Area(81, "Safari Services"), Area(82, "SceneKit"),
        Area(83, "Security Framework"), Area(84, "Setup Assistant"), Area(85, "Simulator"), Area(86, "Siri"),
        Area(87, "Social Framework"), Area(88, "Software Update"), Area(89, "Spotlight"),
        Area(90, "SpriteKit"), Area(91, "StoreKit"), Area(92, "System Slow/Unresponsive"),
        Area(93, "SystemConfiguration Framework"), Area(94, "TouchID"), Area(95, "UIKit"),
        Area(96, "UserNotifications Framework"), Area(97, "VPN"), Area(98, "Wallet"), Area(99, "WebKit"),
        Area(100, "Wi-Fi"), Area(101, "Xcode"), Area(102, "Something not on this list"),
    ]

    private static let AllmacOSAreas: [Area] = [
        Area(1, "Accessibility"), Area(2, "Airplay"), Area(3, "APNS"), Area(4, "App Store"),
        Area(5, "AppKit"), Area(6, "Automation"), Area(7, "Battery"), Area(8, "Bluetooth"),
        Area(9, "Calendar"), Area(10, "Contacts"), Area(11, "Core Graphics"), Area(12, "Developer Web Site"),
        Area(13, "Disk Utility"), Area(14, "Dock"), Area(15, "Documentation"), Area(16, "FaceTime"),
        Area(17, "Final Cut Pro"), Area(18, "Finder"), Area(19, "Graphics & Imaging"),
        Area(20, "iBooks / Author"), Area(21, "iCloud / CloudKit"), Area(22, "Installation"),
        Area(23, "iTunes"), Area(24, "iTunes Connect"), Area(25, "Java"),
        Area(26, "Keyboards, mice and trackpads"), Area(27, "Keynote, Numbers & Pages"),
        Area(28, "Launchpad"), Area(29, "Localization"), Area(30, "Logic Pro X"), Area(31, "Mail"),
        Area(32, "Maps"), Area(33, "Menu Bar"), Area(34, "Messages"), Area(35, "Mission Control"),
        Area(36, "Networking"), Area(37, "News Publisher"), Area(38, "Notes"), Area(39, "Numbers"),
        Area(40, "Performance (slow, hung"), Area(41, "Photos"), Area(42, "Preferences"), Area(43, "Preview"),
        Area(44, "Printing & Faxing"), Area(45, "Reminders"), Area(46, "Safari"), Area(47, "App Sandbox"),
        Area(48, "Screen Saver & desktop"), Area(49, "Server (macOS Server"), Area(50, "Setup Assistant"),
        Area(51, "Software Update"), Area(52, "Spaces"), Area(53, "Spotlight"), Area(54, "Swift"),
        Area(55, "Terminal"), Area(56, "Time Machine"), Area(57, "Wi-Fi"), Area(58, "Xcode"),
        Area(59, "Something not on this list"),
    ]

    private static let AlltvOSAreas: [Area] = [
        Area(1, "Accessibility"), Area(2, "Accounts"), Area(3, "AirPlay"), Area(4, "App Store"),
        Area(5, "App Switcher"), Area(6, "AV Playback"), Area(7, "Bluetooth"),
        Area(8, "Device Management / Profiles"), Area(9, "Display"), Area(10, "Home Screen"),
        Area(11, "Movies / TV Shows"), Area(12, "Music"), Area(13, "Networking"), Area(14, "Photos"),
        Area(15, "Remote.app Support"), Area(16, "Setup (includes Tap Setup"), Area(17, "Screensaver"),
        Area(18, "Search"), Area(19, "Settings"), Area(20, "Siri"), Area(21, "Software Update"),
        Area(22, "SSO"), Area(23, "System, General"), Area(24, "TV App"), Area(25, "TVML Apps"),
        Area(26, "tvOS SDK"),
    ]

    private static let AllwatchOSAreas: [Area] = [
        Area(1, "Accessibility"), Area(2, "Activity"), Area(3, "Battery Life"), Area(4, "Bluetooth"),
        Area(5, "Calendar"), Area(6, "Contacts"), Area(7, "Control Center"), Area(8, "Dock"),
        Area(9, "HealthKit"), Area(10, "HomeKit"), Area(11, "Maps"), Area(12, "Messages"), Area(13, "Music"),
        Area(14, "Notification Center"), Area(15, "Notifications"), Area(16, "Setup and Pairing"),
        Area(17, "Simulator"), Area(18, "Siri"), Area(19, "Syncing"), Area(20, "Wallet"),
        Area(21, "Watch Faces"), Area(22, "WatchKit"), Area(23, "Workout"), Area(24, "Xcode"),
    ]
}

extension Product {
    private init(_ appleIdentifier: Int, _ name: String, _ category: String) {
        self.appleIdentifier = appleIdentifier
        self.category = category
        self.name = name
    }

    public static let iOS = Product(579020, "iOS + SDK", "OS and Development")
    public static let macOS = Product(137701, "macOS + SDK", "OS and Development")
    public static let macOSServer = Product(84100, "Server", "OS and Development")
    public static let tvOS = Product(660932, "tvOS + SDK", "OS and Development")
    public static let watchOS = Product(645251, "watchOS + SDK", "OS and Development")
    public static let DeveloperTools = Product(175326, "Developer Tools", "OS and Development")
    public static let Documentation = Product(183045, "Documentation", "OS and Development")
    public static let iTunesConnect = Product(500515, "iTunes Connect", "OS and Development")
    public static let ParallaxPreviewer = Product(720650, "Parallax Previewer", "OS and Development")
    public static let SampleCode = Product(205728, "Sample Code", "OS and Development")
    public static let TechNote = Product(385563, "Tech Note/Q&A", "OS and Development")
    public static let iBooks = Product(571983, "iBooks", "Applications and Software")
    public static let iCloud = Product(458288, "iCloud", "Applications and Software")
    public static let iLife = Product(445858, "iLife", "Applications and Software")
    public static let iTunes = Product(430173, "iTunes", "Applications and Software")
    public static let iWork = Product(372025, "iWork", "Applications and Software")
    public static let Mail = Product(372031, "Mail", "Applications and Software")
    public static let ProApps = Product(175412, "Pro Apps", "Applications and Software")
    public static let QuickTime = Product(84201, "QuickTime", "Applications and Software")
    public static let Safari = Product(175305, "Safari", "Applications and Software")
    public static let SafariBeta = Product(697770, "Safari Technology Preview", "Applications and Software")
    public static let Siri = Product(750751, "Siri", "Applications and Software")
    public static let SwiftPlaygrounds = Product(743970, "Swift Playgrounds", "Applications and Software")
    public static let AppleTV = Product(430025, "Apple TV", "Hardware")
    public static let iPad = Product(375383, "iPad", "Hardware")
    public static let iPhone = Product(262954, "iPhone/iPod touch", "Hardware")
    public static let iPod = Product(185585, "iPod", "Hardware")
    public static let Mac = Product(213680, "Mac", "Hardware")
    public static let Printing = Product(213679, "Printing/Fax", "Hardware")
    public static let OtherHardware = Product(657117, "Other Hardware", "Hardware")
    public static let CarPlayAccessoryCert = Product(571212, "CarPlay Accessory Certification", "Hardware")
    public static let HomeKitAccessoryCert = Product(601986, "HomeKit Accessory Certification", "Hardware")
    public static let Accessibility = Product(437784, "Accessibility", "Other")
    public static let AppStore = Product(251822, "App Store", "Other")
    public static let MacAppStore = Product(430023, "Mac App Store", "Other")
    public static let BugReporter = Product(242322, "Bug Reporter", "Other")
    public static let iAdNetwork = Product(445860, "iAd Network", "Other")
    public static let iAdProducer = Product(446084, "iAd Producer", "Other")
    public static let Java = Product(84060, "Java", "Other")
    public static let Other = Product(20206, "Other", "Other")

    public static let All: [Product] = [
        .iOS, .macOS, .macOSServer, .tvOS, .watchOS,
        .DeveloperTools, .Documentation, .iTunesConnect, .ParallaxPreviewer, .SampleCode, .TechNote,
        .iBooks, .iCloud, .iLife, .iTunes, .iWork, .Mail, .ProApps, .QuickTime, .Safari, .SafariBeta, .Siri,
        .SwiftPlaygrounds, .AppleTV, .iPad, .iPhone, .iPod, .Mac, .Printing, .OtherHardware,
        .CarPlayAccessoryCert, .HomeKitAccessoryCert, .Accessibility, .AppStore, .MacAppStore, .BugReporter,
        .iAdNetwork, .iAdProducer, .Java, .Other,
    ]
}
