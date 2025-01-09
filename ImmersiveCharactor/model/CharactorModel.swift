import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
@Observable
class CharactorModel {
    private var content: RealityViewContent? = nil
    // 回転軸
    let rotation_axis = simd_float3(x: 0, y: 1, z: 0)
    let immersiveSpaceRoot = Entity()

    var convertingRobotFromVolume: Bool = false
    var convertingRobotToImmersiveSpace: Bool = false
    var charactor: Entity? = nil
    var immersiveSpaceFromRobot: AffineTransform3D?
    var charactorAnimationController: CharactorAnimationController?
    
    var animationSubscription: EventSubscription?
    
    private var state: CharacterAnimationKey? = nil

    func setCharactor(entity: Entity, content: RealityViewContent) {
        entity.transform.translation = [0,-0.5,0.3]
        entity.transform.scale = [0.5,0.5,0.5]
        entity.transform.rotation = simd_quatf(angle: degreesToRadians(-90),
                                               axis: rotation_axis)
        
        Task {
            await setAnimation(entity: entity)
            charactorAnimationController = CharactorAnimationController(
                charactor: entity,
                content: content,
                immersiveSpaceRoot: immersiveSpaceRoot
            )
            charactorAnimationController?.startIdle()
            charactor = entity
        }
    }
    func changeContent(content: RealityViewContent) {
        self.content = content
        charactorAnimationController?.changeContent(content: content)
    }
    
    private func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * .pi / 180
    }
    
    // AnimationControllerに持って行きたいがcomponentsを使っているのでここで設定を行っている
    private func setAnimation(entity: Entity) async {
        for animationName in CharacterAnimationKey.allCases {
            let animationDirectory = "animations/\(animationName.rawValue)"
            if let rootEntity = try? await Entity(named: animationDirectory, in: realityKitContentBundle) {
                if let _entity = rootEntity.findEntity(named: "Nekoyama_nae_PB") {
                    if let animationLibraryComponent = _entity.components[AnimationLibraryComponent.self] {
                        guard var _animationLibrary = entity.components[AnimationLibraryComponent.self] else { return }
                        animationLibraryComponent.animations.forEach { anim in
                            print(anim)
                        }
                        _animationLibrary.animations[animationName.rawValue] = animationLibraryComponent.defaultAnimation
                        entity.components[AnimationLibraryComponent.self] = _animationLibrary
                    }
                }
            }
        }
    }
    
    func convertRobotFromRealityKitToImmersiveSpace(content: RealityViewContent) {
        guard charactor != nil else { return }
        
        immersiveSpaceFromRobot =
        content.transform(from: charactor!, to: .immersiveSpace)
        
        // Reparent robot from volume to immersive space
        charactor!.setParent(immersiveSpaceRoot)
        
        // Handoff to immersive space view to continue conversions.
        convertingRobotFromVolume = false
        convertingRobotToImmersiveSpace = true
    }
    
    func convertRobotFromSwiftUIToRealityKitSpace(content: RealityViewContent) {
        guard immersiveSpaceFromRobot != nil else { return }
        // Calculate transform from SwiftUI immersive space to RealityKit
        // scene space
        let realityKitSceneFromImmersiveSpace =
        content.transform(from: .immersiveSpace, to: .scene)
        
        // Multiply with the robot's transform in SwiftUI immersive space to build a
        // transformation which converts from the robot's local
        // coordinate space in the volume and ends with the robot's local
        // coordinate space in an immersive space.
        let realityKitSceneFromRobot =
        realityKitSceneFromImmersiveSpace * immersiveSpaceFromRobot!
        
        // Place the robot in the immersive space to match where it
        // appeared in the volume
        charactor!.transform = Transform(realityKitSceneFromRobot)
        convertingRobotToImmersiveSpace = false
        
        // Start the jump!
        charactorAnimationController?.startJump()
    }
    
    func moveCharactorInward() {
        Task {
            await charactorAnimationController?.moveCharactorInward()
        }
    }
}
