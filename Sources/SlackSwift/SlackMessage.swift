//
//  SlackMessage.swift
//  
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation

public struct SlackMessage: Codable {
    
    public let ts: String
    public let text: String
    
    public func date() -> Date? {
        guard let interval = TimeInterval(ts) else {
            return nil
        }
        return Date(timeIntervalSince1970:interval)
    }
}

