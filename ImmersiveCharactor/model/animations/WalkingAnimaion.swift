import SwiftUI
import RealityKit
import RealityKitContent

class WalkingAnimaion : AnimationDelegate {
    private var animationSubscription: EventSubscription?
    let animationLibrary: AnimationLibraryComponent
    let charactor: Entity
    
    var target: Entity
    
    let walking: AnimationResource
    
    init(charactor: Entity, target: Entity) {
        guard let animationLibrary = charactor.animationLibraryComponent,
              let walking = animationLibrary.animations[CharacterAnimationKey.walking.rawValue]?.repeat() else {
            fatalError()
        }
        self.animationLibrary = animationLibrary
        self.charactor = charactor
        self.walking = walking
        self.target = target
    }
    
    func play(rotation: simd_quatf?, content: RealityViewContent) async {
        if animationSubscription != nil {
            return
        }
        var transform = await target.transform
        if let rotation {
            transform.rotation = rotation
        }
        transform.translation = await SIMD3(charactor.transform.translation.x, charactor.transform.translation.y, transform.translation.z - 0.8)
        
        let charactorPlaybackController = await charactor.playAnimation(walking, startsPaused: false)
        let duration: Double = 1
        
        let moveAnimationPlaybackController = await charactor.move(to: transform, relativeTo: nil, duration: duration)
        animationSubscription = content.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: charactor) { e in
            if(e.playbackController == moveAnimationPlaybackController) {
                charactorPlaybackController.stop()
                self.animationSubscription?.cancel()
                self.animationSubscription = nil
            }
        }
    }
    
    func stop(rotation: simd_quatf?, content: RealityViewContent) async {
    }
}
