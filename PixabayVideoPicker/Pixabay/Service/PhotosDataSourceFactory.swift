//
//  PhotosDataSourceFactory.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import UIKit

protocol PagedDataSourceFactory {
    func initialCursor() -> PixabayPagedRequest.Cursor
    func request(with cursor: PixabayPagedRequest.Cursor) -> PixabayPagedRequest
}

enum EmptyViewState {
    case noResults
    case noInternetConnection
    case serverError

    var title: String {
        switch self {
        case .noResults:
            return "No results"
        case .noInternetConnection:
            return "No Internet Connection"
        case .serverError:
            return "Server error"
        }
    }

    var description: String {
        switch self {
        case .noResults:
            return "Please update your search and try again."
        case .noInternetConnection:
            return "You must connect to a Wi-Fi or cellular data network to access Pixabay"
        case .serverError:
            return "Oops! Something's wrong. Please try again."
            
        }
    }
}
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
