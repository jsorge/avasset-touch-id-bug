//
//  VideoPlayerView.swift
//  zulily
//
//  Created by Jared Sorge on 3/14/17.
//  Copyright © 2017 zulily. All rights reserved.
//

import UIKit
import AVFoundation

public enum VideoPlaybackState {
    case played, unplayed
}

public final class VideoPlayerView: UIView {
    //MARK: API
    /// The Bool parameter is for whether or not the playback completed
    public typealias PlaybackStoppedCompletion = (_: Bool) -> Void
    
    public struct ConfigHooks {
        public let playbackStarted: (() -> Void)?
        public let playbackStopped: PlaybackStoppedCompletion?
    }

    public var hooks: ConfigHooks?
    
    @objc(playFromURL:)
    public func play(from url: URL) {
        let asset = AVAsset(url: url)
        play(from: asset)
    }
    
    @objc(playFromAsset:)
    public func play(from asset: AVAsset) {
        let assetKeys = [
            "playable"
        ]
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        _playerItem = item
        play()
    }
    
    //MARK: Override
    override public static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public override func observeValue(forKeyPath _keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = _keyPath, context == _kvoContext else {
            super.observeValue(forKeyPath: _keyPath, of: object, change: change, context: context)
            return
        }
        
        if object as? AVPlayer == player {
            switch keyPath {
            case _reasonForWaitingToPlayKey:
                // The video has buffered enough to call the playback started hook if the player has been told to play, and there is no reason to be waiting
                if player?.rate != 0, change?[.newKey] as? String == nil {
                    self.hooks?.playbackStarted?()
                }
                return
            default:
                break
            }
        }
        else if object as? AVPlayerItem == _playerItem {
            switch keyPath {
            case _itemStatusKey:
                guard let encodedStatus = change?[.newKey] as? Int, let status = AVPlayerItemStatus(rawValue: encodedStatus) else { break }
                switch status {
                case .readyToPlay:
                    player?.play()
                default:
                    break
                }
                return
            default:
                break
            }
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    deinit {
        if let token = _noteToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    //MARK: Private
    fileprivate var player: AVPlayer? {
        get {
            return _playerLayer.player
        }
        set {
            _playerLayer.player = newValue
        }
    }

    fileprivate var _noteToken: NSObjectProtocol?
    fileprivate var _kvoContext = UnsafeMutableRawPointer(bitPattern: 0)
    fileprivate var _playerItem: AVPlayerItem?
    fileprivate let _reasonForWaitingToPlayKey = #keyPath(AVPlayer.reasonForWaitingToPlay)
    fileprivate let _itemStatusKey = #keyPath(AVPlayerItem.status)
    
    private var _playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    fileprivate func commonInit() {
        player = AVPlayer(playerItem: nil)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
    }
    
    /// Plays the current item.
    /// Sets up the machinery to observe the item and player for playback events and reports that back through any configured hooks
    fileprivate func play() {
        guard let item = _playerItem else { hooks?.playbackStopped?(false); return }
        item.addObserver(self, forKeyPath: _itemStatusKey, options: [.old, .new], context: _kvoContext)

        let center = NotificationCenter.default
        let token = center.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] (note) in
            guard let strongSelf = self else { return }
            strongSelf.hooks?.playbackStopped?(true)
            
            if let _noteToken = strongSelf._noteToken {
                center.removeObserver(_noteToken)
                strongSelf.player?.removeObserver(strongSelf, forKeyPath: strongSelf._reasonForWaitingToPlayKey, context: strongSelf._kvoContext)
                item.removeObserver(strongSelf, forKeyPath: strongSelf._itemStatusKey, context: strongSelf._kvoContext)
                self?._noteToken = nil
            }
        }
        _noteToken = token
        
        player?.addObserver(self, forKeyPath: _reasonForWaitingToPlayKey, options: [.old, .new], context: _kvoContext)
        player?.replaceCurrentItem(with: item)
    }
}
