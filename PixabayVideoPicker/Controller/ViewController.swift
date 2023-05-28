//
//  ViewController.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorDescriptionView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView?.collectionViewLayout = WaterfallLayout(with: self)
        }
    }
    private let refreshControl = UIRefreshControl()
    private var searchText: String?
    var dataSource: PagedDataSource! {
        didSet {
            dataSource.delegate = self
        }
    }
    var editorialDataSource = VideosDataSourceFactory.collection.dataSource
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotifications()
        dataSource = editorialDataSource
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl // iOS 10+
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
    
    func playVideo(url: URL) {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
        }

        let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)

        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset = contentInsets
            self?.collectionView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc func keyboardWillHideNotification(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset = .zero
            self?.collectionView.scrollIndicatorInsets = .zero
        }
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then asynchronously remember to stop the
        // refreshing when you've got a result (either positive or negative)
        refreshControl.endRefreshing()
    }
    
    func showErrorView(with title: String, and description: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = title
            self.descriptionLabel.text = description
            self.errorDescriptionView.isHidden = false
        }
    }
    
    func hideErrorView() {
        errorDescriptionView.isHidden = true
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
        
        let videoURL = URL(string: dataSource.items[indexPath.item].videos.tiny.url)!
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
            fetchNextItems()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt
        indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let previewProvider: () -> PreviewViewController? = { [unowned self] in
            let size = CGSize(width: self.dataSource.items[indexPath.row].videos.tiny.width, height: self.dataSource.items[indexPath.row].videos.tiny.height)
            return PreviewViewController(url: self.dataSource.items[indexPath.row].videos.tiny.url, size: size)
        }
        return UIContextMenuConfiguration(previewProvider: previewProvider)
    }
}


extension ViewController: PagedDataSourceDelegate {
    func dataSourceWillStartFetching(_ dataSource: PagedDataSource) {
        
    }
    
    func dataSource(_ dataSource: PagedDataSource, didFetch items: [PixabayHitModel]) {
        guard items.count > 0 else {
            //No data found on this Search
            return
            
        }
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
        let state: EmptyViewState = (error as NSError).isNoInternetConnectionError() ? .noInternetConnection : .serverError
       
            self.showErrorView(with: state.title, and: state.description)
      
        print("ERROR",error.localizedDescription)
    }
}

extension ViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let video = dataSource.item(at: indexPath.item) else { return .zero }
        return CGSize(width: video.videos.tiny.width, height: video.videos.tiny.height)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text else { return }
        let escapedQuery = text.replacingOccurrences(of: " ", with: "+")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        setSearchText(escapedQuery)
        refresh()
        scrollToTop()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.searchText != nil && searchText.isEmpty else { return }

        setSearchText(nil)
        refresh()
        reloadData()
        scrollToTop()
    }
    
    private func setSearchText(_ text: String?) {
        if let text = text, text.isEmpty == false {
            dataSource = VideosDataSourceFactory.search(query: text).dataSource
            searchText = text
        } else {
            dataSource = editorialDataSource
            searchText = nil
        }
    }
    
    private func scrollToTop() {
        let contentOffset = CGPoint(x: 0, y: -collectionView.safeAreaInsets.top)
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}
