
import Combine
import ObjectMapper
import SwiftUI

extension CGFloat {
    public static let horizontalPadding: CGFloat = 10
    public static let vertialPadding: CGFloat = 10
    public static let sectionHeight: CGFloat = 50
    public static let sectionSpacing: CGFloat = 10
    public static let itemSpacing: CGFloat = 5
    public static let padding: CGFloat = 10
    public static let popUpPadding: CGFloat = 20
    public static let progressHeight: CGFloat = 20
}


public protocol IViewConfigurable {
    associatedtype T
    init(viewModel: T)
}

public final class TabIndex: ObservableObject, Identifiable {
    let index: Int
    @Published var isFocused: Bool = false
    init(index: Int, isFocused: Bool = false) {
        self.index = index
        self.isFocused = isFocused
    }
}

public struct BaseListView<CellType: View, T: Mappable & Hashable>: View {
    // View model
    @StateObject public var viewModel: PaginatedListWithHeaderViewModel<T>

    /// check error
    @State var hasError: Bool = false
    @State var allowScrollToTop = true

    /// a variable to check view is visible or not
    @StateObject public var tab: TabIndex

    /// cell creator
    var cellCreator: (T) -> CellType
    /// detect table view to handle deselect rows
    @State private var tableView: UITableView?
    private func deselectRows() {
        if let tableView = tableView, let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    // render body
    public var body: some View {
        /// table list
        ZStack(alignment: .leading) {
            Text("").opacity(0).onReceive(tab.$isFocused) { status in
                if status {
                    viewModel.loadInitialData()
                }
            }
            ScrollViewReader { scrollView in
                ZStack {
                    List {
                        ForEach(viewModel.items, id: \.self) { item in
                            cellCreator(item).onAppear {
                                viewModel.loadNextPageIfNeeded(at: item)
                                deselectRows()
                            }.id(viewModel.items.startIndex)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .introspectTableView(customize: { tableView in
                        self.tableView = tableView
                    })
                    .pullToRefresh(isShowing: $viewModel.isRefreshing , onRefresh: {
                        viewModel.refreshIfNeeded()
                    })
                    if viewModel.items.count > 12 && allowScrollToTop {
                        AlignmentableView(alignment: .rightBottom) {
                            Button(action: {
                                scrollView.scrollTo(viewModel.items.startIndex)
                            }
                            , label: {
                                VStack{
                                    Image(systemName: "chevron.left.2").resizable().frame(width: 20, height: 20, alignment: .center).rotationEffect(.degrees(90))
                                }.frame(width: 60, height: 60)
                            })
                            .padding( .trailing, .popUpPadding - 11)
                            .padding(.bottom,.popUpPadding + 72)
                        }
                    }
                }
            }
            showActivityIndicator(viewModel.isShowLoadingIndicator, position: .center)
            if viewModel.isShowEmptyDataView {
                EmptyDataView()
            }
        }
        .alert(isPresented: $hasError) { () -> Alert in
            Alert(
                title: Text(""),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("Dismiss"), action: {
                })
            )
        }
        .onReceive(viewModel.$errorMessage, perform: { value in
            hasError = !value.isEmpty
        })
    }
}

struct EmptyDataView: View {
    var body: some View {
        HStack(alignment:.center){
            Spacer()
            Text("No data")
            Spacer()
        }
    }
}
