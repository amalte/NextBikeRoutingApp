import SwiftUI

struct AppDescriptionView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("NextBikeRouter")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Share a Google Maps destination to this app to get NextBike routing.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
