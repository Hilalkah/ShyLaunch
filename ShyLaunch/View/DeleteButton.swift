//
//  DeleteButton.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 30.06.2026.
//

import SwiftUI

struct DeleteButton: View {
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .foregroundColor(isHovering ? .red : .secondary)
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .optionalGlassEffect(cornerRadius: 16, interactive: true)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    DeleteButton(action: {})
        .padding(100)
}
