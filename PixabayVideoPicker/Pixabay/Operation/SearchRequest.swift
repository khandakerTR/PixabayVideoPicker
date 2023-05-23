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

    
    func parseJSON(_ pixabay: Data) -> [PixabayHitModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PixabayResult.self, from: pixabay)
            let hits = decodedData.hits
            var pHits = [PixabayHitModel]()
            for hit in hits {
                let pixabayhit = PixabayHitModel(id: hit.id, pageURL: hit.pageURL, type: hit.type, tags: hit.tags, duration: hit.duration, pictureID: hit.pictureID, videos: hit.videos, views: hit.views, downloads: hit.downloads, likes: hit.likes, comments: hit.comments, userID: hit.userID, user: hit.user, userImageURL: hit.userImageURL)
                pHits.append(pixabayhit)
            }
            print("PPPPPP HIT",pHits.count)
            return pHits
        } catch {
            return nil
        }
    }
    
    override func processResponseData(_ data: Data?) {
        if let photos = parseJSON(data!) {
            self.items = photos
            completeOperation()
        }
        super.processResponseData(data)
    }

}


