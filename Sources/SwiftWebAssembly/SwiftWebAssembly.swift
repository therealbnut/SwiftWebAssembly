//
//  WebAssembly.swift
//
//  Created by Andrew Bennett on 26/11/17.
//  Copyright © 2017 Andrew Bennett. All rights reserved.
//

import Foundation
import JavaScriptCore
import JavaScriptCoreHelpers

extension JSContext {

    @available(OSX 10.12, *)
    public func loadWebAssemblyModule(
        data: Data,
        imports: [String: JSValue] = [:],
        success: @escaping ([String: JSValue]) -> Void,
        failure: ((JSValue) -> Void)? = nil)
    {
        let onLoadComplete = makeOnLoadCompleteFunction { exports in
            success(exports)
        }
        let onCompileFailure = makeOnCompileFailureFunction { error -> Void in
            failure?(error.value)
        }
        let onLoadFailure = makeOnLoadFailureFunction { error -> Void in
            failure?(error.value)
        }

        do {
            let dataValue = try self.makeArrayBuffer(from: data)
            let importsValue = JSValue(object: ["imports": imports],
                                       in: context)!

            try jsLoadWebAssembly(
                data: dataValue,
                imports: importsValue,
                onCompileFailure: onCompileFailure,
                onLoadFailure: onLoadFailure,
                onLoadComplete: onLoadComplete)
        }
        catch {
            // This should only produce JSError values
            failure?((error as! JSError).value)
        }
    }

}

