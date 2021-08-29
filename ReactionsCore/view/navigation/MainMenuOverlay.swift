//
// Reactions App
//

import SwiftUI

struct MainMenuOverlay<Injector: NavigationInjector>: View {

    let rows: NavigationRows<Injector.Screen>
    @ObservedObject var navigation: RootNavigationViewModel<Injector>
    let feedbackSettings: FeedbackSettings
    let shareSettings: ShareSettings
    let size: CGFloat
    let topPadding: CGFloat
    let menuHPadding: CGFloat

    @Binding var unitSelectionIsShowing: Bool
    @Binding var aboutPageIsShowing: Bool

    @State private var showFailedMailAlert = false
    @State private var activeSheet: ActiveSheet?

    public var body: some View {
        GeometryReader { geo in
            MainMenuOverlayWithSettings(
                rows: rows,
                navigation: navigation,
                feedbackSettings: feedbackSettings,
                activeSheet: $activeSheet,
                showFailedMailAlert: $showFailedMailAlert,
                unitSelectionIsShowing: $unitSelectionIsShowing,
                aboutPageIsShowing: $aboutPageIsShowing,
                settings: MainMenuLayoutSettings(
                    geometry: geo,
                    menuSize: size,
                    topPadding: topPadding,
                    hPadding: menuHPadding
                )
            )
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .mail:
                MailComposerView(
                    settings: feedbackSettings,
                    onDismiss: { activeSheet = nil }
                )
                    .edgesIgnoringSafeArea(.all)
            case .share:
                ShareSheetView(
                    activityItems: [shareSettings.message],
                    onCompletion: { activeSheet = nil }
                )
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .alert(isPresented: $showFailedMailAlert) {
            Alert(
                title: Text("Send Feedback"),
                message: Text("Could not open Mail composer. Please send feedback to \(feedbackSettings.toAddress)."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

private struct MainMenuOverlayWithSettings<Injector: NavigationInjector>: View {

    let rows: NavigationRows<Injector.Screen>
    @ObservedObject var navigation: RootNavigationViewModel<Injector>
    let feedbackSettings: FeedbackSettings
    @Binding var activeSheet: ActiveSheet?
    @Binding var showFailedMailAlert: Bool
    @Binding var unitSelectionIsShowing: Bool
    @Binding var aboutPageIsShowing: Bool
    let settings: MainMenuLayoutSettings


    @State private var panelDragOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {

            if navigation.showAnalyticsConsent {
                Rectangle()
                    .opacity(0.2)
                    .onTapGesture {
                        navigation.showAnalyticsConsent = false
                    }
            }

            icon
                .padding(.leading, settings.geometry.safeAreaInsets.leading)
                .padding(.vertical, settings.geometry.safeAreaInsets.top)
                .accessibility(sortPriority: 0.7)

            if navigation.showMenu {
                panel
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { gesture in
                                panelDragOffset = min(0, gesture.translation.width)
                            }.onEnded { _ in
                                toggleMenu()
                                panelDragOffset = 0
                            }
                    )
                    .offset(x: panelDragOffset)
                    .padding(.top, settings.totalTopPadding)
                    .padding(.bottom, settings.totalBottomPadding)
                    .transition(AnyTransition.move(edge: .leading))
                    .zIndex(1)
                    .accessibilityElement(children: .contain)
                    .accessibility(sortPriority: 0.5)
                    .accessibility(addTraits: .isModal)
            }

            if navigation.showAnalyticsConsent {
                consentView
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25))
        .accessibilityElement(children: .contain)
    }

    private var consentView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                AnalyticsConsentView(
                    isShowing: $navigation.showAnalyticsConsent,
                    model: navigation.analyticsConsent
                )
                    .frame(width: 0.45 * settings.geometry.size.width)
                Spacer()
            }
            Spacer()
        }
    }

    private var icon: some View {
        let action = navigation.showMenu ? "close" : "open"
        return HStack(spacing: 0) {
            VStack(spacing: 0) {
                MenuButton(action: toggleMenu)
                    .frame(width: settings.menuSize, height: settings.menuSize)
                    .padding(.top, settings.topPadding)
                    .padding(.horizontal, settings.hPadding)
                    .accessibility(label: Text("\(action) menu"))
                Spacer()
            }
            Spacer()
        }
    }

    private var panel: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()
                .frame(width: settings.leadingPanelSpace)
            settingsButtons
                .accessibility(sortPriority: 2)
            panelContent
                .accessibility(sortPriority: 3)
            grabHandle
                .accessibility(sortPriority: 1)
        }
        .background(panelBackground)
        .compositingGroup()
        .shadow(radius: navigation.showMenu ? 3 : 0)
    }

    private func toggleMenu() {
        navigation.showMenu.toggle()
    }
}

