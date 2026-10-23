import Foundation
import AVFoundation

class RingbackPlayer {
    private var audioPlayer: AVAudioPlayer?
    private let lock = NSLock()
    private var isPlaying = false

    init() {}

    func start() {
        lock.lock()
        defer { lock.unlock() }
        if isPlaying { return }

        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.module
        #else
        let resourceBundle = Bundle(for: RingbackPlayer.self)
        #endif
        guard let url = resourceBundle.url(forResource: "ringback", withExtension: "wav")
                ?? Bundle.main.url(forResource: "ringback", withExtension: "wav") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // loop indefinitely
            player.prepareToPlay()
            player.play()
            self.audioPlayer = player
            self.isPlaying = true
        } catch {
            // Log without sensitive data
        }
    }

    func stop() {
        lock.lock()
        defer { lock.unlock() }
        if !isPlaying && audioPlayer == nil { return }
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

