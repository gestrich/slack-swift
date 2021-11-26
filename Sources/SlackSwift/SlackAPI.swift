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
    
    public func getMessages(channelName: String, completionBlock:@escaping (_ message: SlackMessagesResponse) -> Void, errorBlock:@escaping () -> Void, page: Int = 1, ascending: Bool = true) {
        
        let channelName = channelName
        let urlString = "https://slack.com/api/search.messages?query=in:\(channelName)&sort=timestamp&sort_dir=\(ascending ? "asc" : "desc")&page=\(page)"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.addValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            (data, response, error) -> Void in
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                errorBlock()
                return
            }
            
            guard let data = data else {
                print("No data")
                errorBlock()
                return
            }

            do {
                let slackReponse = try JSONDecoder().decode(SlackMessagesResponse.self, from: data)
                print("\(slackReponse)")
                completionBlock(slackReponse)
            } catch let exc {
                print("error \(exc)")
                errorBlock()
                return
            }
            
        }
        task.resume()
    }
    
    public func getMessagesAndWait(channelName: String, page: Int = 0, ascending: Bool = true) -> [SlackMessage] {
        
        let semaphore = DispatchSemaphore(value: 0)
        var messages =  [SlackMessage]()

        getMessages(channelName: channelName, completionBlock: { resp in
                
                print("done")
                if resp.messages.pagination.page < resp.messages.pagination.page_count {
                    messages = resp.messages.matches
                    semaphore.signal() //done
                } else {
                    semaphore.signal() //done
                }

            }, errorBlock: {
                print("error")
                semaphore.signal()
            }, ascending: ascending)

        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return messages
        
    }
    
    public func deleteMessage(_ slackMessage: SlackMessage, channelID: String, completionBlock:@escaping (_ message: SlackMessage) -> Void, errorBlock:@escaping () -> Void) {
        
        let urlString = "https://slack.com/api/chat.delete"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.addValue("Bearer \(self.bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let payload = ["channel":channelID, "ts": slackMessage.ts]
        
        guard let data = try? JSONEncoder().encode(payload) else {
            errorBlock()
            return
        }
        
        request.httpBody = data
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            (data, response, error) -> Void in
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                errorBlock()
                return
            }
            
            guard let data = data else {
                print("No data")
                errorBlock()
                return
            }

            do {
                let slackMessage = try JSONDecoder().decode(SlackMessage.self, from: data)
                print("\(slackMessage)")
                completionBlock(slackMessage)
            } catch let exc {
                print("error \(exc)")
                errorBlock()
                return
            }
            
        }
        task.resume()
    }
    
    public func deleteMessageAndWait(slackMessage: SlackMessage, channelID: String) -> SlackMessage? {
        
        let semaphore = DispatchSemaphore(value: 0)
        var toRet: SlackMessage? = nil
        deleteMessage(slackMessage, channelID: channelID) { msg in
            toRet = msg
            semaphore.signal()
        } errorBlock: {
            toRet = nil
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return toRet
    }
}