// MARK: Shapes
extension MainMenuOverlayWithSettings {
    private var grabHandle: some View {
        VStack(spacing: 3) {
            grabLine
            grabLine
            grabLine
        }
        .frame(width: settings.menuSize, height: settings.menuSize)
        .padding(settings.hPadding)
        .foregroundColor(.black)
        .accessibility(label: Text("Close menu"))
        .accessibilityAction {
            navigation.showMenu = false
        }
        .accessibility(sortPriority: 1)
    }

    private var grabLine: some View {
        Rectangle()
            .frame(
                width: settings.grabLineWidth,
                height: settings.grabLineHeight
            )
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
            tabWidth: settings.tabSize,
            tabHeight: settings.tabSize,
            cornerRadius: 0.5 * settings.tabSize
        )
    }
}

// MARK: Main navigation icons
extension MainMenuOverlayWithSettings {
    private var panelContent: some View {
        VStack(alignment: .leading, spacing: settings.navVStackSpacing) {
            ForEach(0..<rows.primary.count) { i in
                navRow(rows.primary[i])
            }
            if !rows.secondary.isEmpty {
                Divider()
                    .frame(width: settings.dividerWidth(rows: rows))
            }
            ForEach(0..<rows.secondary.count) { i in
                navRow(rows.secondary[i])
            }
        }
        .padding(settings.panelContentPadding)
    }

    private func navRow(_ row: NavigationRow<Injector.Screen>) -> some View {
        HStack(alignment: .bottom, spacing: settings.navRowHSpacing) {
            navIcon(icon: row.primaryIcon)
                .frame(
                    width: settings.navIconWidth,
                    height: settings.navIconHeight
                )

            if row.firstSecondaryIcon != nil {
                navIcon(icon: row.firstSecondaryIcon!)
                    .frame(
                        width: settings.secondaryIconWidth,
                        height: settings.secondaryIconHeight
                    )
            }

            if row.secondSecondaryIcon != nil {
                navIcon(icon: row.secondSecondaryIcon!)
                    .frame(
                        width: settings.secondaryIconWidth,
                        height: settings.secondaryIconHeight
                    )
            }
        }
    }

    private func navIcon(
        icon: NavigationIcon<Injector.Screen>
    ) -> some View {
        let isSelected = navigation.currentScreen == icon.screen
        let canSelect = navigation.canSelect(screen: icon.screen)

        let shouldFocus = navigation.highlightedIcon == icon.screen
        let mainColor = shouldFocus ? Color.orangeAccent : Styling.navIcon
        let color = canSelect ? mainColor : Styling.inactiveScreenElement

        return Button(action: { goTo(screen: icon.screen) }) {
            Image(isSelected ? icon.selectedImage : icon.image)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .font(.system(size: 10, weight: isSelected ? .light : .ultraLight))
                .foregroundColor(color)
        }
        .disabled(!canSelect)
        .accessibility(label: Text(icon.label))
        .accessibility(addTraits: isSelected ? .isSelected : [])
    }

    private func goTo(screen: Injector.Screen) {
        navigation.jumpTo(screen: screen)
        toggleMenu()
    }
}

