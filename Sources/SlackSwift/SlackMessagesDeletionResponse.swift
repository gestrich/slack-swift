//
//  SlackMessagesDeletionResponse.swift
//
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation


public struct SlackMessagesDeletionResponse: Codable {
    public let ok: Bool
    public let channel: String?
    public let ts: String?
    public let error: String?
}
