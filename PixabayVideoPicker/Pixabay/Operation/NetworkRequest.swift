//
//  NetworkRequest.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import Foundation

class NetworkRequest: ConcurrentOperation {
    
    enum RequestError: Error {
        case invalidURL, noHTTPResponse, http(status: Int)

        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .noHTTPResponse:
                return "Not a HTTP response."
            case .http(let status):
                return "HTTP error: \(status)."
            }
        }
    }
    
    private let baseURL = "https://pixabay.com/api/videos/"
    private let apiKey = "36438408-6e2cafe5de5e482918a197b82"
    
    private let timeoutInterval = 30.0

    private var task: URLSessionDataTask?
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureCodes: CountableRange<Int> = 400..<499

    // MARK: - Prepare the request

    func prepareParameters() -> [String: Any]? {
        return nil
    }

    func prepareURLRequest() throws -> URLRequest {
        
        let parameters = prepareParameters()
        guard let req = addQueryParameters(parameters) else {
            throw RequestError.invalidURL
        }
        
        return URLRequest(url: req.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
    }

    private func addQueryParameters(_ parameters: [String: Any]?) -> URLComponents? {
        
        guard var requestURL = URLComponents(string: baseURL) else {
            return nil
        }
        
        requestURL.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        parameters?.forEach { key, value in
            let qry = URLQueryItem(name: key, value: "\(value)")
            requestURL.queryItems?.append(qry)
        }
        return requestURL
    }

    // MARK: - Execute the request

    override func main() {
        guard let request = try? prepareURLRequest() else {
            completeWithError(RequestError.invalidURL)
            return
        }

        let session = URLSession.shared
        print("REQUEST > ",request)
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.processResponse(response, data: data, error: error)
        })
        task?.resume()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    // MARK: - Process the response

    final func processResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        if let error = error {
            return completeWithError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return completeWithError(RequestError.noHTTPResponse)
        }

        processHTTPResponse(httpResponse, data: data)
    }

    final func processHTTPResponse(_ response: HTTPURLResponse, data: Data?) {
        let statusCode = response.statusCode
        print("STATUS CODE ",statusCode)
        if successCodes.contains(statusCode) {
            processResponseData(data)
        } else if failureCodes.contains(statusCode) {
            if let data = data, let responseBody = try? JSONSerialization.jsonObject(with: data, options: []) {
                debugPrint(responseBody)
            }
            completeWithError(RequestError.http(status: statusCode))
        } else {
            // Server returned response with status code different than expected `successCodes`.
            let info = [
                NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
                NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoing mapping or backend bug."
            ]
            let error = NSError(domain: "NetworkService", code: 0, userInfo: info)
            completeWithError(error)
        }
    }

    func processResponseData(_ data: Data?) {
        completeOperation()
    }

}