// MARK: Left hand side setting buttons
extension MainMenuOverlayWithSettings {
    private var settingsButtons: some View {
        VStack(spacing: settings.navVStackSpacing) {
            unitSelectionButton
            mailButton
            shareButton
            aboutButton
             if Flags.showAnalyticsOptOutToggle {
                analyticsButton
            }
        }
        .frame(width: settings.settingButtonsWidth)
        .padding(.top, 2 * settings.panelContentPadding)
        .padding(.leading, settings.panelContentPadding)
        .padding(.trailing, 2 * settings.panelContentPadding)
    }

    private var mailButton: some View {
        Button(action: openMailComposer) {
            Image(systemName: "envelope.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Styling.navIcon)
                .font(.system(size: 10, weight: .ultraLight))
        }
        .accessibility(label: Text("Open mail composer"))
        .accessibility(hint: Text("Opens mail composer to send app feedback"))
    }

    private var shareButton: some View {
        Button(action: {
            navigation.didShowShareSheetFromMenu()
            activeSheet = .share
        }) {
            Image("share-icon", bundle: .reactionsCore)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .accessibility(label: Text("Open share sheet"))
        .accessibility(hint: Text("Opens share sheet to share app with others"))
    }

    private var unitSelectionButton: some View {
        Button(action: {
            unitSelectionIsShowing = true
            navigation.showMenu = false
        }) {
            // note this symbol not available in iOS 13, so have to import manually
            Image("circles.hexagongrid", bundle: .reactionsCore)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Styling.navIcon)
        }
        .accessibility(label: Text("Open unit selection page"))
    }

    private var aboutButton: some View {
        Button(action: {
            aboutPageIsShowing = true
            navigation.showMenu = false
        }) {
            Image(systemName: "info.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Styling.navIcon)
        }
        .accessibility(label: Text("Open about page"))
    }

    private var analyticsButton: some View {
        Button(action: {
            navigation.showAnalyticsConsent.toggle()
        }) {
            Image(systemName: "chart.bar.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Styling.navIcon)
        }
        .accessibility(label: Text("Open analytics consent settings"))
    }

    private func openMailComposer() {
        if MailComposerView.canSendMail() {
            activeSheet = .mail
            return
        }

        if let url = feedbackSettings.mailToUrl {
            openMailToLink(url)
        } else {
            showFailedMailAlert = true
        }
    }

    private func openMailToLink(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showFailedMailAlert = true
        }
    }
}

private struct MainMenuLayoutSettings {

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

    var navVStackSpacing: CGFloat {
        0.05 * height
    }

    var navIconHeight: CGFloat {
        let availableHeight = panelContentHeight - (4 * navVStackSpacing)
        return availableHeight / 5
    }

    var navIconWidth: CGFloat {
        0.85 * navIconHeight
    }

    var totalTopPadding: CGFloat {
        topPadding + geometry.safeAreaInsets.top
    }

    var settingButtonsWidth: CGFloat {
        navIconHeight * 0.45
    }

    var totalBottomPadding: CGFloat {
        geometry.safeAreaInsets.bottom
    }

    private var panelHeight: CGFloat {
        let maxAvailableHeight = height - totalTopPadding - totalBottomPadding
        let maxHeight: CGFloat = 550
        return min(maxAvailableHeight, maxHeight)
    }

    var panelContentHeight: CGFloat {
        panelHeight - (2 * panelContentPadding)
    }

    var secondaryIconHeight: CGFloat {
        0.5 * navIconHeight
    }

    var secondaryIconWidth: CGFloat {
        1.2 * secondaryIconHeight
    }

    var panelContentPadding: CGFloat {
        0.35 * menuSize
    }

    var tabSize: CGFloat {
        menuSize + (2 * hPadding)
    }

    var navRowHSpacing: CGFloat {
        10
    }

    var leadingPanelSpace: CGFloat {
        let leading = geometry.safeAreaInsets.leading
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            return leading
        }
        return leading / 2
    }

    var panelBorder: CGFloat {
        0.75
    }

    func dividerWidth<T>(rows: NavigationRows<T>) -> CGFloat {
        let secondaryCount = CGFloat(rows.maxSecondaryIconCount)
        let secondary = secondaryIconWidth * secondaryCount
        let spacing = navRowHSpacing * secondaryCount
        return navIconWidth + secondary + spacing
    }
}

private enum ActiveSheet: Int, Identifiable {
    case mail, share

