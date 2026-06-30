//
//  View+Extension.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 30.06.2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func optionalGlassEffect(
        cornerRadius: CGFloat = 30,
        interactive: Bool = false
    ) -> some View {
        let backgroundColor = Color(NSColor.windowBackgroundColor)
        
        if #available(macOS 26, *) {
            let glass: Glass = interactive
                ? .regular.tint(backgroundColor.opacity(0.55)).interactive()
                : .regular.tint(backgroundColor.opacity(0.55))
            self.glassEffect(glass, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            }
        }
    }
}
