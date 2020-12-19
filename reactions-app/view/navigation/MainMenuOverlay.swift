//
// Reactions App
//
  

import SwiftUI

struct MainMenuOverlay: View {

    let size: CGFloat
    let topPadding: CGFloat
    let menuHPadding: CGFloat
    let navigation: RootNavigationViewModel

    var body: some View {
        GeometryReader { geo in
            MainMenuOverlayWithSettings(
                navigation: navigation,
                settings: MainMenuLayoutSettings(
                    geometry: geo,
                    menuSize: size,
                    topPadding: topPadding,
                    hPadding: menuHPadding
                )
            )
        }
    }
}

fileprivate struct MainMenuOverlayWithSettings: View {

    let navigation: RootNavigationViewModel
    let settings: MainMenuLayoutSettings

    @State private var showPanel: Bool = false
    @State private var extraOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
            icon
            panel
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { gesture in
                            extraOffset = min(0, gesture.translation.width)
                        }.onEnded { _ in
                            toggleMenu()
                            extraOffset = 0
                        }
                )
                .offset(
                    x: showPanel ? 0 + extraOffset : -settings.totalMenuWidth - (settings.panelBorder / 2),
                    y: settings.geometry.safeAreaInsets.top + settings.topPadding
                )
                .edgesIgnoringSafeArea(.all)
        }
    }

    private var icon: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                MenuButton(action: toggleMenu)
                    .frame(width: settings.menuSize, height: settings.menuSize)
                    .padding(.top, settings.topPadding)
                    .padding(.horizontal, settings.hPadding)
                Spacer()
            }
            Spacer()
        }
    }

    private var panel: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
                .frame(width: settings.leadingPanelSpace)
            panelContent
            grabHandle
        }
        .background(panelBackground)
        .compositingGroup()
        .shadow(radius: showPanel ? 3 : 0)
    }

    private var grabHandle: some View {
        VStack(spacing: 3) {
            grabLine
            grabLine
            grabLine
        }
        .frame(width: settings.menuSize, height: settings.menuSize)
        .padding(settings.hPadding)
        .foregroundColor(.black)
    }

    private var grabLine: some View {
        Rectangle()
            .frame(
                width: settings.grabLineWidth,
                height: settings.grabLineHeight
            )
    }

    private var panelContent: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: settings.tabHeight / 2)
            beakerWithFilingCabinet(order: .Zero)
            beakerWithFilingCabinet(order: .First)
            beakerWithFilingCabinet(order: .Second)
            navIcon(image: "comparisonicon", screen: .reactionComparison)
                .frame(width: settings.beakerImageWidth)
            navIcon(image: "kineticsicon", screen: .energyProfile)
                .frame(width: settings.beakerImageWidth)
        }
        .frame(width: settings.panelWidth, height: settings.panelHeight)
        .padding(.trailing, settings.panelTrailingPadding)
    }

    private func beakerWithFilingCabinet(order: ReactionOrder) -> some View {
        HStack(spacing: 0) {
            navIcon(image: order.navImage, screen: order.screen)
                .frame(width: settings.beakerImageWidth)
            Spacer()
            Button(action: goToScreen { navigation.goToFilingCabinet(order: order) }) {
                filingCabinet
                    .frame(width: settings.filingCabinetWidth)
            }
        }
    }

    private var filingCabinet: some View {
        Image(systemName: "archivebox")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Styling.navIcon)
            .font(.system(size: 10, weight: .ultraLight))
    }

    private var panelBackground: some View {
        ZStack {
            panelShape
                .fill()
                .foregroundColor(Styling.menuPanel)

            panelShape
                .stroke(lineWidth: settings.panelBorder)
        }
    }

    private var panelShape: some Shape {
        MainMenuPanel(
            panelWidthFraction: settings.panelWidthFraction,
            panelHeightFraction: settings.panelHeightFraction,
            cornerRadius: 0.5 * settings.menuSize
        )
    }

    private func navIcon(image: String, screen: AppScreen) -> some View {
        Button(action: goToScreen(action: { navigation.goToFresh(screen: screen) })) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func goToScreen(action: @escaping () -> Void) -> () -> Void {
        {
            action()
            toggleMenu()
        }
    }

    private func toggleMenu() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
            showPanel.toggle()
        }
    }
}

fileprivate extension ReactionOrder {
    var navImage: String {
        switch (self) {
        case .Zero: return "zeroordericon"
        case .First: return "firstordericon"
        case .Second: return "secondordericon"
        }
    }

    var screen: AppScreen {
        switch (self) {
        case .Zero: return .zeroOrderReaction
        case .First: return .firstOrderReaction
        case .Second: return .secondOrderReaction
        }
    }
}

fileprivate struct MainMenuLayoutSettings {
    let geometry: GeometryProxy
    let menuSize: CGFloat
    let topPadding: CGFloat
    let hPadding: CGFloat

    var height: CGFloat {
        geometry.size.height
    }

    var grabLineWidth: CGFloat {
        0.6 * menuSize
    }

    var grabLineHeight: CGFloat {
        max(0.015 * menuSize, 1)
    }

    var panelWidth: CGFloat {
        3.5 * menuSize
    }

    var panelTrailingPadding: CGFloat {
        0.1 * panelWidth
    }

    var beakerImageWidth: CGFloat {
        0.5 * panelWidth
    }

    var filingCabinetWidth: CGFloat {
        0.3 * panelWidth
    }

    var tabHeight: CGFloat {
        1.1 * (menuSize + (2 * topPadding))
    }

    var tabWidth: CGFloat {
        menuSize
    }

    var totalMenuWidth: CGFloat {
        panelWidth + panelTrailingPadding + tabWidth + (2 * hPadding) + leadingPanelSpace
    }

    var panelWidthFraction: CGFloat {
        (panelWidth + leadingPanelSpace + panelTrailingPadding) / totalMenuWidth
    }

    var panelHeightFraction: CGFloat {
        1 - (tabHeight / panelHeight)
    }

    var leadingPanelSpace: CGFloat {
        let leading = geometry.safeAreaInsets.leading
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft) {
            return leading
        }
        return leading / 2
    }

    var panelBorder: CGFloat {
        0.75
    }

    var panelHeight: CGFloat {
        min(height, 7 * panelWidth)
    }
}

struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay(
            size: 50,
            topPadding: 10,
            menuHPadding: 10,
            navigation: RootNavigationViewModel(
                persistence: InMemoryReactionInputPersistence()
            )
        ).previewLayout(.fixed(width: 926, height: 428))
    }
}
