//
// Reactions App
//

import SwiftUI

struct BranchMenu: View {

    init(categories: [Category], layout: Layout) {
        self.categories = categories
        self.layout = layout
        self.selectedCategory = categories[0]
    }

    let categories: [Category]
    let layout: Layout
    @State private var selectedCategory: Category?

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: layout.categorySpacing) {
                    ForEach(categories) { category in
                        CategoryMenu(
                            category: category,
                            selectedCategory: $selectedCategory,
                            layout: layout
                        )
                    }
                }

                Rectangle()
                    .frame(width: layout.indicatorThickness)
                    .padding(.bottom, verticalLineBottomPadding)
            }
        }
        .animation(.easeOut(duration: 0.35), value: selectedCategory)
    }

    private var verticalLineBottomPadding: CGFloat {
        var padding = layout.outerVerticalLineBottomPadding
        if let last = categories.last, last == selectedCategory {
            padding += (CGFloat(last.items.count) * layout.itemSize.height)
        }

        return padding
    }
}

private struct CategoryMenu: View {

    let category: BranchMenu.Category
    @Binding var selectedCategory: BranchMenu.Category?
    let layout: BranchMenu.Layout

    var body: some View {
        VStack(alignment: .trailing, spacing: layout.headerToItemsSpacing) {
            header
            items
        }
    }

    private var header: some View {
        Button(action: {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
        }) {
            HStack(spacing: layout.headerToArrowSpacing) {
                Text(category.name)
                    .frame(size: layout.headerSize, alignment: .trailing)

                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .frame(width: layout.arrowWidth)
            }
            .withHorizontalIndicator(layout: layout)
        }
        .foregroundColor(.black)
        .font(.system(size: layout.headerFontSize))
    }

    private var items: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                ForEach(category.items) { item in
                    Button(action: item.action) {
                        Text(item.name)
                    }
                    .frame(size: layout.itemSize, alignment: .trailing)
                    .font(.system(size: layout.itemFontSize))
                    .withHorizontalIndicator(layout: layout)
                    .foregroundColor(item.isSelected ? .orangeAccent : .black)
                }
            }

            Rectangle()
                .frame(width: layout.indicatorThickness)
                .padding(.bottom, layout.itemSize.height / 2)
        }
        .padding(.trailing, layout.itemTrailingPadding)
        .frame(height: isExpanded ? expandedItemHeight : 0, alignment: .top)
        .clipped()
    }

    private var expandedItemHeight: CGFloat {
        CGFloat(category.items.count) * layout.itemSize.height
    }

    private var isExpanded: Bool {
        selectedCategory == category
    }
}

private extension View {
    func withHorizontalIndicator(layout: BranchMenu.Layout) -> some View {
        self.modifier(HorizontalIndicatorModifier(layout: layout))
    }
}

private struct HorizontalIndicatorModifier: ViewModifier {
    let layout: BranchMenu.Layout

    func body(content: Content) -> some View {
        HStack(spacing: layout.textToIndicatorSpacing) {
            content

            // Without the offset, there would be a small gap in the corner
            // between the vertical line and horizontal indicator
            Rectangle()
                .frame(width: layout.indicatorWidth, height: layout.indicatorThickness)
                .offset(x: layout.indicatorThickness)
        }
    }
}

extension BranchMenu {
    struct Layout {

        let headerToItemsSpacing: CGFloat = 5
        let categorySpacing: CGFloat = 10

        let indicatorWidth: CGFloat = 15
        let indicatorThickness: CGFloat = 1

        let textToIndicatorSpacing: CGFloat = 5
        let headerToArrowSpacing: CGFloat = 5
        let arrowWidth: CGFloat = 10

        let itemSize: CGSize = CGSize(width: 120, height: 20)
        let itemFontSize: CGFloat = 12

        let headerSize: CGSize = CGSize(width: 120, height: 20)
        let headerFontSize: CGFloat = 12

        var itemTrailingPadding: CGFloat {
            textToIndicatorSpacing + indicatorWidth + (arrowWidth / 2)
        }

        var outerVerticalLineBottomPadding: CGFloat {
            headerToItemsSpacing + (headerSize.height / 2)
        }
    }
}

extension BranchMenu {
    struct Category: Identifiable, Equatable {
        let name: String
        let items: [CategoryItem]

        var id: String {
            name
        }

        static func == (lhs: BranchMenu.Category, rhs: BranchMenu.Category) -> Bool {
            lhs.id == rhs.id
        }
    }

    struct CategoryItem: Identifiable {
        let name: String
        let isSelected: Bool
        let action: () -> Void

        var id: String {
            name
        }
    }
}

struct BranchMenu_Previews: PreviewProvider {
    static var previews: some View {
        BranchMenu(
            categories: [
                .init(
                    name: "Reaction rates",
                    items: [
                        .init(name: "Zero order", isSelected: false, action: {}),
                        .init(name: "First order", isSelected: true, action: {}),
                        .init(name: "Second order", isSelected: false, action: {}),
                        .init(name: "Reaction comparison", isSelected: false, action: {}),
                        .init(name: "Energy profile", isSelected: false, action: {})
                    ]
                ),
                .init(
                    name: "Equilibrium",
                    items: [
                        .init(name: "Aqueous reactions", isSelected: false, action: {}),
                        .init(name: "Gaseous reactions", isSelected: false, action: {}),
                        .init(name: "Solid reactions", isSelected: false, action: {})
                    ]
                ),
                .init(
                    name: "Acids & Bases",
                    items: [
                        .init(name: "Introduction", isSelected: false, action: {}),
                        .init(name: "Buffers", isSelected: false, action: {}),
                        .init(name: "Titration", isSelected: false, action: {})
                    ]
                )
            ],
            layout: .init()
        )
    }
}
