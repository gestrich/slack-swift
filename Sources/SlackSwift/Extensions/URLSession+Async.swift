//
//  URLSession+Async.swift
//  
//
//  Created by Bill Gestrich on 10/14/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLSession {
 
    //Linux URLSession has not support for concurrency as of swift 5.7
    //This wrapper works around that
    func data(withRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: withRequest) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response  else {
                    continuation.resume(throwing: URLSessionCustomErrors.missingResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: URLSessionCustomErrors.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
    
    enum URLSessionCustomErrors: Error {
        case missingResponse
        case missingResponseData
    }
}

