//
// Reactions App
//

import SwiftUI

/// Provides the view for a screen of the app
///
/// The provider should maintain it's underlying state, so that the view can be restored again when
/// viewing the screen later - for example, as the user goes back through the previous screens
///
/// It is not necessary to store the view itself in the provider - only the underlying state should be stored.
public protocol ScreenProvider {
    var screen: AnyView { get }
}
