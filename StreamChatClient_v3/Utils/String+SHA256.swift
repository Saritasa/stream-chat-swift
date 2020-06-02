//
// String+SHA256.swift
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CommonCrypto
import Foundation

extension String {
  /// A string format to conver bytes to string.
  static let dataToHEXFormat = "%02hhx"

  var sha256: String {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    let data = self.data(using: .utf8)!
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    return Data(hash).map { String(format: String.dataToHEXFormat, $0) }.joined()
  }
}
