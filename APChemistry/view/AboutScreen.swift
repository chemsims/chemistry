//
// Reactions App
//

import ReactionsCore
import SwiftUI

struct AboutScreen: View {

    let model: TippingViewModel
    let navigation: APChemRootNavigationModel
    @State private var showShareSheet = false

    var body: some View {
        GeometryReader { geo in
            AboutScreenWithSettings(
                model: model,
                storeManager: model.storeManager,
                navigation: navigation,
                settings: SupportStudentsModalSettings(
                    geometry: geo
                ),
                showShareSheet: $showShareSheet
            )
        }
        .onAppear {
            model.storeManager.loadProducts()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(
                activityItems: [
                    UIImage(named: "stem-badge") as Any
                ],
                onCompletion: { showShareSheet = false }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

private struct AboutScreenWithSettings: View {

    @ObservedObject var model: TippingViewModel
    @ObservedObject var storeManager: StoreManager
    let navigation: APChemRootNavigationModel
    let settings: SupportStudentsModalSettings
    @Binding var showShareSheet: Bool


    var body: some View {
        ScrollView {
            VStack(spacing: settings.vSpacing) {
                backButton

                VStack(spacing: 3 * settings.vSpacing) {
                    SupportStudentsModal.IntroScreen(
                        settings: settings,
                        nestInScrollView: false,
                        includeImageBackground: true
                    )

                    AboutScreenWithSettings.TipArea(
                        model: model,
                        storeManager: storeManager,
                        settings: settings,
                        showShareSheet: $showShareSheet
                    )
                    .frame(width: settings.mainContentWidth)
                }
            }
            .padding(8)
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: { navigation.activeSheet = nil }) {
                Text("Back")
            }
            Spacer(minLength: 0)
        }
    }
}

extension AboutScreenWithSettings {

    struct TipArea: View {
        @ObservedObject var model: TippingViewModel
        @ObservedObject var storeManager: StoreManager
        let settings: SupportStudentsModalSettings

        @Binding var showShareSheet: Bool

        var body: some View {
            VStack(spacing: settings.vSpacing) {

                StudentsBanner(
                    studentsToShow: model.studentsToShow,
                    settings: settings
                )
                .background(
                    RoundedRectangle(cornerRadius: settings.cornerRadius)
                        .foregroundColor(.primaryLightBlue)
                )

                Text("Support students")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryDarkBlue)

                Text(Strings.tipMessage)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if model.hasPurchased {
                    hasPurchasedContent
                } else {
                    noPurchaseContent
                }
            }
            .lineLimit(nil)
        }

        private var hasPurchasedContent: some View {
            Group {
                Text(Strings.thankForSupport)
                stemBadge
                ExtraTipArea(storeManager: storeManager, settings: settings)
            }
        }

        private var noPurchaseContent: some View {
            Group {
                TipSlider(
                    formatPrice: { level in
                        storeManager.price(forProduct: level.product)
                    },
                    selectedTipLevel: $model.selectedTipLevel,
                    settings: settings
                )

                tipButton
                restoreButton
            }
        }

        private var stemBadge: some View {
            Group {
                Text(Strings.showStemBadge)

                Image("stem-badge")
                    .overlay(shareStemBadge, alignment: .topTrailing)
            }
        }

        private var shareStemBadge: some View {
            Button(action: { showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
            }
        }

        private var tipButton: some View {
            SupportStudentsModal.CapsuleButton(
                label: "Support",
                settings: settings,
                action: model.makeTipPurchase
            )
            .foregroundColor(.primaryDarkBlue)
            .frame(size: settings.supportButtonSize)
            .disabled(!model.tipButtonEnabled)
            .overlay(tipButtonOverlay)
        }

        @ViewBuilder
        private var tipButtonOverlay: some View {
            if model.isPurchasing {
                ActivityIndicator()
            }
        }

        private var restoreButton: some View {
            Button(action: storeManager.restorePurchases) {
                Text(storeManager.isRestoring ? "Restoring" : "Restore purchases")
            }
            .disabled(storeManager.isRestoring)
        }
    }

    private struct ExtraTipArea: View {

        @ObservedObject var storeManager: StoreManager
        let settings: SupportStudentsModalSettings

        var body: some View {
            VStack(spacing: settings.vSpacing) {
                Text(Strings.furtherTip)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                tipButtons
            }
        }

        private var tipButtons: some View {
            ForEach(ExtraTipLevel.allCases) { level in
                tipButton(forLevel: level)
            }
        }

        private func tipButton(forLevel level: ExtraTipLevel) -> some View {
            let price = storeManager.price(forProduct: level.product)
            let state = storeManager.productState(for: level.product)
            let failedToLoadProduct = (state?.state).exists { $0 == .failedToLoadProduct }

            let priceString = price ?? (failedToLoadProduct ? "Cannot connect to store" : "")

            let showLoading = state.map(showLoadingIndicator) ?? false

            return SupportStudentsModal.CapsuleButton(
                label: priceString,
                settings: settings,
                action: { storeManager.beginPurchase(of: level.product) }
            )
            .frame(size: settings.extraTipSize)
            .foregroundColor(.primaryDarkBlue)
            .disabled(showLoading)
            .overlay(loadingOverlay(loading: showLoading))
            .multilineTextAlignment(.center)
        }

        private func showLoadingIndicator(state: InAppPurchaseWithState) -> Bool {
            switch state.state {
            case .readyForPurchase, .failedToLoadProduct: return false
            default: return true
            }
        }

        @ViewBuilder
        private func loadingOverlay(loading: Bool) -> some View {
            if loading {
                ActivityIndicator()
//                    .background(Color.white.opacity(0.5))
            }
        }
    }
}
