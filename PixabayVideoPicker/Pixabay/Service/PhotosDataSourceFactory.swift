//
//  PhotosDataSourceFactory.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import UIKit

enum PhotosDataSourceFactory: PagedDataSourceFactory {
    case search(query: String)
    case collection

    var dataSource: PagedDataSource {
        return PagedDataSource(with: self)
    }

    func initialCursor() -> PixabayPagedRequest.Cursor {
        switch self {
        case .search(let query):
            return SearchRequest.cursor(with: query, page: 1, perPage: 200)
        case .collection:
            let perPage = 200
            return VideosRequest.cursor(with: "", page: 1, perPage: perPage)
        }
    }

    func request(with cursor: PixabayPagedRequest.Cursor) -> PixabayPagedRequest {
        switch self {
        case .search(let query):
            return SearchRequest(with: query, page: cursor.page, perPage: cursor.perPage)
        case .collection:
            return VideosRequest(for: "", page: cursor.page, perPage: cursor.perPage)
        }
    }
}
