//
//  ContentView.swift
//  ImmersiveCharactor
//
//  Created by Satoshi Asada on 2024/12/12.
//

import SwiftUI
import RealityKit

struct OrnamentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    OrnamentView()
        .environment(AppModel())
}
