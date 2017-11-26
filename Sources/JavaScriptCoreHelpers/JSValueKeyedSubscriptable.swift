//
//  JSValueKeyedSubscriptable.swift
//
//  Created by Andrew Bennett on 26/11/17.
//  Copyright © 2017 Andrew Bennett. All rights reserved.
//

import Foundation
import JavaScriptCore

public protocol JSValueKeyedSubscriptable: class {

    var context: JSContext! { get }

    func objectForKeyedSubscript(_ key: Any!) -> JSValue!
    func setObject(_ object: Any!,
                   forKeyedSubscript key: (NSCopying & NSObjectProtocol)!)
}

extension JSValueKeyedSubscriptable {

    public subscript (keyPath keyPath: String) -> JSValue? {
        get {
            let keyedSubscript = keyPath as NSString
            let value = self.objectForKeyedSubscript(keyedSubscript)
            return value?.isUndefined == true ? nil : value
        }
        set {
            let keyedSubscript = keyPath as NSString
            if let value = newValue, !value.isUndefined {
                self.setObject(value, forKeyedSubscript: keyedSubscript)
            }
            else {
                self.setObject(nil, forKeyedSubscript: keyedSubscript)
            }
        }
    }

}

extension JSValue: JSValueKeyedSubscriptable {
}

extension JSContext: JSValueKeyedSubscriptable {

    public var context: JSContext! {
        return self
    }

}

extension JSError: JSValueKeyedSubscriptable {

    public var context: JSContext! {
        return self.value.context
    }

    public func objectForKeyedSubscript(_ key: Any!) -> JSValue! {
        return self.value.objectForKeyedSubscript(key)
    }

    public func setObject(
        _ object: Any!,
        forKeyedSubscript key: (NSCopying & NSObjectProtocol)!)
    {
        self.value.setObject(object, forKeyedSubscript: key)
    }

}
