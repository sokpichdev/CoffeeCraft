//
//  String+Ex.swift
//  CoffeeCraft
//
//  Created by Sok Pich on 1/14/26.
//

import SwiftUI

extension String {
    func isContainsLettersAndNumbers() -> Bool {
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        
        let hasLetter = self.rangeOfCharacter(from: letters) != nil
        let hasNumber = self.rangeOfCharacter(from: digits) != nil
        
        return hasLetter && hasNumber
    }
    
    func checkSpaceAndSpecialChars() -> Bool {
        let regex = "^[a-zA-Z0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}
