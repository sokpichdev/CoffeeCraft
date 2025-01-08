import UIKit

let sWM = "1, 2, 3, 4 66"
let sWOM = "123 4"
var array1: [String] = []

extension String {
    func convertStringToListOfStrings() -> [String] {
        if self.contains(",") || self.contains(" ") {
            // Split the string by commas and trim whitespaces
            return self.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        } else {
            // Map each character to a string
            return self.map { String($0) }
        }
    }
    func convertStringToConcatenatedString() -> String {
        // Remove commas and trim whitespaces, then concatenate the numbers into a single string
        let concatenatedString = self.replacingOccurrences(of: ",", with: "")
        return concatenatedString
    }

    func convertconcatedStrToListOfStr() -> [String] {
        return self.convertStringToConcatenatedString().convertStringToListOfStrings()
    }
}

array1 = sWM.convertStringToListOfStrings()
print(array1)

array1 = sWOM.convertStringToListOfStrings()
print(array1)

array1  = sWM.convertconcatedStrToListOfStr()
print(array1)

array1 = sWOM.convertconcatedStrToListOfStr()
print(array1)
