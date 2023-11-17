//
//  SettingsToggleRowView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/26/23.
//

import SwiftUI

struct SettingsToggleRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    @Binding var isToggleOn: Bool
    
    // Custom settings row view to include the toggle option for sharing/unsharing location

    var body: some View {
        Toggle(isOn: $isToggleOn) {
            HStack(spacing: 12) {
                Image(systemName: imageName)
                    .imageScale(.small)
                    .font(.title)
                    .foregroundColor(tintColor)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
    }
}


struct SettingsToggleRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with the toggle in 'ON' state
        SettingsToggleRowView(imageName: "location", title: "Share Location", tintColor: Color.blue, isToggleOn: .constant(true))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

