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
