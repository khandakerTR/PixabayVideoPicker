//
//  SearchRequest.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import Foundation

class SearchRequest: PixabayPagedRequest {

    static func cursor(with query: String, page: Int = 1, perPage: Int = 200) -> PixabayPagedRequest.Cursor {
        let parameters = ["q": query]
        return Cursor(page: page, perPage: perPage, parameters: parameters)
    }

    convenience init(with query: String, page: Int = 1, perPage: Int = 200) {
        let cursor = SearchRequest.cursor(with: query, page: page, perPage: perPage)
        self.init(with: cursor)
    }
    
    override func processResponseData(_ data: Data?) {
        if let photos = parseJSON(data!) {
            self.items = photos
            completeOperation()
        }
        super.processResponseData(data)
    }

}


