//
//  AccessTokenResponse.swift
//  SwiftVoiceQuickstart
//
//  Created by Neosoft on 29/06/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//


import Foundation
struct AccessTokenResponse : Codable {
    let success : Bool?
    let message : String?

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case message = "message"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }

}
