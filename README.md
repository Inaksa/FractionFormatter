# FractionsFormatter
[SPM compatible](https://img.shields.io/badge/SPM-compatible-blue)

A package to display measures using the imperial systems in feet, inches and fractions of an inch.

There are a few options:
  
* allowZero: Bool (default: true) adds a leading zero when expressing fractions. (eg: 0.5in = 0 ½in)

* allowMultipleUnits: Bool (default: false) splits the integer part in multiple units (eg 63390in = "1mi 2ft 6in" 

* useFractions: Bool (default: true) toggles between using unicode to display fractions (eg: 1/8 becomes '⅛' (unicode 215B))

The fractions are snapped to the closest 8th. But this can be further adjusted by providing the fractions needed and the decimal values corresponding for said fractions. (If there is no single glyph for the fraction unicode, it can be created by composing multiple graphemes. eg: 13/16 can be represented with "\u{B9}\u{B3}\u{2044}\u{2081}\u{2086}", this method allows any fraction to be represented)

Note: if you add other fractions the tests are likely to break, since most depend on the snapping to multiple of 1/8th.

Usage mode:

let formatter = FractionsFormatter()
print(formatter.string(for: 0.5))

