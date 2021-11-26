//
//  SlackMessagesContainer.swift
//  
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation

public struct SlackMessagesContainer: Codable {
    let matches: [SlackMessage]
    let pagination: SlackPagination
}
