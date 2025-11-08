import SwiftUI

struct SetupIcon: View {
    var body: some View {
        VStack {
            Image("SetupIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
            Text("Initial setup")
        }
    }
}

#Preview {
    ContentView()
}
