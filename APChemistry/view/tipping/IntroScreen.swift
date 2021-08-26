//
// Reactions App
//

import ReactionsCore
import SwiftUI

extension SupportStudentsModal {
    struct IntroScreen: View {

        init(
            settings: SupportStudentsModalSettings,
            nestInScrollView: Bool = true,
            includeImageBackground: Bool = false
        ) {
            self.settings = settings
            self.nestInScrollView = nestInScrollView
            self.includeImageBackground = includeImageBackground
        }

        let settings: SupportStudentsModalSettings
        let nestInScrollView: Bool
        let includeImageBackground: Bool

        var body: some View {
            VStack(spacing: 0) {
                image

                if nestInScrollView {
                    ScrollView {
                        centeredContent
                    }
                    .padding(.horizontal, settings.mainContentScrollViewHPadding)
                } else {
                    centeredContent
                }
            }
        }

        private var centeredContent: some View {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                mainContent
                    .frame(width: settings.mainContentWidth)
                Spacer(minLength: 0)
            }
        }

        private var mainContent: some View {
            VStack(alignment: .leading, spacing: settings.vSpacing) {
                Text("Hyper learning")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primaryDarkBlue)
                    .frame(width: settings.mainContentWidth)

                Text(message1)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.75)

                Text(message2)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.75)

                LegacyLink(destination: .virk2013Paper) {
                    Text("1. Open paper in browser.")
                }
            }
        }

        private var image: some View {
            Image("hyperlearning")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(size: settings.hyperLearningImageSize)
                .frame(height: settings.bannerHeight)
                .background(imageBackground)
        }

        @ViewBuilder
        private var imageBackground: some View {
            if includeImageBackground {
                RoundedRectangle(cornerRadius: settings.cornerRadius)
                    .foregroundColor(.primaryLightBlue)
            }
        }

        private let message1 = """
        We are visualizing STEM in ways never before done, and showing concepts to make \
        learning 700% faster or more (Virk, 2013)¹. We call it hyper learning, and want to expand \
        it to all of chemistry and all of physics and STEM for the students of the world with \
        your help!
        """

        private let message2: String = """
        Based on a cutting edge doctoral dissertation at Columbia University and backed by \
        cognition science.
        """
    }
}

struct IntroScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SupportStudentsModal.IntroScreen(
                settings: .init(geometry: geo)
            )
        }
    }
}
