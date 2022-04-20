
import ObjectMapper
import SwiftUI

// MARK: Modifier for showing/hiding dynamically.

struct Show: ViewModifier {
    @Binding var isVisible: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isVisible {
            content
        } else {
            content.hidden()
        }
    }
}

// MARK: View + Show/Hide

extension View {
    func visible(_ isVisible: Binding<Bool>) -> some View {
        ModifiedContent(content: self, modifier: Show(isVisible: isVisible))
    }

    func visible(_ isVisible: String) -> some View {
        ModifiedContent(content: self, modifier: Show(isVisible: Binding(get: {
            !isVisible.isEmpty
        }, set: { _ in })))
    }
}

// MARK: View + Exts

public extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

    @ViewBuilder func round(with radius: CGFloat = 10, strokeColor: Color, lineWidth: CGFloat = 1) -> some View {
        cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius).stroke(strokeColor, lineWidth: lineWidth)
            )
    }

    @ViewBuilder func round(with radius: CGFloat = 10, color: Color) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
        )
    }

    @ViewBuilder func backgroundColor(_ color: Color) -> some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            self
        }
    }
}

// MARK: ActivityIndicatorPosition

enum ActivityIndicatorPosition {
    case top
    case center
    case bottom
}

// MARK: View + ActivityIndicator

public let indicatorSize = CGSize(width: 30, height: 30)
extension View {
    @ViewBuilder func showActivityIndicator(
        _ status: Bool,
        position: ActivityIndicatorPosition
    ) -> some View {
        VStack {
            if position == .bottom || position == .center {
                Spacer()
            }

            HStack {
                Spacer()

                /// Indicator
                ActivityIndicator(color: Color.primary)

                /// trailing space
                Spacer()
            }

            /// trailing space
            if position == .top || position == .center {
                Spacer()
            }
        }
        .isHidden(!status)
    }
}

#if canImport(UIKit)
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif

// MARK: Increase touchable area with navigation bar item

extension View {
    @ViewBuilder func scaleToFitNavigationBar(_ alignment: Alignment = .trailing) -> some View {
        frame(width: 44, height: 44, alignment: alignment)
    }
}

// MARK: Capture current view

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

// MARK: Navigation Bar Modifier

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor?
    var titleColor: UIColor?

    init(backgroundColor: UIColor?, titleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
}
