//
//  ActivityView.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/26/23.
//

import SwiftUI

struct ActivityView: View {
    // Organizes the activites cards in a nicely formatted VGrid
    @EnvironmentObject var healthManager: HealthManager
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                    // Render the activity cards, grabbing from healthManager.activites
                    ForEach(healthManager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                            ActivityCard(activity: item.value)
                        }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}


#Preview {
    ActivityView()
        .environmentObject(HealthManager())
}
