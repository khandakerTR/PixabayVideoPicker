//
//  PixabayRequest.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import Foundation

class PixabayRequest: NetworkRequest {

    enum RequestError: Error {
        case invalidJSONResponse

        var localizedDescription: String {
            switch self {
            case .invalidJSONResponse:
                return "Invalid JSON response."
            }
        }
    }

    private(set) var jsonResponse: Any?

    // MARK: - Process the response

    override func processResponseData(_ data: Data?) {
        if let error = error {
            completeWithError(error)
            return
        }
        guard let data = data else { return }
        
        do {
            jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
            processJSONResponse()
        } catch {
            completeWithError(RequestError.invalidJSONResponse)
        }
    }

    func processJSONResponse() {
        if let error = error {
            completeWithError(error)
        } else {
            completeOperation()
        }
    }
}


