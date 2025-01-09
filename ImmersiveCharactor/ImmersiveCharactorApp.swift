//
//  ImmersiveCharactorApp.swift
//  ImmersiveCharactor
//
//  Created by Satoshi Asada on 2024/12/12.
//

import SwiftUI

@main
struct ImmersiveCharactorApp: App {

    @State private var appModel = AppModel()
    @State private var charactorModel = CharactorModel()

    var body: some Scene {
        WindowGroup {
            VolumeticView()
                .volumeBaseplateVisibility(.visible)
                .ornament(attachmentAnchor: .scene(.topBack)) {
                    OrnamentView()
                        .environment(appModel)
                }
                .environment(appModel)
                .environment(charactorModel)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(charactorModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
