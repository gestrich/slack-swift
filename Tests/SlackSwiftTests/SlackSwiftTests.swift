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
    func testPostMessage() throws {
        //Add your own webhook url below to post to the associated channel.
        let debugURL = URL(string: "")!
        SlackAPIWebhooks(slackDefaultWebhookURL: debugURL).postAndWait(message: "test")
    }
    
    func testGetMessages() throws {
        //Add your own bearer token and channelName to fetch messages.
        let bearerToken = ""
        let channelName = ""
        let messages = SlackAPI(bearerToken: bearerToken).getMessagesAndWait(channelName: channelName)
        for message in messages {
            dump(message)
        }
    }
     */
}
