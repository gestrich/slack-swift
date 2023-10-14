//
//  SlackMessagesContainer.swift
//  
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation

public struct SlackMessagesContainer: Codable {
    public let matches: [SlackMessage]
    public let pagination: SlackPagination
}
