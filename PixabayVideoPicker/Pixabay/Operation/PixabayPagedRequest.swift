//
//  PixabayPagedRequest.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import Foundation

class PixabayPagedRequest: PixabayRequest {

    struct Cursor {
        let page: Int
        let perPage: Int
        let parameters: [String: Any]?
    }

    let cursor: Cursor

    var items = [Any]()

    init(with cursor: Cursor) {
        self.cursor = cursor
        super.init()
    }

    convenience init(with page: Int = 1, perPage: Int = 200) {
        self.init(with: Cursor(page: page, perPage: perPage, parameters: nil))
    }

    func nextCursor() -> Cursor {
        return Cursor(page: cursor.page + 1, perPage: cursor.perPage, parameters: cursor.parameters)
    }

    // MARK: - Prepare the request

    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters() ?? [String: Any]()
        parameters["page"] = cursor.page
        parameters["per_page"] = cursor.perPage

        if let cursorParameters = cursor.parameters {
            for (key, value) in cursorParameters {
                parameters[key] = value
            }
        }

        return parameters
    }
}

