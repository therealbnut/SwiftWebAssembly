import XCTest
import JavaScriptCore

import JavaScriptCoreTestHelpers
@testable import SwiftWebAssembly

@available(OSX 10.12, *)
class SwiftWebAssemblyTests: XCTestCase {

    var virtualMachine: JSVirtualMachine!
    var context: JSContext!

    var exports: [String:JSValue]?
    var error: JSValue?

    override func setUp() {
        super.setUp()
        virtualMachine = JSVirtualMachine()
        context = JSContext(virtualMachine: virtualMachine)

        context.exceptionHandler = { context, error in
            print("exception: \(error!))")
        }
    }

    override func tearDown() {
        super.tearDown()
        autoreleasepool {
            virtualMachine = nil
            context = nil
            exports = nil
            error = nil
        }
    }

    private func loadWebAssemblyModuleHelper(
        data: Data,
        imports: [String:JSValue] = [:])
    {
        let finished = expectation(description: "finished")

        context.loadWebAssemblyModule(
            data: data,
            imports: imports,
            success: { exports in
                self.exports = exports
                finished.fulfill()
            },
            failure: { error in
                self.error = error
                finished.fulfill()
            })

        wait(for: [finished], timeout: 1.0)
    }

    func testCallableExports() {
        loadWebAssemblyModuleHelper(data: TestBinaryData.add)
        let result = exports?["add"]?.call(withArguments: [1, 2]).toInt32()
        XCTAssertEqual(result, 3)
    }

    func testImportsSuccessfullyLoaded() {
        let imports = [
            "imported_func": context.makeFunction(from: { () -> JSValue in
                return JSValue(undefinedIn: context)
            })
        ]
        loadWebAssemblyModuleHelper(data: TestBinaryData.importAndExport,
                                    imports: imports)

        if let exports = exports {
            XCTAssertTrue(exports.keys.contains("exported_func"))
        }
        else {
            XCTFail("Failed to find exports!")
        }
    }

    func testFailWithoutRequiredImports() {
        loadWebAssemblyModuleHelper(data: TestBinaryData.importAndExport)
        XCTAssertNil(exports)
        XCTAssertNotNil(error)
    }

    func testFailOnInvalidBinary() {
        loadWebAssemblyModuleHelper(data: TestBinaryData.badFile)
        XCTAssertNil(exports)
        XCTAssertNotNil(error)
    }

    func testLoadPerformance() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let imports = [
                "__errno_location": JSValue(int32: 0, in: context)!
            ]
            let data = TestBinaryData.library
            let finished = expectation(description: "finished")

            startMeasuring()
            context.loadWebAssemblyModule(
                data: data,
                imports: imports,
                success: { exports in
                    self.exports = exports
                    finished.fulfill()
                },
                failure: { error in
                    self.error = error
                    finished.fulfill()
                })
            wait(for: [finished], timeout: 1.0)
            stopMeasuring()

            XCTAssertNotNil(exports)
            XCTAssertNil(error)
        }
    }

    func testMemoryCleanup() {
        var weakReference: JSManagedValue!

        autoreleasepool {
            loadWebAssemblyModuleHelper(data: TestBinaryData.add)
            weakReference = JSManagedValue(value: exports?["add"])
            XCTAssertNotNil(weakReference.value)

            self.exports = nil
            self.error = nil
        }

        JSSynchronousGarbageCollectForDebugging(context.jsGlobalContextRef)

        XCTAssertNil(JSContext.currentThis())
        XCTAssertNil(JSContext.currentCallee())
        XCTAssertNil(JSContext.currentArguments())

        XCTAssertNil(weakReference.value)
    }

    static var allTests = [
        ("testCallableExports", testCallableExports),
        ("testImportsSuccessfullyLoaded", testImportsSuccessfullyLoaded),
        ("testFailWithoutRequiredImports", testFailWithoutRequiredImports),
        ("testFailOnInvalidBinary", testFailOnInvalidBinary),
        ("testLoadPerformance", testLoadPerformance),
        ("testMemoryCleanup", testMemoryCleanup),
    ]
}
