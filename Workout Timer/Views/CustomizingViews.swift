//
//  CustomizingViews.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 20/5/24.
//

import Foundation
import SwiftUI

extension View {
    func clearButtonHidden(_ hidesClearButton: Bool = true) -> some View {
        environment(\.clearButtonHidden, hidesClearButton)
    }
}

private struct TextInputFieldClearButtonHidden: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var clearButtonHidden: Bool {
        get { self[TextInputFieldClearButtonHidden.self]}
        set { self[TextInputFieldClearButtonHidden.self] = newValue}
    }
}
