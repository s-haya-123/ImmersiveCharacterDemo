import SwiftUI
import RealityKit

protocol AnimationDelegate {
    func play(rotation: simd_quatf?, content: RealityViewContent) async
    func stop(rotation: simd_quatf?, content: RealityViewContent) async
}
