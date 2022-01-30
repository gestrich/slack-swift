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
    
    public func post(message unsafeMessage: String, webHook: URL? = nil, completionBlock:@escaping () -> Void, errorBlock:@escaping () -> Void) {
        let message = removeUnsafeSlackStrings(input: unsafeMessage)
        guard let url = slackDefaultWebhookURL ?? slackDefaultWebhookURL else {
            print("Need a webhook url")
            errorBlock()
            return
        }
        
        let payload = "payload={\"text\": \"\(message)\"}"
        let data = (payload as NSString).data(using: String.Encoding.utf8.rawValue)
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            (data, response, error) -> Void in
            if let error = error {
                print("error: \(error.localizedDescription)")
                errorBlock()
            }
            else if let data = data {
                
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    completionBlock()
                    print("\(str)")
                }
                else {
                    print("error")
                }
            }
        }
        task.resume()
    }
    
    func removeUnsafeSlackStrings(input: String) -> String {
        var toRet = input
        let unsafeStrings = ["\""]
        for unsafeString in unsafeStrings {
            toRet = toRet.replacingOccurrences(of: unsafeString, with: "")
        }
        
        return toRet
    }
    
    public func postAndWait(message: String, webHook: URL? = nil) {
        
        let semaphore = DispatchSemaphore(value: 0)
        post(message: message, webHook: webHook) {
            semaphore.signal()
        } errorBlock: {
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    
}
