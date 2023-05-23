//
//  VideosRequest.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import Foundation

class VideosRequest: PixabayPagedRequest {

    static func cursor(with searchQuery: String,page: Int = 1, perPage: Int = 200) -> PixabayPagedRequest.Cursor {
        let parameters: [String: Any] = ["id": searchQuery]
        return Cursor(page: page, perPage: perPage, parameters: parameters)
    }

    convenience init(for collectionId: String, page: Int = 1, perPage: Int = 200) {
        let cursor = VideosRequest.cursor(with: collectionId, page: page, perPage: perPage)
        self.init(with: cursor)
    }

    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters()
        parameters?["id"] = nil
        return parameters
    }

    // MARK: - Process the response

    override func processResponseData(_ data: Data?) {
        if let photos = parseJSON(data!) {
            self.items = photos
            completeOperation()
        }
        super.processResponseData(data)
    }
    
    func parseJSON(_ pixabay: Data) -> [PixabayHitModel]? {
        let decoder = JSONDecoder()
        do {
            print("data ..... ",pixabay)
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

}


