//
//  Extensions.swift
//  Gemini
//
//  Created by Dylan Modesitt on 1/7/18.
//  Copyright © 2018 modesitt. All rights reserved.
//

import Foundation


extension String {
    
    /**
     Encode a String to Base64
     :returns: the base 64 representation
     */
    func toBase64()->String{
        let data = self.data(using: .utf8)
        return data!.base64EncodedString()
    }
}
