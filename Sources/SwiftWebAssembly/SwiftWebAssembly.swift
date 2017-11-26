//  WebAssembly.swift
//  Copyright © 2017 Andrew Bennett. All rights reserved.

import Foundation
import JavaScriptCore
import JavaScriptCoreHelpers

@available(OSX 10.12, *)
extension JSContext {

    /// Compiles and links a WebAssembly module, returning a dictionary of
    /// exported functions and other symbols.
    ///
    /// This function essentially mirrors the JavaScript
    /// `WebAssembly.instantiate` [API](https://mdn.io/WebAssembly/instantiate).
    ///
    /// A wasm module can be produced by following the official
    /// [guide](http://webassembly.org/getting-started/developers-guide/).
    ///
    /// ```
    /// context.loadWebAssemblyModule(
    ///     data: data,
    ///     success: { exports in
    ///         let result = exports?["add"]?.call(withArguments: [1, 2])
    ///         print("result: \(result)") // result: 3
    ///     },
    ///     failure: { error in
    ///         print("oh no!")
    ///     })
    /// ```
    ///
    /// - Parameter data: The data for a valid wasm binary.
    /// - Parameter imports: A dictionary of named external symbols that the
    ///   module needs to resolve during linking.
    /// - Parameter success: If successful this is called with the exported
    ///   symbols.
    /// - Parameter exports: A dictionary of named exported symbols.
    /// - Parameter failure: If unsuccesful this is called with an error value.
    /// - Parameter error: An error JSValue describing the failure reason.
    ///
    public func loadWebAssemblyModule(
        data: Data,
        imports: [String: JSValue] = [:],
        success: @escaping ( _ exports: [String: JSValue]) -> Void,
        failure: @escaping (_ error: JSValue) -> Void = { error in
            debugPrint("Uncaught error: \(error)")
        })
    {
        let onSuccess = makeOnSuccessFunction { exports in
            success(exports)
        }
        let onFailure = makeOnLoadFailureFunction { error -> Void in
            failure(error.value)
        }

        do {
            let dataValue = try self.makeArrayBuffer(from: data)
            let importsValue = JSValue(object: ["imports": imports],
                                       in: context)!

            try jsLoadWebAssembly(
                data: dataValue,
                imports: importsValue,
                onCompileFailure: onFailure,
                onLoadFailure: onFailure,
                onSuccess: onSuccess)
        }
        catch {
            // This should only produce JSError values
            failure((error as! JSError).value)
        }
    }

}

