//
// Reactions App
//


import SwiftUI

struct AnalyticsConsentView: View {

    @Binding var isShowing: Bool
    @ObservedObject var model: AnalyticsConsentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Button(action: {
                    isShowing = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.darkGray)
                }
                .accessibility(label: Text("Close analytics consent modal"))
                Spacer()
            }
            Toggle(isOn: model.enabled) {
                Text("Share analytics")
            }
            Text("Help us improve Reactions Rate by providing anonymous usage data.")
                .font(.subheadline)
                .foregroundColor(.darkGray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
                .shadow(radius: 3)
        )
        .frame(idealWidth: 250)
        .accessibility(addTraits: .isModal)
    }
}

class AnalyticsConsentViewModel: ObservableObject {

    private var service: AnalyticsService

    init(service: AnalyticsService) {
        self.service = service
    }

    var enabled: Binding<Bool> {
        Binding(
            get: { self.service.enabled },
            set: { self.service.enabled = $0 }
        )
    }
}

struct AnalyticsConsentView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsConsentView(
            isShowing: .constant(true),
            model: AnalyticsConsentViewModel(service: NoOpAnalytics())
        )
        .padding()
    }
}