    var id: Int {
        rawValue
    }
}


struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay(
            rows: NavigationRows(rows, secondary: secondary),
            navigation: model,
            feedbackSettings: FeedbackSettings(),
            shareSettings: ShareSettings(),
            size: 20,
            topPadding: 10,
            menuHPadding: 10,
            unitSelectionIsShowing: .constant(false),
            aboutPageIsShowing: .constant(false)
        )
        .previewLayout(.iPhoneSELandscape)
    }

    static let rows: [NavigationRow<Int>] = [
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: 1,
                image: .system("folder.circle"),
                selectedImage: .system("folder.circle.fill"),
                label: ""
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: 2,
                image: .system("externaldrive"),
                selectedImage: .system("externaldrive.fill"),
                label: ""
            ),
            secondSecondaryIcon: nil
        ),
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: 3,
                image: .system("folder.circle"),
                selectedImage: .system("folder.circle.fill"),
                label: ""
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: 2,
                image: .system("externaldrive"),
                selectedImage: .system("externaldrive.fill"),
                label: ""
            ),
            secondSecondaryIcon: NavigationIcon(
                screen: 2,
                image: .system("externaldrive"),
                selectedImage: .system("externaldrive.fill"),
                label: ""
            )
        )
    ]

    static let secondary: [NavigationRow<Int>] = [
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: 4,
                image: .system("heart.circle"),
                selectedImage: .system("heart.circle"),
                label: ""
            ),
            firstSecondaryIcon: nil,
            secondSecondaryIcon: nil
        )
    ]

    static let model = RootNavigationViewModel(injector: injector, generalAnalytics: NoOpGeneralAnalytics())

    static let injector = AnyNavigationInjector(
        behaviour: AnyNavigationBehavior(EmptyBehaviour()),
        persistence: AnyScreenPersistence(InMemoryScreenPersistence()),
        analytics: AnyAppAnalytics(NoOpAppAnalytics<Int, Int>()),
        quizPersistence: AnyQuizPersistence(InMemoryQuizPersistence<Int>()),
        reviewPersistence: InMemoryReviewPromptPersistence(),
        namePersistence: InMemoryNamePersistence(),
        sharePrompter: SharePrompter(
            persistence: InMemorySharePromptPersistence(),
            appLaunches: InMemoryAppLaunchPersistence(),
            analytics: NoOpGeneralAnalytics()
        ),
        appLaunchPersistence: UserDefaultsAppLaunchPersistence(),
        allScreens: [1, 2, 3, 4],
        linearScreens: [1, 2, 3, 4]
    )

    struct EmptyBehaviour<Screen>: NavigationBehaviour {
        func deferCanSelect(of screen: Screen) -> DeferCanSelect<Screen>? {
            nil
        }

        func shouldRestoreStateWhenJumpingTo(screen: Screen) -> Bool {
            false
        }

        func showReviewPromptOn(screen: Screen) -> Bool {
            false
        }

        func showMenuOn(screen: Screen) -> Bool {
            false
        }

        func highlightedNavIcon(for screen: Screen) -> Screen? {
            nil
        }

        func getProvider(for screen: Screen, nextScreen: @escaping () -> Void, prevScreen: @escaping () -> Void) -> ScreenProvider {
            EmptyProvider()
        }
    }

    struct EmptyProvider: ScreenProvider {
        let screen: AnyView = AnyView(EmptyView())
    }
}
