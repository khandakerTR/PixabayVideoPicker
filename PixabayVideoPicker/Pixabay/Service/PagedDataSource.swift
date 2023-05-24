//
//  PagedDataSource.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import UIKit

protocol PagedDataSourceDelegate: AnyObject {
    func dataSourceWillStartFetching(_ dataSource: PagedDataSource)
    func dataSource(_ dataSource: PagedDataSource, didFetch items: [PixabayHitModel])
    func dataSource(_ dataSource: PagedDataSource, fetchDidFailWithError error: Error)
}

class PagedDataSource {

    enum DataSourceError: Error {
        case dataSourceIsFetching
        case wrongItemsType(Any)

        var localizedDescription: String {
            switch self {
            case .dataSourceIsFetching:
                return "The data source is already fetching."
            case .wrongItemsType(let returnedItems):
                return "The request return the wrong item type. Expecting \([PixabayHitModel].self), got \(returnedItems.self)."
            }
        }
    }

    private(set) var items = [PixabayHitModel]()
    private(set) var error: Error?
    private let factory: PagedDataSourceFactory
    private var cursor: PixabayPagedRequest.Cursor
    private(set) var isFetching = false
    private var canFetchMore = true
    private lazy var operationQueue = OperationQueue(with: "com.pixabay.pagedDataSource")

    weak var delegate: PagedDataSourceDelegate?

    init(with factory: PagedDataSourceFactory) {
        self.factory = factory
        self.cursor = factory.initialCursor()
    }

    func reset() {
        operationQueue.cancelAllOperations()
        items.removeAll()
        isFetching = false
        canFetchMore = true
        cursor = factory.initialCursor()
        error = nil
    }

    func fetchNextPage() {
        if isFetching {
            fetchDidComplete(withItems: nil, error: DataSourceError.dataSourceIsFetching)
            return
        }

        if canFetchMore == false {
            fetchDidComplete(withItems: [], error: nil)
            return
        }

        delegate?.dataSourceWillStartFetching(self)

        isFetching = true

        let request = factory.request(with: cursor)
        request.completionBlock = {
            if let error = request.error {
                self.isFetching = false
                self.fetchDidComplete(withItems: nil, error: error)
                return
            }

            guard let items = request.items as? [PixabayHitModel] else {
                self.isFetching = false
                self.fetchDidComplete(withItems: nil, error: DataSourceError.wrongItemsType(request.items))
                return
            }

            if items.count < self.cursor.perPage {
                self.canFetchMore = false
            } else {
                self.cursor = request.nextCursor()
            }
            let filteredItems = items.filter { ($0.videos.tiny.size != 0) && ($0.videos.tiny.url != "") }
            self.items.append(contentsOf: filteredItems)
            self.isFetching = false
            self.fetchDidComplete(withItems: filteredItems, error: nil)
        }

        operationQueue.addOperationWithDependencies(request)
    }

    func cancelFetch() {
        operationQueue.cancelAllOperations()
        isFetching = false
    }

    func item(at index: Int) -> PixabayHitModel? {
        guard index < items.count else {
            return nil
        }

        return items[index]
    }

    // MARK: - Private

    private func fetchDidComplete(withItems items: [PixabayHitModel]?, error: Error?) {
        self.error = error

        if let error = error {
            delegate?.dataSource(self, fetchDidFailWithError: error)
        } else {
            let items = items ?? []
            delegate?.dataSource(self, didFetch: items)
        }
    }

}
