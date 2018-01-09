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
    
    static let base = "https://api.sandbox.gemini.com"
    
    static let apiKey = "kRJCbsHSDIQnlnXoE0vK"
    static let apiSecret = "2WNUoBuoc5jVxUx3J4pDyYUkeD4s"
    
    /**
     * An abstraction layer on top of the Gemini API to allow for simple handeling of API
     * calls in a more standard way.
     *
     * - property method: the HTTP method (post, get, ...) of the request
     * - property path: The path of the request
     */
    public enum Endpoints {
        case Balances()
        case AuctionHistory(symbol: String, since: Int, limit: Int?, indicitave: Bool?)
        
        public var method: HTTPMethod {
            switch self {
            case .Balances:
                return .post
            case .AuctionHistory:
                return .get
            }
        }
        
        public var path: String {
            switch self {
            case .Balances:
                return "/v1/balances"
            case .AuctionHistory(let symbol, _, _, _):
                return "/v1/auction/\(symbol)/history"
            }
        }
        
        public var url: String {
            return base + self.path
        }
        
        public var parameters: [String : Any] {
            switch self {
            case .AuctionHistory(_, let since, let limit, let indicative):
                return ["since": since, "limit_auction_results": limit ?? 50, "include_indicative": indicative ?? false]
            default:
                return [:]
            }
        }
        
        public var headers: HTTPHeaders {
            switch self {
            case .Balances:
                return createHeaders(request: self.path)
            case .AuctionHistory:
                return [:]
            }
        }
        
    }
    
    
    /**
     Create HTTP Headers for a gemini request
     
     - parameter request: the path, ex: "/v1/order/status", of the request.
     - parameter additionalData: the additional payload data requested by the API
     
     - returns: the http headers for the request
    */
    private static func createHeaders(request: String, withAdditionalData additionalData: JSON? = nil) -> HTTPHeaders {
        
        var payload = additionalData ?? JSON()
        let nonce = Int64(Date().timeIntervalSince1970 * 1000)
        payload["request"] = JSON(request)
        payload["nonce"]  = JSON(String(nonce))
        let payloadb64 = payload.serialize().toBase64()
        
        var headers: [String: String] = [:]
        headers["Content-Type"] = "text/plain"
        headers["Content-Length"] = "0"
        headers["X-GEMINI-APIKEY"] = apiKey
        headers["X-GEMINI-PAYLOAD"] = payloadb64
        headers["X-GEMINI-SIGNATURE"] = payloadb64.hmac(algorithm: .SHA384, key: apiSecret)
        headers["Cache-Control"] = "no-cache"
        
        return headers
    }
    
    /**
     Make a request to the gemini API
     
     - parameter endpoint: the API endpoint
     - parameter completionHandler: the function to handle the JSON response from the API
     */
    public static func request(endpoint: Api.Endpoints, completionHandler: @escaping (JSON) -> Void) {
        Alamofire.request(endpoint.url, method: endpoint.method, parameters: endpoint.parameters, headers: endpoint.headers).responseJSON { (response) in
            if (response.result.value != nil) {
                print("sucuess")
                completionHandler(JSON(response.result.value!))
            } else {
                if (response.result.error != nil) {
                    print(response.result.error!) // known error
                } else {
                    print("Unkown error") // unkown error
                }
            }
        }
    }
    
    
}


extension JSON {
    
    // serialize the json into a standard JSON string
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
