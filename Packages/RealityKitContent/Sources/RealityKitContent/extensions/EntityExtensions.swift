/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A component that marks an entity as a plant.
*/

import Foundation
import RealityKit

public extension Entity {
    var animationLibraryComponent: AnimationLibraryComponent? {
        get { components[AnimationLibraryComponent.self] }
        set { components[AnimationLibraryComponent.self] = newValue }
    }
}
