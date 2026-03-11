//  Created by Sok Pich on 3/4/26.
//
//  Smart dollar formatter:
//    10.0  → "$10"
//    10.5  → "$10.5"
//    10.25 → "$10.25"

import Foundation

extension Double {

    /// Formats a dollar amount, trimming unnecessary trailing zeros.
    /// Examples:
    /// 10.0  → "$10"
    /// 10.5  → "$10.5"
    /// 10.25 → "$10.25"
    /// -10.5 → "-$10.5"
    var currencyFormatted: String {
        let rounded = (self * 100).rounded() / 100
        let sign = rounded < 0 ? "-" : ""
        let absValue = abs(rounded)

        if absValue == absValue.rounded(.towardZero) {
            return "\(sign)$\(Int(absValue))"
        }

        var str = String(format: "%.2f", absValue)
        while str.hasSuffix("0") { str.removeLast() }

        return "\(sign)$\(str)"
    }
}
