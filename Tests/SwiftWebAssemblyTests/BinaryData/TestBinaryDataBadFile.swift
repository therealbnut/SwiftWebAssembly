//
//  TestBinaryDataBadFile.swift
//  SwiftWebAssemblyPackageDescription
//
//  Created by Andrew Bennett on 26/11/17.
//

import Foundation

extension TestBinaryData {

    public static let badFile = Data(
        base64Encoded: "AGFzbQ==",
        options: .ignoreUnknownCharacters)!

}
