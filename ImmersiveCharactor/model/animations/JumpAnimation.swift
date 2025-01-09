import SwiftUI
import RealityKit
import RealityKitContent

class JumpAnimation : AnimationDelegate {
    private var animationSubscription: EventSubscription?
    let animationLibrary: AnimationLibraryComponent
    let charactor: Entity
    
    let target: Entity
    
    let jumpUp: AnimationResource
    let jumpDown: AnimationResource
    
    init(charactor: Entity, target: Entity) {
        guard let animationLibrary = charactor.animationLibraryComponent,
              let jumpUp = animationLibrary.animations[CharacterAnimationKey.jump_up.rawValue],
              let jumpDown = animationLibrary.animations[CharacterAnimationKey.jump_down.rawValue] else {
            fatalError()
        }
        self.animationLibrary = animationLibrary
        self.charactor = charactor
        self.jumpUp = jumpUp
        self.jumpDown = jumpDown
        self.target = target
    }
    
    func play(rotation: simd_quatf?, content: RealityViewContent) async {
        var charactorTransform = await charactor.transform
        var rootTransform = await target.transform
        
        rootTransform.translation = await SIMD3(charactor.transform.translation.x, rootTransform.translation.y, charactor.transform.translation.z)
        if let rotation {
            charactorTransform.rotation = rotation
            rootTransform.rotation = rotation
        }
        
        animationSubscription = content.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: charactor) { _ in
            let charactorPlaybackController = self.charactor.playAnimation(self.jumpDown, startsPaused: false)
            self.charactor.move(to: rootTransform, relativeTo: nil, duration: charactorPlaybackController.duration)
            self.animationSubscription?.cancel()
        }
        await charactor.playAnimation(jumpUp, startsPaused: false)
    }
    
    func stop(rotation: simd_quatf?, content: RealityViewContent) async {
    }
}
