//
// Reactions App
//


import SwiftUI

public struct MainMenuOverlay2<Injector: NavigationInjector>: View {

    let rows: [NavigationRow<Injector.Screen>]
    let size: CGFloat
    let topPadding: CGFloat
    let menuHPadding: CGFloat
    @ObservedObject var navigation: RootNavigationViewModel<Injector>

    public init(
        rows: [NavigationRow<Injector.Screen>],
        navigation: RootNavigationViewModel<Injector>,
        size: CGFloat,
        topPadding: CGFloat,
        menuHPadding: CGFloat
    ) {
        self.rows = rows
        self.navigation = navigation
        self.size = size
        self.topPadding = topPadding
        self.menuHPadding = menuHPadding
    }

    @State private var showFailedMailAlert = false
    @State private var activeSheet: ActiveSheet?

    public var body: some View {
        GeometryReader { geo in
            MainMenuOverlayWithSettings(
                rows: rows,
                navigation: navigation,
                activeSheet: $activeSheet,
                showFailedMailAlert: $showFailedMailAlert,
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

private struct MainMenuOverlayWithSettings<Injector: NavigationInjector>: View {

    let rows: [NavigationRow<Injector.Screen>]
    @ObservedObject var navigation: RootNavigationViewModel<Injector>
    @Binding var activeSheet: ActiveSheet?
    @Binding var showFailedMailAlert: Bool
    let settings: MainMenuLayoutSettings

    @State private var panelDragOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
            icon

            if navigation.showMenu || true {
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
                    .accessibility(sortPriority: 10)
                    .accessibility(addTraits: .isModal)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25))
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
                .accessibility(sortPriority: -1)
            panelContent
            grabHandle
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
            ForEach(0..<rows.count) { i in
                navRow(rows[i])
            }
        }
        .padding(settings.panelContentPadding)
    }

    private func navRow(_ row: NavigationRow<Injector.Screen>) -> some View {
        HStack(alignment: .bottom, spacing: settings.navRowHSpacing) {
            navIcon(icon: row.primaryIcon)
                .frame(height: settings.navIconHeight)

            if row.firstSecondaryIcon != nil {
                navIcon(icon: row.firstSecondaryIcon!)
                    .frame(height: settings.secondaryIconHeight)
            }

            if row.secondSecondaryIcon != nil {
                navIcon(icon: row.secondSecondaryIcon!)
                    .frame(height: settings.secondaryIconHeight)
            }
        }
    }

    private func navIcon(icon: NavigationIcon<Injector.Screen>) -> some View {
        navIcon(
            image: icon.image,
            selectedImage: icon.pressedImage,
            isSystem: icon.isSystemImage,
            screen: icon.screen,
            label: icon.label
        )
    }

    private func navIcon(
        image: String,
        selectedImage: String,
        isSystem: Bool,
        screen: Injector.Screen,
        label: String
    ) -> some View {
        let isSelected = navigation.currentScreen == screen
        let canSelect = navigation.canSelect(screen: screen)

        let shouldFocus = navigation.highlightedIcon == screen
        let mainColor = shouldFocus ? Color.orangeAccent : Styling.navIcon
        let color = canSelect ? mainColor : Styling.inactiveScreenElement

        return Button(action: { goTo(screen: screen) }) {
            makeImage(
                name: isSelected ? selectedImage : image,
                isSystem: isSystem
            )
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .font(.system(size: 10, weight: isSelected ? .light : .ultraLight))
            .foregroundColor(color)
        }
        .disabled(!canSelect)
        .accessibility(label: Text(label))
        .accessibility(addTraits: isSelected ? .isSelected : [])
    }

    private func makeImage(name: String, isSystem: Bool) -> Image {
        if isSystem {
            return Image(systemName: name)
        }
        return Image(name)
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
            mailButton
            shareButton
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
    }

    private var shareButton: some View {
        Button(action: { activeSheet = .share }) {
            Image("share-icon", bundle: .reactionsCore)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .colorMultiply(Styling.navIcon)
        }
        .accessibility(label: Text("Open share sheet"))
    }

    // TODO
    private func openMailComposer() {
        let canSendMail = true // MailComposerView.canSendMail()
        if canSendMail {
            activeSheet = .mail
            return
        }

        if let url = URL(string: "foo") { //} FeedbackSettings.mailToUrl {
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


public struct NavigationRow<Screen> {
    let primaryIcon: NavigationIcon<Screen>
    let firstSecondaryIcon: NavigationIcon<Screen>?
    let secondSecondaryIcon: NavigationIcon<Screen>?

    public init(
        primaryIcon: NavigationIcon<Screen>,
        firstSecondaryIcon: NavigationIcon<Screen>?,
        secondSecondaryIcon: NavigationIcon<Screen>?
    ) {
        self.primaryIcon = primaryIcon
        self.firstSecondaryIcon = firstSecondaryIcon
        self.secondSecondaryIcon = secondSecondaryIcon
    }
}

public struct NavigationIcon<Screen> {
    let screen: Screen
    let image: String
    let pressedImage: String
    let isSystemImage: Bool
    let label: String

    public init(
        screen: Screen,
        image: String,
        pressedImage: String,
        isSystemImage: Bool,
        label: String
    ) {
        self.screen = screen
        self.image = image
        self.pressedImage = pressedImage
        self.isSystemImage = isSystemImage
        self.label = label
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
}

private enum ActiveSheet: Int, Identifiable {
    case mail, share

    var id: Int {
        rawValue
    }
}


struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay2(
            rows: rows,
            navigation: model,
            size: 20,
            topPadding: 10,
            menuHPadding: 10
        )
        .previewLayout(.iPhoneSELandscape)
    }

    static let rows: [NavigationRow<Int>] = [
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: 1,
                image: "folder.circle",
                pressedImage: "folder.circle.fill",
                isSystemImage: true,
                label: ""
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: 2,
                image: "externaldrive",
                pressedImage: "externaldrive.fill",
                isSystemImage: true,
                label: ""
            ),
            secondSecondaryIcon: nil
        ),
        NavigationRow(
            primaryIcon: NavigationIcon(
                screen: 3,
                image: "folder.circle",
                pressedImage: "folder.circle.fill",
                isSystemImage: true,
                label: ""
            ),
            firstSecondaryIcon: NavigationIcon(
                screen: 2,
                image: "externaldrive",
                pressedImage: "externaldrive.fill",
                isSystemImage: true,
                label: ""
            ),
            secondSecondaryIcon: nil
        )
    ]

    static let model = RootNavigationViewModel(injector: injector)

    static let injector = AnyNavigationInjector(
        behaviour: AnyNavigationBehavior(EmptyBehaviour()),
        persistence: AnyScreenPersistence(InMemoryScreenPersistence()),
        analytics: AnyAppAnalytics(NoOpAnalytics()),
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

    struct NoOpAnalytics<Screen>: AppAnalytics {
        func opened(screen: Screen) { }
    }
}

