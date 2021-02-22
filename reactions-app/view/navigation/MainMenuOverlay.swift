//
// Reactions App
//

import SwiftUI
import MessageUI
import ReactionsCore

struct MainMenuOverlay: View {

    let size: CGFloat
    let topPadding: CGFloat
    let menuHPadding: CGFloat
    @ObservedObject var navigation: RootNavigationViewModel

    @State private var showFailedMailAlert = false
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        GeometryReader { geo in
            MainMenuOverlayWithSettings(
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
        .sheet(item: $activeSheet) { item in
            switch item {
            case .mail:
                MailComposerView(onDismiss: { activeSheet = nil })
                    .edgesIgnoringSafeArea(.all)
            case .share:
                ShareSheetView(activityItems: [ShareSettings.message])
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .alert(isPresented: $showFailedMailAlert) {
            Alert(
                title: Text("Send Feedback"),
                message: Text("Could not open Mail composer. Please send feedback to \(FeedbackSettings.toAddress)."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

private enum ActiveSheet: Int, Identifiable {
    case mail, share

    var id: Int {
        rawValue
    }
}

private struct MainMenuOverlayWithSettings: View {

    @ObservedObject var navigation: RootNavigationViewModel
    @Binding var activeSheet: ActiveSheet?
    @Binding var showFailedMailAlert: Bool
    let settings: MainMenuLayoutSettings

    @State private var panelDragOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
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
            Image("share-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .colorMultiply(Styling.navIcon)
        }
        .accessibility(label: Text("Open share sheet"))
    }

    private var panelContent: some View {
        VStack(alignment: .leading, spacing: settings.navVStackSpacing) {
            navRow(screen: .zeroOrderReaction)
            navRow(screen: .firstOrderReaction)
            navRow(screen: .secondOrderReaction)
            navRow(screen: .reactionComparison)
            navRow(screen: .energyProfile)
        }
        .padding(settings.panelContentPadding)
    }

    private func navRow(screen: TopLevelScreen) -> some View {
        HStack(alignment: .bottom, spacing: settings.navRowHSpacing) {
            navIcon(
                image: screen.navImage,
                selectedImage: screen.navImagePressed,
                isSystem: false,
                screen: screen.appScreen,
                label: screen.label
            )
            .frame(height: settings.navIconHeight)

            navIcon(
                image: "text-book-closed",
                selectedImage: "text-book-closed",
                isSystem: false,
                screen: screen.quizScreen,
                label: "\(screen.label) quiz"
            )
            .frame(height: settings.secondaryIconHeight)

            if screen.filingScreen != nil {
                navIcon(
                    image: "archivebox-thinner",
                    selectedImage: "archivebox-thinner",
                    isSystem: false,
                    screen: screen.filingScreen!,
                    label: "\(screen.label) saved snapshots"
                )
                .frame(height: settings.secondaryIconHeight)
            }
        }
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

    private func navIcon(
        image: String,
        selectedImage: String,
        isSystem: Bool,
        screen: AppScreen,
        label: String
    ) -> some View {
        let isSelected = navigation.currentScreen == screen
        let canSelect = navigation.canSelect(screen: screen)

        let shouldFocus = navigation.focusScreen == screen
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

    private func goTo(screen: AppScreen) {
        navigation.jumpTo(screen: screen)
        toggleMenu()
    }

    private func toggleMenu() {
        navigation.showMenu.toggle()
    }
}

extension MainMenuOverlayWithSettings {
    private func openMailComposer() {
        if MailComposerView.canSendMail() {
            activeSheet = .mail
            return
        }

        if let url = FeedbackSettings.mailToUrl {
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

private enum TopLevelScreen {
    case zeroOrderReaction,
          firstOrderReaction,
          secondOrderReaction,
          reactionComparison,
          energyProfile

    var navImage: String {
        switch self {
        case .zeroOrderReaction: return "zeroordericon"
        case .firstOrderReaction: return "firstordericon"
        case .secondOrderReaction: return "secondordericon"
        case .reactionComparison: return "comparisonicon"
        case .energyProfile: return "kineticsicon"
        }
    }

    var navImagePressed: String {
        "\(navImage)-pressed"
    }

    var appScreen: AppScreen {
        switch self {
        case .zeroOrderReaction: return .zeroOrderReaction
        case .firstOrderReaction: return .firstOrderReaction
        case .secondOrderReaction: return .secondOrderReaction
        case .reactionComparison: return .reactionComparison
        case .energyProfile: return .energyProfile
        }
    }

    var quizScreen: AppScreen {
        switch self {
        case .zeroOrderReaction: return .zeroOrderReactionQuiz
        case .firstOrderReaction: return .firstOrderReactionQuiz
        case .secondOrderReaction: return .secondOrderReactionQuiz
        case .reactionComparison: return .reactionComparisonQuiz
        case .energyProfile: return .energyProfileQuiz
        }
    }

    var filingScreen: AppScreen? {
        switch self {
        case .zeroOrderReaction: return .zeroOrderFiling
        case .firstOrderReaction: return .firstOrderFiling
        case .secondOrderReaction: return .secondOrderFiling
        case .energyProfile: return .energyProfileFiling
        default: return nil
        }
    }

    var label: String {
        switch self {
        case .zeroOrderReaction: return "Zero order reaction"
        case .firstOrderReaction: return "First order reaction"
        case .secondOrderReaction: return "Second order reaction"
        case .reactionComparison: return "Reaction comparison"
        case .energyProfile: return "Energy profile"
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

struct MainMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuOverlay(
            size: 50,
            topPadding: 10,
            menuHPadding: 10,
            navigation: RootNavigationViewModel(
                injector: InMemoryInjector.shared
            )
        ).previewLayout(.fixed(width: 1300, height: 600))
    }
}
