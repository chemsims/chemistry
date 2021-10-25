//
// Reactions App
//

import SwiftUI

extension EnvironmentValues {
    public var menuCategories: [BranchMenu.Category] {
        get { self[MenuCategoryKey.self] }
        set { self[MenuCategoryKey.self] = newValue }
    }
}

private struct MenuCategoryKey: EnvironmentKey {
    static let defaultValue = [BranchMenu.Category]()
}

public struct BranchMenu: View {

    init(categories: [Category], layout: Layout) {
        self.categories = categories
        self.layout = layout
        let initialSelectedCategory = categories.first { category in
            category.items.contains { item in
                item.isSelected
            }
        }
        self._selectedCategory = State(initialValue: initialSelectedCategory)
    }

    let categories: [Category]
    let layout: Layout
    @State private var selectedCategory: Category?

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .trailing, spacing: layout.categorySpacing) {
                ForEach(categories) { category in
                    CategoryMenu(
                        category: category,
                        selectedCategory: $selectedCategory,
                        layout: layout
                    )
                }
            }
            .padding(.top, layout.topPadding)
            .padding(.leading, layout.leadingPadding)

            Rectangle()
                .frame(width: layout.indicatorThickness, height: verticalLineHeight)
                .padding(.bottom, verticalLineBottomPadding)
        }
    }

    private var verticalLineHeight: CGFloat {
        let headerHeights = CGFloat(categories.count) * layout.headerHeight
        let halfOfBottomHeight = 0.5 * layout.headerHeight
        let headerSpacing = CGFloat(categories.count - 1) * layout.categorySpacing
        let topPadding = layout.topPadding

        var itemSpacing = CGFloat(categories.count - 1) * layout.headerToItemsSpacing

        if let lastCategory = categories.last,
            let selectedCategory = selectedCategory,
            selectedCategory != lastCategory {
            itemSpacing += CGFloat(selectedCategory.items.count) * layout.itemHeight
        }

        return topPadding + headerHeights + headerSpacing + itemSpacing - halfOfBottomHeight
    }

    private var verticalLineBottomPadding: CGFloat {
        var padding = layout.outerVerticalLineBottomPadding
        if let last = categories.last, last == selectedCategory {
            padding += (CGFloat(last.items.count) * layout.itemHeight)
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
            selectedCategory = isExpanded ? nil : category
        }) {
            HStack(spacing: layout.headerToArrowSpacing) {
                Text(category.name)
                    .frame(height: layout.headerHeight, alignment: .trailing)

                Image(systemName: "chevron.right")
                    .frame(square: layout.arrowWidth)
                    .rotationEffect(isExpanded ? .degrees(90) : .zero)
            }
            .withHorizontalIndicator(layout: layout)
        }
        .foregroundColor(.black)
        .font(.system(size: layout.headerFontSize))
    }

    private var items: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(category.items) { item in
                    Button(action: item.action) {
                        Text(item.name)
                    }
                    .frame(height: layout.itemHeight, alignment: .trailing)
                    .lineLimit(1)
                    .font(.system(size: layout.itemFontSize))
                    .withHorizontalIndicator(layout: layout)
                    .foregroundColor(itemColor(item))
                    .disabled(!isExpanded || !item.canSelect)
                }
            }

            Rectangle()
                .frame(width: layout.indicatorThickness)
                .padding(.bottom, layout.itemHeight / 2)
        }
        .padding(.trailing, layout.itemTrailingPadding)
        .frame(height: isExpanded ? expandedItemHeight : 0, alignment: .top)
        .clipped()
    }

    private func itemColor(_ item: BranchMenu.CategoryItem) -> Color {
        if item.isSelected {
            return .orangeAccent
        } else if item.canSelect {
            return .black
        }
        return .gray
    }

    private var expandedItemHeight: CGFloat {
        CGFloat(category.items.count) * layout.itemHeight
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
    public struct Layout {

        let headerToItemsSpacing: CGFloat = 5
        let categorySpacing: CGFloat = 10

        let indicatorWidth: CGFloat = 15
        let indicatorThickness: CGFloat = 1

        let textToIndicatorSpacing: CGFloat = 5
        let headerToArrowSpacing: CGFloat = 5
        let arrowWidth: CGFloat = 10

        let itemHeight: CGFloat = 20
        let itemFontSize: CGFloat = 12

        let headerHeight: CGFloat = 20
        let headerFontSize: CGFloat = 12

        let leadingPadding: CGFloat = 5
        let topPadding: CGFloat = 5

        var itemTrailingPadding: CGFloat {
            textToIndicatorSpacing + indicatorWidth + (arrowWidth / 2)
        }

        var outerVerticalLineBottomPadding: CGFloat {
            headerToItemsSpacing + (headerHeight / 2)
        }
    }
}

extension BranchMenu {
    public struct Category: Identifiable, Equatable {

        public init(name: String, items: [CategoryItem]) {
            self.name = name
            self.items = items
        }

        public let name: String
        public let items: [CategoryItem]

        public func deselectAllItems() -> Category {
            Category(name: name, items: items.map { $0.setSelected(false) })
        }

        public func appendingAction(_ newAction: @escaping () -> Void) -> Category {
            Category(name: name, items: items.map { $0.appendingAction(newAction)})
        }

        public var id: String {
            name
        }
    }

    public struct CategoryItem: Identifiable, Equatable {
        public init(
            name: String,
            isSelected: Bool,
            canSelect: Bool,
            action: @escaping () -> Void
        ) {
            self.name = name
            self.isSelected = isSelected
            self.canSelect = canSelect
            self.action = action
        }

        public let name: String
        public let isSelected: Bool
        public let canSelect: Bool
        public let action: () -> Void

        public var id: String {
            name
        }

        public func setSelected(_ value: Bool) -> CategoryItem {
            CategoryItem(name: name, isSelected: value, canSelect: canSelect, action: action)
        }

        public func appendingAction(_ newAction: @escaping () -> Void) -> CategoryItem {
            CategoryItem(name: name, isSelected: isSelected, canSelect: canSelect, action: {
                action()
                newAction()
            })
        }

        public static func == (lhs: BranchMenu.CategoryItem, rhs: BranchMenu.CategoryItem) -> Bool {
            lhs.name == rhs.name && lhs.isSelected == rhs.isSelected && lhs.canSelect == rhs.canSelect
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
                        .init(name: "Zero order", isSelected: false, canSelect: true, action: {}),
                        .init(name: "First order", isSelected: true, canSelect: true, action: {}),
                        .init(name: "Second order", isSelected: false, canSelect: true, action: {}),
                        .init(name: "Reaction comparison", isSelected: false, canSelect: true, action: {}),
                        .init(name: "Energy profile", isSelected: false, canSelect: true, action: {})
                    ]
                ),
                .init(
                    name: "Equilibrium",
                    items: [
                        .init(name: "Aqueous reactions", isSelected: false, canSelect: true, action: {}),
                        .init(name: "Gaseous reactions", isSelected: false, canSelect: true, action: {}),
                        .init(name: "Solid reactions", isSelected: false, canSelect: true, action: {})
                    ]
                ),
                .init(
                    name: "Acids & Bases",
                    items: [
                        .init(name: "Introduction", isSelected: false, canSelect: true, action: {}),
                        .init(name: "Buffers", isSelected: false, canSelect: true, action: {}),
                        .init(name: "Titration", isSelected: false, canSelect: true, action: {})
                    ]
                )
            ],
            layout: .init()
        )
    }
}
