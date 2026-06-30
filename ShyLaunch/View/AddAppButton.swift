//
//  AddAppButton.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 30.06.2026.
//

import SwiftUI

struct AddAppButton: View {
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Label("Uygulama Ekle", systemImage: "plus.circle.fill")
                .font(.body.bold())
                .foregroundColor(isHovering ? .accentColor : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .optionalGlassEffect(cornerRadius: 20, interactive: true)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    AddAppButton(action: {})
        .padding(100)
}
