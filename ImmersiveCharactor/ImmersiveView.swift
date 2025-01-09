//
//  ImmersiveView.swift
//  ImmersiveCharactor
//
//  Created by Satoshi Asada on 2024/12/12.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @Environment(CharactorModel.self) private var charactorModel
    @State var immersionAmount: Double?

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
            content.add(charactorModel.immersiveSpaceRoot)
            charactorModel.convertingRobotFromVolume = true
            charactorModel.changeContent(content: content)
        } update: { content in
            guard charactorModel.convertingRobotToImmersiveSpace else { return }

            // Convert the robot transform from SwiftUI space for the immersive
            // space to RealityKit scene space
            charactorModel.convertRobotFromSwiftUIToRealityKitSpace(content: content)
        }
        .onImmersionChange { oldContext, newContext in
            immersionAmount = newContext.amount
        }
        .onChange(of: immersionAmount) { oldValue, newValue in
            handleImmersionAmountChanged(newValue: newValue, oldValue: oldValue)
        }
    }
    
    func handleImmersionAmountChanged(newValue: Double?, oldValue: Double?) {
        guard let newValue, let oldValue else {
            return
        }
        
        if oldValue == 0 {
            return
        }

        if newValue > oldValue {
            // Move the robot outward to react to increasing immersion
//            moveRobotOutward()
            charactorModel.moveCharactorInward()
        } else if newValue < oldValue {
            // Move the robot inward to react to decreasing immersion
            charactorModel.moveCharactorInward()
        }
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
