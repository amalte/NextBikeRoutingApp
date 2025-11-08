import SwiftUI

struct HowToUseButton: View {
    var onTap: () -> Void

    var body: some View {
        Button("How to use", action: onTap)
            .font(.subheadline)
    }
}
