//
//  VideoPlayer.swift
//
//  Created by Dylan Marcus on 12/9/21.
//

import UIKit
import AVKit

class VideoPlayer: UIView {
    @IBOutlet weak var vwPlayer: UIView!
    var videoplayer: AVPlayer?
    var currentLoadedURL: URL!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    fileprivate func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("VideoPlayer", owner: self, options: nil)[0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        addPlayerToView(self.vwPlayer)
    }
    
    fileprivate func addPlayerToView(_ view: UIView) {
        videoplayer = AVPlayer()
        let videoplayerLayer = AVPlayerLayer(player: videoplayer)
        videoplayerLayer.frame = self.bounds
        videoplayerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoplayerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playVideoWithFileName(_ fileName: String, ofType type:String) {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: type) else { return }
        let videoURL = URL(fileURLWithPath: filePath)
        currentLoadedURL = videoURL
        let playerItem = AVPlayerItem(url: videoURL)
        videoplayer?.replaceCurrentItem(with: playerItem)
        videoplayer?.play()
    }
    
    @objc func playerEndPlay() {
        print("Player ends playing video")
    }
}
