//
//  SlackAPIWebhooks.swift
//  
//
//  Created by Bill Gestrich on 11/26/21.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif



public class SlackAPIWebhooks {
    
    let slackDefaultWebhookURL: URL?
    
    public init(slackDefaultWebhookURL: URL? = nil) {
        self.slackDefaultWebhookURL = slackDefaultWebhookURL
    }
    
    public func post(message unsafeMessage: String, webHook: URL? = nil) async throws {
        let message = removeUnsafeSlackStrings(input: unsafeMessage)
        guard let url = slackDefaultWebhookURL ?? slackDefaultWebhookURL else {
            throw SlackAPIWebhooksError.missingWebHookURL
        }
        
        let payload = "payload={\"text\": \"\(message)\"}"
        let payloadData = (payload as NSString).data(using: String.Encoding.utf8.rawValue)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = payloadData
        let session = URLSession.shared
        let (data, response) = try await session.data(withRequest: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SlackAPIWebhooksError.unexpectedURLResponseType
        }
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            
            var responseDescription = ""
            if let str = String(data: data, encoding: String.Encoding.utf8) {
                responseDescription = str
            }
            else {
                responseDescription = "Slack webhook response data was not a String. Data byte size is \(data.count)"
            }
            
            throw SlackAPIWebhooksError.invalidStatusCode(code: httpResponse.statusCode, bodyMessage: responseDescription)
        }

    }
    
    func removeUnsafeSlackStrings(input: String) -> String {
        var toRet = input
        let unsafeStrings = ["\""]
        for unsafeString in unsafeStrings {
            toRet = toRet.replacingOccurrences(of: unsafeString, with: "")
        }
        
        return toRet
    }
    
    enum SlackAPIWebhooksError: Error {
        case missingWebHookURL
        case unexpectedURLResponseType
        case invalidStatusCode(code: Int, bodyMessage: String)
    }
}
