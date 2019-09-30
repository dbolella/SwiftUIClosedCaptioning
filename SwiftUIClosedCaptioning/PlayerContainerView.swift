//
//  PlayerContainerView.swift
//  SwiftUIClosedCaptioning
//
//  Created by Daniel Bolella on 9/30/19.
//  Copyright © 2019 Daniel Bolella. All rights reserved.
//

import SwiftUI
import AVFoundation

// This is the UIView that contains the AVPlayerLayer for rendering the video
class PlayerUIView: UIView {
    private let player: AVPlayer
    private let playerLayer = AVPlayerLayer()
    private let videoPos: Binding<Double>
    private let videoDuration: Binding<Double>
    private let seeking: Binding<Bool>
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
  
    init(player: AVPlayer, videoPos: Binding<Double>, videoDuration: Binding<Double>, seeking: Binding<Bool>) {
        self.player = player
        self.videoDuration = videoDuration
        self.videoPos = videoPos
        self.seeking = seeking
        
        super.init(frame: .zero)
    
        backgroundColor = .lightGray
        playerLayer.player = player
        layer.addSublayer(playerLayer)
        
        // Observe the duration of the player's item so we can display it
        // and use it for updating the seek bar's position
        durationObservation = player.currentItem?.observe(\.duration, changeHandler: { [weak self] item, change in
            guard let self = self else { return }
            self.videoDuration.wrappedValue = item.duration.seconds
        })
        
        // Observe the player's time periodically so we can update the seek bar's
        // position as we progress through playback
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            // If we're not seeking currently (don't want to override the slider
            // position if the user is interacting)
            guard !self.seeking.wrappedValue else {
                return
            }
        
            // update videoPos with the new video time (as a percentage)
            self.videoPos.wrappedValue = time.seconds / self.videoDuration.wrappedValue
        }
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
    
        playerLayer.frame = bounds
    }
    
    func cleanUp() {
        // Remove observers we setup in init
        durationObservation?.invalidate()
        durationObservation = nil
        
        if let observation = timeObservation {
            player.removeTimeObserver(observation)
            timeObservation = nil
        }
    }
  
}

// This is the SwiftUI view which wraps the UIKit-based PlayerUIView above
struct PlayerView: UIViewRepresentable {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    
    let player: AVPlayer
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        // This function gets called if the bindings change, which could be useful if
        // you need to respond to external changes, but we don't in this example
    }
    
    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> UIView {
        let uiView = PlayerUIView(player: player,
                                  videoPos: $videoPos,
                                  videoDuration: $videoDuration,
                                  seeking: $seeking)
        return uiView
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let playerUIView = uiView as? PlayerUIView else {
            return
        }
        
        playerUIView.cleanUp()
    }
}

// This is the SwiftUI view that contains the controls for the player
struct PlayerControlsView : View {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    
    let player: AVPlayer
    
    @State private var playerPaused = true
    
    var body: some View {
        HStack {
            // Play/pause button
            Button(action: togglePlayPause) {
                Image(systemName: playerPaused ? "play" : "pause")
                    .padding(.trailing, 10)
            }
            // Current video time
            Text("\(Utility.formatSecondsToHMS(videoPos * videoDuration))")
            // Slider for seeking / showing video progress
            Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
            // Video duration
            Text("\(Utility.formatSecondsToHMS(videoDuration))")
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
    
    private func togglePlayPause() {
        pausePlayer(!playerPaused)
    }
    
    private func pausePlayer(_ pause: Bool) {
        playerPaused = pause
        if playerPaused {
            player.pause()
        }
        else {
            player.play()
        }
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Set a flag stating that we're seeking so the slider doesn't
            // get updated by the periodic time observer on the player
            seeking = true
            pausePlayer(true)
        }
        
        // Do the seek if we're finished
        if !editingStarted {
            let targetTime = CMTime(seconds: videoPos * videoDuration,
                                    preferredTimescale: 600)
            player.seek(to: targetTime) { _ in
                // Now the seek is finished, resume normal operation
                self.seeking = false
                self.pausePlayer(false)
            }
        }
    }
}

// This is the SwiftUI view which contains the player and its controls
struct PlayerContainerView : View {
    // The progress through the video, as a percentage (from 0 to 1)
    @State private var videoPos: Double = 0
    // The duration of the video in seconds
    @State private var videoDuration: Double = 0
    // Whether we're currently interacting with the seek bar or doing a seek
    @State private var seeking = false
    
    @ObservedObject var closedCaptioning: ClosedCaptioning
    private let vmInput: VideoMediaInput
  
    init(url: URL) {
        closedCaptioning = ClosedCaptioning()
        vmInput = VideoMediaInput(url: url)
    }
  
    var body: some View {
        ZStack {
            VStack {
                PlayerView(videoPos: $videoPos, videoDuration: $videoDuration, seeking: $seeking, player: vmInput.player)
                    .frame(height:350)
                PlayerControlsView(videoPos: $videoPos, videoDuration: $videoDuration, seeking: $seeking, player: vmInput.player)
            }
            .padding()
            .onAppear {
                self.vmInput.delegate = self.closedCaptioning
            }

            Text(self.closedCaptioning.captioning)
                .font(.body)
                .background(Color.black.opacity(0.5))
                .foregroundColor(Color.white)
                .offset(y:100)
//                .frame(height:350)
                .truncationMode(.head)
                .lineLimit(1)
                .padding()
        }
    }
}

struct PlayerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerContainerView(url: Bundle.main.url(forResource: "imac7", withExtension: "mp4")!)
    }
}
