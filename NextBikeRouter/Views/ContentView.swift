import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 10) {
                    HStack {
                        SetupIcon()
                        Spacer()
                        HelpIcon()
                    }.padding()
                    Spacer()
                    AppLogoView()
                    Spacer()
                }
                FlagView()
                    .padding(.trailing, 40)
            }
        }
    }
}

#Preview {
    ContentView()
}
