//
//  SwiftWebAssembly+Helpers.swift
//  SwiftWebAssemblyPackageDescription
//
//  Created by Andrew Bennett on 26/11/17.
//

import Foundation
import JavaScriptCore
import JavaScriptCoreHelpers

// MARK: - Private -

extension JSContext {

    internal enum SymbolKind: String {
        case function = "function"
        case table = "table"
        case memory = "memory"
        case global = "global"

        fileprivate static func load(
            from symbols: JSValue) -> [String: SymbolKind]
        {
            var index = 0
            var output = [String: SymbolKind]()
            while let value = symbols.atIndex(index), !value.isUndefined {
                if let name = value[keyPath: "name"]?.toString(),
                    let _kind = value[keyPath: "kind"]?.toString(),
                    let kind = SymbolKind(rawValue: _kind)
                {
                    output[name] = kind
                }
                index += 1
            }
            return output
        }
    }

    internal func makeOnCompileFailureFunction(
        callback: @escaping (JSError) -> Void) -> JSValue
    {
        return makeFunction { error -> Void in
            callback(JSError(error))
        }
    }

    internal func makeOnLoadFailureFunction(
        callback: @escaping (JSError) -> Void) -> JSValue
    {
        return makeFunction { error, imports -> Void in
            callback(JSError(error))
        }
    }

    internal func makeOnLoadCompleteFunction(
        callback: @escaping ([String: JSValue]) -> Void) -> JSValue
    {
        return makeFunction { module, instance, imports, exports -> Void in
            let exportSymbols = SymbolKind.load(from: exports)
            let exportValues = instance[keyPath: "exports"]!

            var result = [String: JSValue]()
            for (key, _) in exportSymbols {
                if let value = exportValues[keyPath: key] {
                    result[key] = value
                }
            }
            callback(result)
        }
    }

    internal func jsLoadWebAssembly(
        data: JSValue,
        imports: JSValue,
        onCompileFailure: JSValue,
        onLoadFailure: JSValue,
        onLoadComplete: JSValue) throws
    {
        try jsLoadWebAssemblyFunction().call(withArguments: [
            data,
            imports,
            onCompileFailure,
            onLoadFailure,
            onLoadComplete])
    }

    internal func jsLoadWebAssemblyFunction() throws -> JSValue {
        let functionName = "loadModule"
        if let functionValue = context[keyPath: functionName],
            !functionValue.isUndefined
        {
            return functionValue
        }
        let function = try makeFunction(
            parameterNames: [
                "moduleData",
                "moduleImports",
                "onCompileFailure",
                "onLoadFailure",
                "onLoadComplete",
                ],
            body: """
                WebAssembly.compile(moduleData)
                    .then(m => {
                        let imp = WebAssembly.Module.imports(m)
                        let exp = WebAssembly.Module.exports(m)
                        return WebAssembly.instantiate(m, moduleImports).then(
                            i => onLoadComplete(m, i, imp, exp),
                            e => onLoadFailure(e, imp))
                    }, e => onCompileFailure(e))
                """)
        context[keyPath: functionName] = function
        return function
    }
}

