//
// Reactions App
//

import ReactionsCore
import SwiftUI

extension SupportStudentsModal {
    struct TipScreen: View {

        init(
            model: TippingViewModel,
            tipOverlayModel: TipOverlayViewModel,
            settings: SupportStudentsModalSettings
        ) {
            self.model = model
            self.storeManager = model.storeManager
            self.tipOverlayModel = tipOverlayModel
            self.settings = settings
        }

        @ObservedObject var model: TippingViewModel
        @ObservedObject var storeManager: StoreManager
        @ObservedObject var tipOverlayModel: TipOverlayViewModel
        let settings: SupportStudentsModalSettings

        @State private var showShareSheet = false

        var body: some View {
            VStack(spacing: 0) {
                StudentsBanner(
                    studentsToShow: model.studentsToShow,
                    settings: settings
                )

                ScrollView {
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        mainContent
                            .frame(width: settings.mainContentWidth)
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, settings.mainContentScrollViewHPadding)
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

        private var mainContent: some View {
            VStack(spacing: settings.vSpacing) {
                Text("Support Students!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryDarkBlue)
                    .accessibility(addTraits: .isHeader)

                Text(Strings.tipMessage)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.75)

                TipSlider(
                    formatPrice: { level in
                        if let price = storeManager.price(forProduct: level.product) {
                            return price
                        } else if model.hasPurchased {
                            // this case is unlikely, but worth handling otherwise the price
                            // will appear to be loading
                            return ""
                        }
                        return nil
                    },
                    selectedTipLevel: $model.selectedTipLevel,
                    settings: settings
                )

                if model.isPurchasing || model.hasPurchased {
                    closeModalPostTip
                } else {
                    HStack {
                        tipButton

                        skipButton
                    }
                    restoreButton
                }
                Spacer()
            }
        }

        private var closeModalPostTip: some View {
            Group {
                Text("Thank you for your support!")

                if model.isPurchasing {
                    Text("We are unlocking your special STEM badge now...")
                }
                if model.hasPurchased {
                    stemBadge
                }

                continueButton
            }
        }

        private var continueButton: some View {
            CapsuleButton(
                label: "Continue",
                settings: settings,
                action: tipOverlayModel.continuePostTip
            )
            .foregroundColor(.primaryDarkBlue)
            .frame(size: settings.supportButtonSize)
        }

        private var stemBadge: some View {
            Group {
                Text("Check out your STEM badge below!")

                Image("stem-badge")
                    .accessibility(label: Text(Strings.stemBadgeLabel))
                    .overlay(shareStemBadge, alignment: .topTrailing)
            }
        }

        private var shareStemBadge: some View {
            Button(action: { showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
            }
        }

        private var restoreButton: some View {
            Button(action: storeManager.restorePurchases) {
                Text(storeManager.isRestoring ? "Restoring" : "Restore purchases")
            }
            .disabled(storeManager.isRestoring)
        }

        private var tipButton: some View {
            SupportStudentsModal.CapsuleButton(
                label: "Support",
                settings: settings,
                action: {
                    model.makeTipPurchaseFromPrompt(
                        promptCount: tipOverlayModel.getCountOfCurrentlyShowingTipPrompt()
                    )
                }
            )
            .foregroundColor(.primaryDarkBlue)
            .frame(size: settings.supportButtonSize)
            .disabled(!model.tipButtonEnabled)
        }

        private var skipButton: some View {
            SupportStudentsModal.CapsuleButton(
                label: "Skip",
                settings: settings,
                action: tipOverlayModel.dismissWithoutTip
            )
            .foregroundColor(.gray)
            .frame(size: settings.skipButtonSize)
        }
    }
}

extension SupportStudentsModal {
    struct CapsuleButton: View {

        let label: String
        let settings: SupportStudentsModalSettings
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)

                    Text(label)
                        .font(
                            .system(
                                size: settings.tippingButtonsFontSize,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct TipScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SupportStudentsModal.TipScreen(
                model: .init(storeManager: .preview, analytics: NoOpGeneralAnalytics()),
                tipOverlayModel: .init(
                    persistence: UserDefaultsTipOverlayPersistence(),
                    locker: InMemoryProductLocker(),
                    analytics: NoOpGeneralAnalytics()
                ),
                settings: .init(geometry: geo)
            )
        }
        .padding(.horizontal, 12)
    }
}
