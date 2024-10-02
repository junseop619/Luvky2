//
//  AppleTokenResponse.swift
//  Luvky2
//
//  Created by 황준섭 on 1/26/24.
//

import Foundation

struct AppleTokenResponse: Codable {
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

