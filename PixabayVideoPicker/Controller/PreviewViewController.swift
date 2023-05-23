//
//  PreviewViewController.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 23/5/23.
//

import UIKit
import AVKit

class PreviewViewController: UIViewController {
    
    private var player: AVPlayer!
    private let avPlayerController = AVPlayerViewController()
    private let url: URL
    private let size: CGSize
    let videoPlayerView = UIView()
    
    init(url: String, size: CGSize) {
        self.url = URL(string: url)!
        self.size = size
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        startVideo()
    }
    
    func setupView() {
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(videoPlayerView)
        NSLayoutConstraint.activate([
            videoPlayerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoPlayerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoPlayerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoPlayerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func startVideo() {
        player = AVPlayer(url: self.url)
        avPlayerController.player = player
        avPlayerController.view.frame.size.width = videoPlayerView.frame.size.width
        avPlayerController.view.frame.size.height =  videoPlayerView.frame.size.height
        self.videoPlayerView.addSubview(avPlayerController.view)
        let width = view.bounds.width
        let height = size.height * (width / size.width)
        preferredContentSize = CGSize(width: width, height: height)
        player.play()
    }
}
