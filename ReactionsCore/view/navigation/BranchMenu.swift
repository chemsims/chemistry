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

    public init(layout: Layout) {
        self.layout = layout
    }

    let layout: Layout
    @Environment(\.menuCategories) var categories

    public var body: some View {
        BranchMenuWithCategories(
            categories: categories,
            layout: layout
        )
    }
}

private struct BranchMenuWithCategories: View {

    let categories: [BranchMenu.Category]
    let layout: BranchMenu.Layout
    @State private var selectedCategory: BranchMenu.Category? = nil
    @State private var expanded = false

    public var body: some View {
        VStack(alignment: .trailing, spacing: layout.headerToItemsSpacing) {
            header
            dropdown
        }
        .frame(width: layout.width, height: layout.height, alignment: .topTrailing)
        .animation(.easeOut(duration: 0.25), value: selectedCategory)
        .animation(.easeOut(duration: 0.25), value: expanded)
        .minimumScaleFactor(0.5)
    }

    private var header: some View {
        Button(action: toggleExpansion) {
            HStack(spacing: layout.headerToArrowSpacing) {
                Text("Chapters")
                Image(systemName: "chevron.right")
                    .frame(square: layout.arrowWidth)
                    .rotationEffect(expanded ? .degrees(90) : .zero)
                    .foregroundColor(.orangeAccent)
            }
        }
        .foregroundColor(.black)
        .frame(height: layout.headerHeight)
        .font(.system(size: layout.headerFontSize))
    }

    private var dropdown: some View {
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
            .padding(.leading, layout.leadingPadding)

            Rectangle()
                .frame(width: layout.indicatorThickness, height: verticalLineHeight)
                .padding(.top, 0.5 * layout.headerHeight)
        }
        .frame(height: expanded ? dropdownHeight : 0, alignment: .top)
        .clipped()
        .padding(.trailing, layout.arrowWidth / 2)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .shadow(radius: 2)
        )
        .allowsHitTesting(expanded)
    }

    private var dropdownHeight: CGFloat {
        let headerHeights = CGFloat(categories.count) * layout.headerHeight
        let headerSpacing = CGFloat(categories.count - 1) * layout.categorySpacing

        var itemSpacing = CGFloat(categories.count) * layout.headerToItemsSpacing

        if let selectedCategory = selectedCategory {
            itemSpacing += CGFloat(selectedCategory.items.count) * layout.itemHeight
        }

        return headerHeights + headerSpacing + itemSpacing
    }

    private var verticalLineHeight: CGFloat {
        var height = dropdownHeight
        height -= layout.headerToItemsSpacing
        height -= layout.headerHeight

        if let lastCategory = categories.last,
           let selectedCategory = selectedCategory,
           selectedCategory == lastCategory {
            height -= CGFloat(selectedCategory.items.count) * layout.itemHeight
        }

        return height
    }

    private func toggleExpansion() {
        expanded.toggle()
        if expanded {
            selectedCategory = categories.first { category in
                category.items.contains { item in
                    item.isSelected
                }
            }
        } else {
            selectedCategory = nil
        }
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
                    .frame(width: layout.headerWidth, height: layout.headerHeight, alignment: .trailing)

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
                    .frame(width: layout.itemWidth, height: layout.itemHeight, alignment: .trailing)
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
                .offset( x: layout.indicatorThickness)
        }
    }
}

extension BranchMenu {
    public struct Layout {

        public init(
            height: CGFloat = 20
        ) {
            self.height = height
        }

        public let height: CGFloat
        public var width: CGFloat {
            3 * height
        }

        var headerToItemsSpacing: CGFloat {
            height / 4
        }
        var categorySpacing: CGFloat {
            height / 2
        }

        var indicatorWidth: CGFloat {
            3 * headerToItemsSpacing
        }
        let indicatorThickness: CGFloat = 1

        var textToIndicatorSpacing: CGFloat {
            headerToItemsSpacing
        }
        var headerToArrowSpacing: CGFloat {
            headerToItemsSpacing
        }
        var arrowWidth: CGFloat {
            2 * headerToItemsSpacing
        }

        var itemHeight: CGFloat {
            height
        }
        var itemWidth: CGFloat {
            2.2 * width
        }
        var itemFontSize: CGFloat {
            0.5 * height
        }

        var headerWidth: CGFloat {
            itemWidth
        }
        var headerHeight: CGFloat {
            height
        }
        var headerFontSize: CGFloat {
            itemFontSize
        }

        var leadingPadding: CGFloat {
            headerToItemsSpacing
        }
        var topPadding: CGFloat {
            headerToItemsSpacing
        }

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
        BranchMenuWithCategories(
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
        .verticalSpacing(alignment: .top)
        .animation(.easeOut(duration: 0.35))
    }
}
