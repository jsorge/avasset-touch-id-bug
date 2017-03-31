//
//  ViewController.swift
//  Video Test
//
//  Created by Jared Sorge on 3/29/17.
//  Copyright © 2017 zulily. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var label: UILabel!
    private let keychain = KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchKeychainValue()
    }
    
    private let itemKey = "MyItem"
    @IBAction private func addKeychainItem() {
        let item = "This is in the keychain 🎉".data(using: .utf8)!
        if keychain.save(toKeychain: item, withKey: itemKey) {
            label.text = "Saved message to the keychain"
        }
        else {
            label.text = "Failed to save message to the keychain"
        }
    }
    
    @IBAction private func clearKeychain() {
        if keychain.clearAll() {
            label.text = "Cleared the keychain"
        }
        else {
            label.text = "Failed to clear the keychain"
        }
    }
    
    @IBAction private func fetchKeychainValue() {
        guard let storedData = keychain.value(forKey: itemKey)
            else {
                label.text = "No item stored"
                return
        }
        
        if let text = String(data: storedData, encoding: .utf8) {
            label.text = text
        }
        else {
            label.text = "Could not decode stored value"
        }
    }
    
    @IBAction func playVideo() {
        let videoView = VideoPlayerView(frame: .zero)
        view.addSubview(videoView)
        videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let url = URL(string: "https://s3.amazonaws.com/zujsorge/phone_v2.mp4")!
        
        let hooks = VideoPlayerView.ConfigHooks(playbackStarted: nil) { (_) in
            videoView.removeFromSuperview()
        }
        videoView.hooks = hooks
        videoView.play(from: url)
    }
}

