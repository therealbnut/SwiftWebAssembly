//  TestBinaryDataImportAndExport.swift
//  Copyright © 2017 Andrew Bennett. All rights reserved.

import Foundation

extension TestBinaryData {

    public static let importAndExport = Data(base64Encoded: """
        AGFzbQEAAAABCAJgAX8AYAAAAhkBB2ltcG9ydHMNaW1wb3J0ZWRfZnVuYwAAAwIB
        AQcRAQ1leHBvcnRlZF9mdW5jAAEKCAEGAEEqEAAL
        """, options: .ignoreUnknownCharacters)!

}
