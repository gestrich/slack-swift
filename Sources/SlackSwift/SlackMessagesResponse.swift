//
//  SlackMessagesResponse.swift
//  
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation


public struct SlackMessagesResponse: Codable {
    let ok: Bool
    let query: String
    let messages: SlackMessagesContainer
}
