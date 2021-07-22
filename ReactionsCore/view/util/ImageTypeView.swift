//
// Reactions App
//


import SwiftUI

extension Image {
    init(_ image: ImageType) {
        switch image {
        case let .application(name): self.init(name)
        case let .framework(name, bundle): self.init(name, bundle: bundle)
        case let .core(name): self.init(name.name, bundle: .reactionsCore)
        case let .system(name): self.init(systemName: name)
        }
    }
}

struct ImageTypeView_Previews: PreviewProvider {
    static var previews: some View {
        Image(.system("folder"))
    }
}
