//
//  SlackChannel.swift
//
//
//  Created by Bill Gestrich on 11/4/23.
//

import Foundation

public struct SlackChannel {
    
    public let name: String
    public let id: String
    
    public init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}
