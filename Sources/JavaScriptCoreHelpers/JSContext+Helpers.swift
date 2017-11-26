//  JSContext+Helpers.swift
//  Copyright © 2017 Andrew Bennett. All rights reserved.

import Foundation
import JavaScriptCore

extension JSContext {

    @available(OSX 10.12, *)
    public func makeArrayBuffer(from arrayBufferData: Data) throws -> JSValue {
        let data = (arrayBufferData as NSData).mutableCopy() as! NSMutableData

        func releaseUnmanaged(
            array: UnsafeMutableRawPointer?,
            userData: UnsafeMutableRawPointer?)
        {
            userData
                .map(UnsafeRawPointer.init)
                .map(Unmanaged<NSMutableData>.fromOpaque)?
                .release()
        }

        var exception: JSValueRef? = nil
        let object = JSObjectMakeArrayBufferWithBytesNoCopy(
            jsGlobalContextRef,
            data.mutableBytes,
            data.length,
            releaseUnmanaged,
            Unmanaged.passRetained(data).toOpaque(),
            &exception)

        if let value = JSValue(jsValueRef: object, in: self), value.isObject {
            return value
        }
        else {
            throw JSError(jsValueRef: exception, in: context)
        }
    }

    public func makeFunction(
        parameterNames: [String], body: String)
        throws -> JSValue
    {
        let bodyString = JSStringCreateWithUTF8CString(body)
        let parameterStrings = parameterNames.map { parameter in
            JSStringCreateWithUTF8CString(parameter)
        }

        defer {
            JSStringRelease(bodyString)
            for parameter in parameterStrings {
                JSStringRelease(parameter)
            }
        }

        var exception: JSValueRef? = nil
        let object = JSObjectMakeFunction(context.jsGlobalContextRef,
                                          nil,
                                          UInt32(parameterNames.count),
                                          parameterStrings,
                                          bodyString,
                                          nil,
                                          0,
                                          &exception)

        if let value = JSValue(jsValueRef: object, in: self), value.isObject {
            return value
        }
        else {
            throw JSError(jsValueRef: exception, in: context)
        }
    }

    public func makeFunction(from block: @convention(block)
        () -> JSValue) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        () -> Void) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue) -> JSValue) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue) -> Void) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue, JSValue) -> JSValue) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue, JSValue) -> Void) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue, JSValue, JSValue) -> JSValue) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue, JSValue, JSValue) -> Void) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue, JSValue, JSValue, JSValue) -> JSValue) -> JSValue
    {
        return JSValue(object: block, in: self)
    }

    public func makeFunction(from block: @convention(block)
        (JSValue, JSValue, JSValue, JSValue) -> Void) -> JSValue
    {
        return JSValue(object: block, in: self)
    }
}
