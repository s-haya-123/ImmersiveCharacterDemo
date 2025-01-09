
import SwiftUI
import RealityKit
import RealityKitContent

struct VolumeticView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(CharactorModel.self) private var charactorModel
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Volumetirc", in: realityKitContentBundle) {
                content.add(scene)
                charactorModel.setCharactor(
                    entity: scene,
                    content: content
                );
            }
        } update: { content in
            guard charactorModel.convertingRobotFromVolume else { return }

            // Convert the robot transform from RealityKit scene space for
            // the volume to SwiftUI immersive space
            charactorModel.convertRobotFromRealityKitToImmersiveSpace(content: content)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    VolumeticView()
        .environment(AppModel())
}
