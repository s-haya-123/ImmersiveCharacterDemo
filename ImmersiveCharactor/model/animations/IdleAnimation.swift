import SwiftUI
import RealityKit
import RealityKitContent

class IdleAnimation : AnimationDelegate {
    private var animationSubscription: EventSubscription?
    let animationLibrary: AnimationLibraryComponent
    let charactor: Entity
    
    let loopStart: AnimationResource
    let loop: AnimationResource
    let loopEnd: AnimationResource
    
    init(charactor: Entity) {
        guard let animationLibrary = charactor.animationLibraryComponent,
              let loopStart = animationLibrary.defaultAnimation,
              let loopEnd = animationLibrary.animations[CharacterAnimationKey.loop_end.rawValue],
              let loop = animationLibrary.animations[CharacterAnimationKey.loop.rawValue]?.repeat() else {
            fatalError()
        }
        self.animationLibrary = animationLibrary
        self.charactor = charactor
        self.loopStart = loopStart
        self.loopEnd = loopEnd
        self.loop = loop
    }
    
    func play(rotation: simd_quatf?, content: RealityViewContent) async {
        await charactor.playAnimation(loopStart, startsPaused: false)
        
        animationSubscription = content.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: charactor) { _ in
            self.charactor.playAnimation(self.loop, startsPaused: false)
            self.animationSubscription?.cancel()
        }
    }
    
    func stop(rotation: simd_quatf?, content: RealityViewContent) async {
        var target = await charactor.transform
        if let rotation {
            target.rotation = rotation
        }
        
        await withCheckedContinuation { continuation in
            animationSubscription = content.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: charactor) { _ in
                self.animationSubscription?.cancel()
                continuation.resume() // 非同期タスクを終了
            }
            let charactorPlaybackController = charactor.playAnimation(loopEnd, startsPaused: false)
            charactor.move(to: target, relativeTo: nil, duration: charactorPlaybackController.duration)
        }
    }
}
