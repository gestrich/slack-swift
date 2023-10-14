//
//  SlackMessagesResponse.swift
//  
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation


public struct SlackMessagesResponse: Codable {
    public let ok: Bool
    public let query: String?
    public let messages: SlackMessagesContainer?
    public let error: String?
}
