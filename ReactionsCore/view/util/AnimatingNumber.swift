//
// ReactionsCore
//

import SwiftUI

public struct AnimatingNumber: View {

    let x: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String
    let alignment: Alignment

    public init(
        x: CGFloat,
        equation: Equation,
        formatter: @escaping (CGFloat) -> String,
        alignment: Alignment = .center
    ) {
        self.x = x
        self.equation = equation
        self.formatter = formatter
        self.alignment = alignment
    }

    public var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .modifier(
                AnimatingNumberModifier(
                    x: x,
                    equation: equation,
                    formatter: formatter,
                    alignment: alignment
                )
            )
    }
}

public struct AnimatingTextLine: View {

    let x: CGFloat
    let equation: Equation
    let fontSize: CGFloat
    let formatter: (CGFloat) -> TextLine
    let alignment: Alignment

    public init(
        x: CGFloat,
        equation: Equation,
        fontSize: CGFloat,
        formatter: @escaping (CGFloat) -> TextLine,
        alignment: Alignment = .center
    ) {
        self.x = x
        self.equation = equation
        self.fontSize = fontSize
        self.formatter = formatter
        self.alignment = alignment
    }

    public var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .modifier(
                AnimatingTextLineModifier(
                    x: x,
                    fontSize: fontSize,
                    alignment: alignment,
                    format: { x in
                        formatter(equation.getY(at: x))
                    }
                )
            )
    }
}

public struct AnimatingNumberModifier: AnimatableModifier {

    var x: CGFloat
    let equation: Equation
    let formatter: (CGFloat) -> String
    let alignment: Alignment

    public var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    public func body(content: Content) -> some View {
        content
            .modifier(
                AnimatingValueModifier(
                    x: x,
                    alignment: alignment,
                    format: { x in
                        formatter(equation.getY(at: x))
                    }
                )
            )
    }
}

public struct AnimatingValueModifier: AnimatableModifier {

    var x: CGFloat
    let alignment: Alignment
    var format: (CGFloat) -> String

    public var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    public func body(content: Content) -> some View {
        let value = Text(format(x))
        return content
            .overlay(value, alignment: alignment)
            .accessibility(value: value)
            .accessibility(addTraits: .updatesFrequently)
    }
}

public struct AnimatingTextLineModifier: AnimatableModifier {
    var x: CGFloat
    let fontSize: CGFloat
    let alignment: Alignment
    var format: (CGFloat) -> TextLine

    public var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    public func body(content: Content) -> some View {
        let textLine = format(x)
        return content
            .overlay(TextLinesView(line: textLine, fontSize: fontSize), alignment: alignment)
            .accessibility(value: Text(textLine.label))
            .accessibility(addTraits: .updatesFrequently)
    }
}

/// An animatable modifier which also hides the view, for example to use in accessibility values
public struct AccessibleValueModifier: AnimatableModifier {
    private var x: CGFloat
    private let format: (CGFloat) -> String

    public init(x: CGFloat, format: @escaping (CGFloat) -> String) {
        self.x = x
        self.format = format
    }

    public var animatableData: CGFloat {
        get { x }
        set { x = newValue }
    }

    public func body(content: Content) -> some View {
        let value = Text(format(x))
        return content
            .overlay(value.opacity(0))
            .accessibility(value: value)
            .accessibility(addTraits: .updatesFrequently)
    }
}

extension View {

    /// Adds an accessibility value which is a function of the input `x`
    public func updatingAccessibilityValue(
        x: CGFloat,
        format: @escaping (CGFloat) -> String
    ) -> some View {
        self.modifier(AccessibleValueModifier(x: x, format: format))
    }
}
