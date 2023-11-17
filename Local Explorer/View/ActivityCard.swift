//
//  ActivityCard.swift
//  Local Explorer
//
//  Created by Canyon Zhang on 11/28/23.
//

import SwiftUI

struct Activity{
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
}

struct ActivityCard: View {
    @State var activity: Activity
     
    // UI design for each of the activity cards rendered on the activity view. 
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
            .cornerRadius(15)
            
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.title)
                        .font(.system(size: 16))
                        
                        Text(activity.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                Image(systemName: activity.image)
                .foregroundColor(.green)
                
                Text(activity.amount)
                .font(.system(size: 24))
            }
            .padding()
        }
    }
}


struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(id: 0, title: "Daily steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: "9,987"))
    }
}
