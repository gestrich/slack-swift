//
//  SlackAPI.swift
//
//
//  Created by Bill Gestrich on 11/3/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct SlackAPI {
    
    let bearerToken: String
    
    public init(bearerToken: String) {
        self.bearerToken = bearerToken
    }
    
    //Slack Web API Documentation
    //https://api.slack.com/methods
    
    public func getMessages(channelName: String, page: Int = 1, ascending: Bool = true) async throws -> SlackMessagesContainer {
        
        let channelName = channelName
        let urlString = "https://slack.com/api/search.messages?query=in:\(channelName)&sort=timestamp&sort_dir=\(ascending ? "asc" : "desc")&page=\(page)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        let session = URLSession.shared
        let (data, response) = try await session.data(withRequest: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SlackAPIError.unexpectedURLResponseType
        }
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            
            var responseDescription = ""
            if let str = String(data: data, encoding: String.Encoding.utf8) {
                responseDescription = str
            }
            else {
                responseDescription = "Slack webhook response data was not a String. Data byte size is \(data.count)"
            }
            
            throw SlackAPIError.invalidStatusCode(code: httpResponse.statusCode, bodyMessage: responseDescription)
        }
        
        let messagesResponse = try JSONDecoder().decode(SlackMessagesResponse.self, from: data)
        if let messagesResponseError = messagesResponse.error, !messagesResponse.ok {
            throw SlackAPIError.reponseError(error: messagesResponseError)
        }
        
        guard let messagesContainer = messagesResponse.messages else {
            throw SlackAPIError.responseMissingMessagesContainer
        }
        
        return messagesContainer
    }
    
    public func deleteMessage(_ slackMessage: SlackMessage, channelID: String) async throws {
        
        let urlString = "https://slack.com/api/chat.delete"
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let payload = ["channel":channelID, "ts": slackMessage.ts]
        
        let payloadData = try JSONEncoder().encode(payload)
        
        request.httpBody = payloadData
        let session = URLSession.shared
        let (data, response) = try await session.data(withRequest: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SlackAPIError.unexpectedURLResponseType
        }
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            
            var responseDescription = ""
            if let str = String(data: data, encoding: String.Encoding.utf8) {
                responseDescription = str
            }
            else {
                responseDescription = "Slack webhook response data was not a String. Data byte size is \(data.count)"
            }
            
            throw SlackAPIError.invalidStatusCode(code: httpResponse.statusCode, bodyMessage: responseDescription)
        }
        
        let messagesDeletionResponse = try JSONDecoder().decode(SlackMessagesDeletionResponse.self, from: data)
        if let messagesDeletionResponseError = messagesDeletionResponse.error, !messagesDeletionResponse.ok {
            throw SlackAPIError.reponseError(error: messagesDeletionResponseError)
        }
    }
    
    enum SlackAPIError: Error {
        case slackReturnDataNil
        case unexpectedURLResponseType
        case invalidStatusCode(code: Int, bodyMessage: String)
        case reponseError(error: String)
        case responseMissingMessagesContainer
    }
}




