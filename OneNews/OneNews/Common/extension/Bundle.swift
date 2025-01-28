//
//  Bundle.swift
//  OneNews
//
//  Created by Sok Pich on 1/27/25.
//

import Foundation

private var bundleKey: UInt8 = 0

extension Bundle {
    static let once: Void = {
        object_setClass(Bundle.main, LanguageBundle.self)
    }()
    
    class func setLanguage(_ language: String) {
        Bundle.once
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") ?? Bundle.main, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

