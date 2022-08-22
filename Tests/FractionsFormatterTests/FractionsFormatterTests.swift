import XCTest
@testable import FractionsFormatter

final class FractionsFormatterTests: XCTestCase {
    var inchesUnit: String {
        FractionsFormatter().representationFor(unit: .inches)
    }

    func testIntegerValues() {
        let formatter = FractionsFormatter()

        let test: [Double: String] = [
            0: "0\(inchesUnit)",
            1: "1\(inchesUnit)",
            2: "2\(inchesUnit)",
            3: "3\(inchesUnit)",
            -3: "-3\(inchesUnit)",
            -2: "-2\(inchesUnit)",
            -1: "-1\(inchesUnit)",
        ]

        test.forEach { (key: Double, value: String) in
            XCTAssertEqual(value, formatter.string(for: key))
        }
    }

    func testDecimalValues() throws {
        let formatter = FractionsFormatter()

        let test: [Double: String] = [
            0: "0\(inchesUnit)",
            0.125: "0 ⅛\(inchesUnit)",
            0.25: "0 ¼\(inchesUnit)",
            0.5: "0 ½\(inchesUnit)",
            0.625: "0 ⅝\(inchesUnit)",
            0.75: "0 ¾\(inchesUnit)",
            0.825: "0 ⅞\(inchesUnit)",
            1: "1\(inchesUnit)",
        ]

        XCTAssertEqual(test[0], formatter.string(for: 0))
        XCTAssertEqual(test[1], formatter.string(for: 1))
        XCTAssertEqual(test[0.125], formatter.string(for: 0.125))
        XCTAssertEqual(test[0.250], formatter.string(for: 0.250))
        XCTAssertEqual(test[0.500], formatter.string(for: 0.500))
        XCTAssertEqual(test[0.625], formatter.string(for: 0.625))
        XCTAssertEqual(test[0.750], formatter.string(for: 0.750))
        XCTAssertEqual(test[0.825], formatter.string(for: 0.825))
    }

    func testAllValues() throws {
        let formatter = FractionsFormatter()

        let test: [Double: String] = [
            0: "0\(inchesUnit)",
            Double(0.125).nextDown: "0\(inchesUnit)",
            Double(0.125).nextUp: "0 ⅛\(inchesUnit)",
            0.0105: "0 ⅛\(inchesUnit)",
            45.875: "3ft 9 ⅞\(inchesUnit)",
            45.5: "3ft 9 ½\(inchesUnit)",
            45.997: "3ft 10\(inchesUnit)",
        ]

        XCTAssertEqual(test[0], formatter.string(for: 0))
        XCTAssertEqual(test[Double(0.125).nextDown], formatter.string(for: Double(1.0 / 8.0).nextDown))
        XCTAssertEqual(test[Double(0.125).nextUp], formatter.string(for: Double(1.0 / 8.0).nextUp))
        XCTAssertEqual(test[45.875], formatter.string(for: 45.875))
        XCTAssertEqual(test[45.5], formatter.string(for: 45.5))
        XCTAssertEqual(test[45.997], formatter.string(for: 45.997))
    }

    func testFractions() throws {
        let formatter = FractionsFormatter()
        formatter.useFractions = true

        let test: [Double: (String, String)] = [
            0.125: ("0 ⅛\(inchesUnit)", "0 1/8\(inchesUnit)"),
            0.25: ("0 ¼\(inchesUnit)", "0 1/4\(inchesUnit)"),
            0.375: ("0 ⅜\(inchesUnit)", "0 3/8\(inchesUnit)"),
            0.5: ("0 ½\(inchesUnit)", "0 1/2\(inchesUnit)"),
            0.625: ("0 ⅝\(inchesUnit)", "0 5/8\(inchesUnit)"),
            0.75: ("0 ¾\(inchesUnit)", "0 3/4\(inchesUnit)"),
            0.825: ("0 ⅞\(inchesUnit)", "0 7/8\(inchesUnit)"),
        ]

        XCTAssertEqual(test[0.125]!.0, formatter.string(for: 0.125))
        XCTAssertEqual(test[0.250]!.0, formatter.string(for: 0.250))
        XCTAssertEqual(test[0.500]!.0, formatter.string(for: 0.500))
        XCTAssertEqual(test[0.625]!.0, formatter.string(for: 0.625))
        XCTAssertEqual(test[0.750]!.0, formatter.string(for: 0.750))
        XCTAssertEqual(test[0.825]!.0, formatter.string(for: 0.825))

        formatter.useFractions = false

        XCTAssertEqual(test[0.125]!.1, formatter.string(for: 0.125))
        XCTAssertEqual(test[0.250]!.1, formatter.string(for: 0.250))
        XCTAssertEqual(test[0.500]!.1, formatter.string(for: 0.500))
        XCTAssertEqual(test[0.625]!.1, formatter.string(for: 0.625))
        XCTAssertEqual(test[0.750]!.1, formatter.string(for: 0.750))
        XCTAssertEqual(test[0.825]!.1, formatter.string(for: 0.825))
    }

    func testAllowMultipleUnits() throws {
        let formatter = FractionsFormatter()
        formatter.allowZero = false
        formatter.allowMultipleUnits = false

        let test: [Double: String] = [
            0: "0\(inchesUnit)",
            13: "1ft 1\(inchesUnit)",
            32: "2ft 8\(inchesUnit)",
            63360: "5280ft",
            63395.5: "5282ft 11 ½\(inchesUnit)",
        ]

        XCTAssertEqual(test[0], formatter.string(for: 0))
        XCTAssertEqual(test[13], formatter.string(for: 13))
        XCTAssertEqual(test[32], formatter.string(for: 32))
        XCTAssertEqual(test[63360], formatter.string(for: 63360))
        XCTAssertEqual(test[63395.5], formatter.string(for: 63395.5))
    }
    
    func testAnotherTest() throws {
        print("\u{B9}\u{2075}\u{2044}\u{2081}\u{2086}")
        XCTAssertEqual("0", "0")
    }
}
