import SwiftUI
import RealityKit
import RealityKitContent

class CharactorAnimationController {
    private var animationSubscription: EventSubscription?
    private var content: RealityViewContent? = nil
    
    private let idleAnimation: AnimationDelegate
    private let jumpAnimation: AnimationDelegate
    private let walkingAnimation: AnimationDelegate
    
    init(charactor: Entity, content: RealityViewContent, immersiveSpaceRoot: Entity) {
        self.idleAnimation = IdleAnimation(charactor: charactor)
        self.jumpAnimation = JumpAnimation(charactor: charactor, target: immersiveSpaceRoot)
        self.walkingAnimation = WalkingAnimaion(charactor: charactor, target: immersiveSpaceRoot)
        self.content = content
    }
    
    func changeContent(content: RealityViewContent) {
        self.content = content
    }
    
    func startJump() {
        guard let _content = self.content else {
            return
        }
        let rotation = simd_quatf(ix: 0.0, iy: 1.0, iz: 0.0, r: 0.0)
        Task {
            await idleAnimation.stop(rotation: rotation, content: _content)
            await jumpAnimation.play(rotation: rotation, content: _content)
        }
    }
    
    func moveCharactorInward() async {
        guard let _content = self.content else {
            return
        }
        let rotation = simd_quatf(ix: 0.0, iy: 1.0, iz: 0.0, r: 0.0)
        await walkingAnimation.play(rotation: rotation, content: _content)
    }
    
    func startIdle() {
        guard let _content = self.content else {
            return
        }
        Task {
            await idleAnimation.play(rotation: nil, content: _content)
        }
    }
}

