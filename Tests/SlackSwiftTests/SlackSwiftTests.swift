import XCTest
@testable import SlackSwift

final class slack_swiftTests: XCTestCase {
    func testRemoveUnsafeSlackStrings() throws {
        let input = "My Unsafe \"String\""
        let debugURL = URL(string: "https://www.doesntmatterforthistest.com")!
        let webhook = SlackAPIWebhooks(slackDefaultWebhookURL: debugURL)
        let output = webhook.removeUnsafeSlackStrings(input: input)
        XCTAssertEqual(output, "My Unsafe String")
    }
    
    //Code for poking at API
    
    /*
    func testPostMessage() async throws {
        //Add your own webhook url below to post to the associated channel.
        let debugURL = URL(string: "")!
        try await SlackAPIWebhooks(slackDefaultWebhookURL: debugURL).post(message: "Test message")
    }
    */
    
    
    func testDeleteMessages() async throws {
        //Add your own bearer token and channel info
        let bearerToken = ""
        let channel = SlackChannel(name: "", id: "")
        let slackAPI = SlackAPI(bearerToken: bearerToken)
        
        let container = try await slackAPI.getMessages(channelName: channel.name, page: 0, ascending: true)
        let hourThreshold: Int = 24
        let oldestDate = Date().addingTimeInterval(-TimeInterval(hourThreshold) * 60 * 60)
        for message in container.matches {
            dump(message)
            if let messageDate = message.date(), messageDate < oldestDate {
                let _ = try await slackAPI.deleteMessage(message, channelID: channel.id)
                try await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
     
}
