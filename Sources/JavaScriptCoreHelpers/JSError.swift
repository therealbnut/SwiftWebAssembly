//
//  JSError.swift
//
//  Created by Andrew Bennett on 26/11/17.
//  Copyright © 2017 Andrew Bennett. All rights reserved.
//

import Foundation

import JavaScriptCore

public final class JSError: Error {

    public var value: JSValue

    public var name: String? {
        return value[keyPath: "name"]?.toString()
    }
    public var message: String? {
        return value[keyPath: "message"]?.toString()
    }
    public var fileName: String? {
        return value[keyPath: "fileName"]?.toString()
    }
    public var lineNumber: Int? {
        return (value[keyPath: "lineNumber"]?.toUInt32()).map(Int.init(_:))
    }

    public init(_ error: JSValue) {
        self.value = error
    }

}

extension JSError {

    public convenience init(jsValueRef: JSValueRef!, in context: JSContext) {
        if let value = JSValue(jsValueRef: jsValueRef, in: context) {
            self.init(value)
        }
        else {
            self.init(unexpectedErrorIn: context)
        }
    }

    public convenience init(message: String, in context: JSContext) {
        self.init(JSValue(newErrorFromMessage: message, in: context))
    }

    public convenience init(unexpectedErrorIn context: JSContext) {
        self.init(message: "Unexpected error!", in: context)
    }
}

extension JSError: LocalizedError {

    public var errorDescription: String? {
        return self.message
    }

}
