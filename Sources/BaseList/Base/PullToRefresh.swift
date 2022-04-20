import Introspect
import SwiftUI

extension Color {
    public func uiColor() -> UIColor {
        return UIColor(self)
        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000FF) / 255
        }
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}


private struct PullToRefresh: UIViewRepresentable {
    @Binding var isShowing: Bool
    let color: UIColor
    let onRefresh: () -> Void

    public init(
        isShowing: Binding<Bool>,
        color: Color,
        onRefresh: @escaping () -> Void
    ) {
        _isShowing = isShowing
        self.color = color.uiColor()
        self.onRefresh = onRefresh
    }

    public class Coordinator {
        let onRefresh: () -> Void
        let isShowing: Binding<Bool>

        init(
            onRefresh: @escaping () -> Void,
            isShowing: Binding<Bool>
        ) {
            self.onRefresh = onRefresh
            self.isShowing = isShowing
        }

        @objc
        func onValueChanged() {
            isShowing.wrappedValue = true
            onRefresh()
        }
    }

    public func makeUIView(context: UIViewRepresentableContext<PullToRefresh>) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }

    private func tableView(entry: UIView) -> UITableView? {
        // Search in ancestors
        if let tableView = Introspect.findAncestor(ofType: UITableView.self, from: entry) {
            return tableView
        }

        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }

        // Search in siblings
        return Introspect.previousSibling(containing: UITableView.self, from: viewHost)
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PullToRefresh>) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let tableView = self.tableView(entry: uiView) else {
                return
            }

            if let refreshControl = tableView.refreshControl {
                if self.isShowing {
                    refreshControl.beginRefreshing()
                } else {
                    refreshControl.endRefreshing()
                }
                return
            }

            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = color
            refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.onValueChanged), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(onRefresh: onRefresh, isShowing: $isShowing)
    }
}

extension View {
    public func pullToRefresh(isShowing: Binding<Bool>, onRefresh: @escaping () -> Void) -> some View {
        return overlay(
            PullToRefresh(
                isShowing: isShowing,
                color: Color.primary,
                onRefresh: onRefresh
            )
            .frame(width: 0, height: 0)
        )
    }
}
