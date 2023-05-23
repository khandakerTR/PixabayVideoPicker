//
//  ViewController.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView?.collectionViewLayout = WaterfallLayout(with: self)
        }
    }
    private var searchText: String?
    var dataSource: PagedDataSource! {
        didSet {
            dataSource.delegate = self
        }
    }
    var editorialDataSource = PhotosDataSourceFactory.collection.dataSource
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       dataSource = editorialDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if dataSource.items.count == 0 {
            refresh()
        }
    }
    
    @objc func refresh() {
        guard dataSource.items.isEmpty else { return }

        if dataSource.isFetching == false && dataSource.items.count == 0 {
            dataSource.reset()
            collectionView.reloadData()
            fetchNextItems()
        }
    }
    
    func fetchNextItems() {
        dataSource.fetchNextPage()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let video = dataSource.items[indexPath.item]
        cell.configure(with: video)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoURL = URL(string: dataSource.items[indexPath.item].videos.large.url)!
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let prefetchCount = 10
        if indexPath.item == dataSource.items.count - prefetchCount {
            print("IndexPath",indexPath.item, "dataSource.items.count",dataSource.items.count, "prefetchCount",prefetchCount)
            fetchNextItems()
        }
    }
}


extension ViewController: PagedDataSourceDelegate {
    func dataSourceWillStartFetching(_ dataSource: PagedDataSource) {
        
    }
    
    func dataSource(_ dataSource: PagedDataSource, didFetch items: [PixabayHitModel]) {
        guard items.count > 0 else { return }
        guard dataSource.items.count > 0 else {

            return
        }

        let newPhotosCount = items.count
        let startIndex = self.dataSource.items.count - newPhotosCount
        let endIndex = startIndex + newPhotosCount
        var newIndexPaths = [IndexPath]()
        for index in startIndex..<endIndex {
            newIndexPaths.append(IndexPath(item: index, section: 0))
        }

        DispatchQueue.main.async { [unowned self] in
            print("self.dataSource.items.count",self.dataSource.items.count)
            let hasWindow = self.collectionView.window != nil
            let collectionViewItemCount = self.collectionView.numberOfItems(inSection: 0)
            if hasWindow && collectionViewItemCount < dataSource.items.count {
                self.collectionView.insertItems(at: newIndexPaths)
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    func dataSource(_ dataSource: PagedDataSource, fetchDidFailWithError error: Error) {
//        let state: EmptyViewState = (error as NSError).isNoInternetConnectionError() ? .noInternetConnection : .serverError
    }
}

extension ViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("IndexPath",dataSource.items[indexPath.item].id)
        guard let video = dataSource.item(at: indexPath.item) else { return .zero }
        print("IMAGE WIDTH> ",video.videos.large.width, "HEIGHT ",video.videos.large.height)
        return CGSize(width: video.videos.tiny.width, height: video.videos.tiny.height)
  
    }
    
}
