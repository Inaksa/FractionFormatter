import Foundation

extension Int {
    static let inchesInMile: Int = 63360
    static let inchesInYard: Int = 32
    static let inchesInFoot: Int = 12
}

// swiftlint:disable all
class FractionsFormatter: Formatter {
    private enum Configuration {
        // [Millimeter: InchFraction]
        static let convertions: [Double: String] = [
            0.12500: "1/8",
            0.25000: "1/4",
            0.37500: "3/8",
            0.50000: "1/2",
            0.62500: "5/8",
            0.75000: "3/4",
            0.87500: "7/8",
        ]

        static let fractions: [String: String] = [
            "1/8": "\u{215B}",
            "1/4": "\u{BC}",
            "3/8": "\u{215C}",
            "1/2": "\u{BD}",
            "5/8": "\u{215D}",
            "3/4": "\u{BE}",
            "7/8": "\u{215E}",
        ]

        static func representationFor(unit: UnitLength) -> String {
            if unit == UnitLength.inches {
                return "in"
            }

            return unit.symbol
        }

        static let defaultPrecision: Int = 4

        static var minFraction: Double {
            if let key = convertions.keys.sorted().first {
                return key
            } else {
                return 0
            }
        }

        static var maxFraction: Double {
            if let key = convertions.keys.sorted().last {
                return key
            } else {
                return 1
            }
        }
    }

    private let formatter = NumberFormatter()

    var allowZero: Bool = true
    var allowMultipleUnits: Bool = false
    var useFractions: Bool = true

    override init() {
        super.init()
        formatter.minimumFractionDigits = Configuration.defaultPrecision
        formatter.maximumFractionDigits = Configuration.defaultPrecision
        formatter.minimumIntegerDigits = 1
    }

    convenience init(allowZero: Bool = true, useFractions: Bool = true) {
        self.init()
        self.allowZero = allowZero
        self.useFractions = useFractions
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(for obj: Any?) -> String? {
        guard let localObject = obj as? Double else { return nil }

        var components: [String] = []
        var intPart = Int(floor(localObject))
        var fractionPart = localObject - Double(intPart)

        let prevFraction: Double = Configuration.convertions
            .keys
            .sorted()
            .reversed()
            .first(where: { $0 < fractionPart }) ?? Configuration.minFraction
        let nextFraction: Double = Configuration.convertions
            .keys
            .sorted()
            .first(where: { $0 > fractionPart }) ?? Configuration.maxFraction

        if Configuration.convertions[fractionPart] == nil {
            if fractionPart > nextFraction {
                intPart += 1
                fractionPart = 0
            } else if fractionPart < prevFraction {
                if fractionPart > 0 {
                    fractionPart = (prevFraction == Configuration.minFraction ? 0 : prevFraction)
                } else {
                    fractionPart = 0
                }
            }
        }

        let decPartRepresentation = handleDecimal(fractionPart)
        var intPartRepresentation = handleInteger(intPart, hasDecimal: decPartRepresentation.count > 0)

        // Remove inches at the end of the integer part if there is a fraction.
        if let last = intPartRepresentation.last,
           last.hasSuffix(Configuration.representationFor(unit: .inches)),
           (decPartRepresentation.first?.count ?? 0) > 0 {
            _ = intPartRepresentation.popLast()
            intPartRepresentation.append(
                last.replacingOccurrences(
                    of: Configuration.representationFor(unit: .inches),
                    with: ""
                )
            )
        }

        components.append(contentsOf: intPartRepresentation)
        components.append(contentsOf: decPartRepresentation)

        var retValue = components.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        if let lastChar = retValue.last,
           ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(lastChar) {
            retValue.append(Configuration.representationFor(unit: .inches))
        }

        return retValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    override func getObjectValue(
        _: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for _: String,
        errorDescription _: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        false
    }

    func representationFor(unit: UnitLength) -> String {
        Configuration.representationFor(unit: unit)
    }

    private func removeFrom(_ value: String, units: [String]) -> String {
        var retValue = value

        units.forEach {
            retValue = retValue.replacingOccurrences(of: $0, with: "")
        }

        return retValue
    }

    private func handleInteger(_ value: Int, hasDecimal _: Bool) -> [String] {
        var retValue: [String] = []
        var myCopy = value
        var extractedFeet = false

        if (myCopy / Int.inchesInFoot) >= 1 {
            let feet = Int(myCopy / Int.inchesInFoot)
            retValue.append("\(feet)\(Configuration.representationFor(unit: .feet))")
            myCopy -= (feet * Int.inchesInFoot)
            extractedFeet = true
        }

        if myCopy == 0 {
            if !extractedFeet {
                retValue.append("\(myCopy)\(Configuration.representationFor(unit: .inches))")
            }
            return retValue
        }

        guard allowMultipleUnits else {
            retValue.append("\(myCopy)\(Configuration.representationFor(unit: .inches))")
            return retValue
        }

        let data: [Int: String] = [
            // Int.inchesInMile: Configuration.representationFor(unit: .miles),
            // Int.inchesInYard: Configuration.representationFor(unit: .yards),
            Int.inchesInFoot: Configuration.representationFor(unit: .feet),
        ]

        var conversionRatios: [Int] = []

        if allowMultipleUnits {
            // conversionRatios.append(Int.inchesInMile)
            // conversionRatios.append(Int.inchesInYard)
            conversionRatios.append(Int.inchesInFoot)
        }

        conversionRatios = conversionRatios.sorted().reversed()

        conversionRatios.forEach { key in
            let result = myCopy / key
            if result >= 1, let value = data[key] {
                retValue.append("\(result)\(value)")
                myCopy -= (result * key)
            }
        }

        if let lastRatio = conversionRatios.last,
           myCopy < lastRatio {
            if allowZero {
                retValue.append("\(myCopy)\(Configuration.representationFor(unit: .inches))")
            } else {
                if myCopy > 0 {
                    retValue.append("\(myCopy)\(Configuration.representationFor(unit: .inches))")
                }
            }
        }

        return retValue
    }

    private func handleDecimal(_ fractionPart: Double) -> [String] {
        guard fractionPart > 0 else { return [""] }

        let fractionID = clampToCloser(fractionPart)
        var fractionString = Configuration.convertions[fractionID]!

        if useFractions {
            Configuration.fractions.forEach { (key: String, value: String) in
                fractionString = fractionString.replacingOccurrences(of: key, with: value)
            }
        }

        if fractionString.count > 0 {
            return ["\(fractionString)\(Configuration.representationFor(unit: .inches))"]
        } else {
            return ["\(fractionString)"]
        }
    }

    private func clampToCloser(_ aValue: Double) -> Double {
        var retValue: Double = 0

        let sortedKeys = Configuration.convertions.keys.sorted()

        var idx = 1
        while idx < sortedKeys.count {
            if aValue == sortedKeys[idx] {
                retValue = aValue
                idx = sortedKeys.count
            } else if aValue < sortedKeys[idx] {
                let deltaPrev = abs(aValue - sortedKeys[idx - 1])
                let deltaNext = abs(sortedKeys[idx] - aValue)
                if deltaPrev < deltaNext {
                    retValue = sortedKeys[idx - 1]
                } else {
                    retValue = sortedKeys[idx]
                }
                idx = sortedKeys.count
            } else {
                idx += 1
            }
        }

        return retValue
    }
}
