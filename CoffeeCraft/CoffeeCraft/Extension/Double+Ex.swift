//  Created by Sok Pich on 3/4/26.
//
//  Smart dollar formatter:
//    10.0  → "$10"
//    10.5  → "$10.5"
//    10.25 → "$10.25"

import Foundation

extension Double {

    /// Formats a dollar amount, trimming unnecessary trailing zeros.
    /// Examples: 10.0 → "$10", 10.5 → "$10.5", 10.25 → "$10.25"
    var currencyFormatted: String {
        let rounded = (self * 100).rounded() / 100
        if rounded == rounded.rounded(.towardZero) && rounded >= 0 {
            return "$\(Int(rounded))"
        }
        var str = String(format: "%.2f", rounded)
        while str.hasSuffix("0") { str.removeLast() }
        return "$\(str)"
    }
}
