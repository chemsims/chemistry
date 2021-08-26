//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct SupportStudentsModal: View {

    let model: TippingViewModel
    let tipOverlayModel: TipOverlayViewModel
    @State private var page = 0

    var body: some View {
        GeometryReader { geo in
            SupportStudentsModalWithSettings(
                model: model,
                tipOverlayModel: tipOverlayModel,
                settings: .init(geometry: geo)
            )
            .frame(size: geo.size)
            .onAppear {
                model.storeManager.loadProducts()
            }
        }
    }
}

private struct SupportStudentsModalWithSettings: View {

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

    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            mainContent

            PageControl(
                pages: 2,
                currentPage: $page,
                pageIndicatorColor: .gray,
                currentPageIndicatorColor: RGB.primaryDarkBlue.uiColor
            )
        }
        .frame(size: settings.modalSize)
        .background(
            RoundedRectangle(cornerRadius: settings.cornerRadius)
                .foregroundColor(.white)
        )
        .compositingGroup()
        .shadow(radius: 2)
    }

    private var mainContent: some View {
        return ZStack(alignment: .top) {
            SupportStudentsModal.HeadingBackgroundRect(
                settings: settings
            )

            PageViewController(
                pages: [
                    screen(0),
                    screen(1)
                ],
                currentPage: $page
            )

            inverseBannerCorners

            // The student images stick out a pixel below the banner rectangle, and
            // moving them up 1 pixel caused them to not line up properly with the base
            // of the banner. So this rectangle is just to cover up the pixel below the banner
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 1)
                .padding(.top, settings.bannerHeight)
        }
    }

    /// We can't add a mask to the banner images inside the paging view, so instead we
    /// add the corners which complete the bottom of the banner on top of the view
    /// to cover the images when they move
    private var inverseBannerCorners: some View {
        Rectangle()
            .foregroundColor(.white)
            .frame(height: settings.bannerHeight / 2)
            .frame(height: settings.bannerHeight, alignment: .bottom)
            .mask(
                RectWithRoundedRect(
                    cornerRadius: settings.cornerRadius
                )
                .fill(style: FillStyle(eoFill: true))
            )
    }

    @ViewBuilder
    private func screen(_ page: Int) -> some View {
        if page == 0 {
            SupportStudentsModal.IntroScreen(settings: settings)
        } else {
            SupportStudentsModal.TipScreen(
                model: model,
                tipOverlayModel: tipOverlayModel,
                settings: settings
            )
        }
    }
}

// A shape with two paths: one for a rounded rect, and normal rect
private struct RectWithRoundedRect: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: rect,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        path.addRect(rect)
        return path
    }
}

extension SupportStudentsModal {
    struct HeadingBackgroundRect: View {
        let settings: SupportStudentsModalSettings

        var body: some View {
            RoundedRectangle(cornerRadius: settings.cornerRadius)
                .frame(height: settings.bannerHeight)
                .foregroundColor(RGB.primaryLightBlue.color)
        }
    }
}

struct SupportStudentsModal_Previews: PreviewProvider {
    static var previews: some View {
        SupportStudentsModal(
            model: .init(storeManager: .preview),
            tipOverlayModel: .init(persistence: UserDefaultsTipOverlayPersistence())
        )
        .padding()
    }
}
