//
//  String.swift
//  Localization
//
//  Created by Sok Pich on 1/28/25.
//

import SwiftUI

extension String {
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
