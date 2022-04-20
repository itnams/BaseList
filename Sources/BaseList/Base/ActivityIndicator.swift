
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    var isAnimating: Binding<Bool>
    let style: UIActivityIndicatorView.Style
    let color: UIColor

    init(
        isAnimating: Binding<Bool> = .constant(true),
        style: UIActivityIndicatorView.Style = .large,
        color: Color
    ) {
        self.isAnimating = isAnimating
        self.style = style
        self.color = UIColor(color)
    }

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let instance = UIActivityIndicatorView(style: style)
        instance.color = color
        return instance
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating.wrappedValue ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
