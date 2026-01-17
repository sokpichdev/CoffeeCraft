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

extension String {
    // MARK: Strick password validation
    func containsUppercase() -> Bool {
        return self.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    func containsLowercase() -> Bool {
        return self.rangeOfCharacter(from: .lowercaseLetters) != nil
    }
    
    func containsNumber() -> Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    func containsSpecialCharacter() -> Bool {
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        return self.rangeOfCharacter(from: specialCharacters) != nil
    }
    
    // MARK: Simple password validation
    func containsLetterAndNumber() -> Bool {
        let hasLetter = self.rangeOfCharacter(from: .letters) != nil
        let hasNumber = self.rangeOfCharacter(from: .decimalDigits) != nil
        return hasLetter && hasNumber
    }
}

extension String {
    func generateProductID() -> String {
        self.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
    }
}
