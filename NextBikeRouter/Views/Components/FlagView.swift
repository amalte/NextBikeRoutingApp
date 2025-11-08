import SwiftUI

struct FlagView: View {
    var body: some View {
        Image("sweFlag")
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
    }
}
