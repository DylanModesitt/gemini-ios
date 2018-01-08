//
//  HMAC.swift
//  Gemini
//
//  Created by Dylan Modesitt on 1/7/18.
//  Copyright © 2018 modesitt. All rights reserved.
//
//  Don't forget to add Bridging-Header and this line in it :
//  #import <CommonCrypto/CommonCrypto.h>
//  originally based on: https://gist.github.com/Darkkrye/66242e31f573dc975d46e30b1cd8517b

import Foundation

enum CryptoAlgorithm {
    
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:  result = kCCHmacAlgMD5
        case .SHA1:  result = kCCHmacAlgSHA1
        case .SHA224: result = kCCHmacAlgSHA224
        case .SHA256: result = kCCHmacAlgSHA256
        case .SHA384: result = kCCHmacAlgSHA384
        case .SHA512: result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    typealias DigestAlgorithm = (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<CUnsignedChar>) -> UnsafeMutablePointer<CUnsignedChar>?

    var digestAlgorithm: DigestAlgorithm {
        switch self {
        case .MD5:      return CC_MD5
        case .SHA1:     return CC_SHA1
        case .SHA224:   return CC_SHA224
        case .SHA256:   return CC_SHA256
        case .SHA384:   return CC_SHA384
        case .SHA512:   return CC_SHA512
        }
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:  result = CC_MD5_DIGEST_LENGTH
        case .SHA1:  result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    // MARK: HMAC
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: .utf8)
        let strLen = Int(self.lengthOfBytes(using: .utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: .utf8)
        let keyLen = Int(key.lengthOfBytes(using: .utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    // MARK: Digest
    var md5: String {
        return digest(algorithm: .MD5)
    }
    
    var sha1: String {
        return digest(algorithm: .SHA1)
    }
    
    var sha224: String {
        return digest(algorithm: .SHA224)
    }
    
    var sha256: String {
        return digest(algorithm: .SHA256)
    }
    
    var sha384: String {
        return digest(algorithm: .SHA384)
    }
    
    var sha512: String {
        return digest(algorithm: .SHA512)
    }
    
    func digest(algorithm: CryptoAlgorithm) -> String {
        let str = self.cString(using: .utf8)
        let strLen = Int(self.lengthOfBytes(using: .utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        algorithm.digestAlgorithm(str!, UInt32(strLen), result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        
        return String(hash)
    }
}
