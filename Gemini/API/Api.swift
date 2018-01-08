//
//  Api.swift
//  Gemini
//
//  Created by Dylan Modesitt on 1/7/18.
//  Copyright © 2018 modesitt. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Api {
    
    let base = "https://api.sandbox.gemini.com/v1/"
    
    let apiKey = "kRJCbsHSDIQnlnXoE0vK"
    let apiSecret = "2WNUoBuoc5jVxUx3J4pDyYUkeD4s"
    

    /**
     Create HTTP Headers for a gemini request
     
     - parameter request: the path, ex: "/v1/order/status", of the request.
     - parameter additionalData: the additional payload data requested by the API
     
     - returns: the http headers for the request
    */
    private func createHeaders(request: String, withAdditionalData additionalData: JSON? = nil) -> HTTPHeaders {
        
        var payload = additionalData ?? JSON()
        let nonce = Int64(Date().timeIntervalSince1970 * 1000)
        payload["request"] = JSON(request)
        payload["nonce"]  = JSON(String(nonce))
        
        print(payload.serialize())
        let payloadb64 = payload.serialize().toBase64()
        print(payloadb64)
        
        var headers: [String: String] = [:]
        headers["Content-Type"] = "text/plain"
        headers["Content-Length"] = "0"
        headers["X-GEMINI-APIKEY"] = apiKey
        headers["X-GEMINI-PAYLOAD"] = payloadb64
        headers["X-GEMINI-SIGNATURE"] = payloadb64.hmac(algorithm: .SHA384, key: apiSecret)
        headers["Cache-Control"] = "no-cache"
        
        print(headers)
        return headers
    }
    
    init() {
      
        print(base + "balances")
        Alamofire.request(base + "balances", method: .post, headers: createHeaders(request: "/v1/balances")).responseJSON { (json) in
            
            let response = JSON(json.result.value)
            print(response)
        }
        
    }
    
}


extension JSON {
    
    func serialize() -> String {
        let s0: String = self.rawString() ?? ""
        let s1: String = s0.replacingOccurrences(of: "\\/", with: "/")
        return s1
    }
    
}


extension String {
    
    // appends the <path> with slashes before and after it, if not already present
    mutating func appendPath(path: String) {
        self.append((self.last == "/" || path.first == "/" ? "":"/") + path + (path.last == "/" ? "" : "/"))
    }
    
}
