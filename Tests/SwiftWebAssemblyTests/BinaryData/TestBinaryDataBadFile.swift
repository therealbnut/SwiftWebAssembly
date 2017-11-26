//  TestBinaryDataBadFile.swift
//  Copyright © 2017 Andrew Bennett. All rights reserved.

import Foundation

extension TestBinaryData {

    public static let badFile = Data(
        base64Encoded: "AGFzbQ==",
        options: .ignoreUnknownCharacters)!

}
