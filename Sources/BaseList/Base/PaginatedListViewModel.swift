
import Combine
import ObjectMapper

// MARK: ISummaryHeaderAdapter

public protocol ISummaryHeaderAdapter {
    var isAvailable: Bool { get }
    var isAvailablePublished: Published<Bool> { get }
    var isAvailablePublisher: Published<Bool>.Publisher { get }
}
// MARK: PaginatedListWithHeaderViewModel

open class PaginatedListWithHeaderViewModel<T: Mappable & Hashable>: PaginatedListViewModel<T>, ISummaryHeaderAdapter {
    
    public var isAvailablePublished: Published<Bool> { _isAvailable }
    public var isAvailablePublisher: Published<Bool>.Publisher { $isAvailable }
    /// information to request previous / next page
    @Published public private(set) var isAvailable: Bool = false

    internal var parameters: [String: Any] = [:]

    override open func invalidate() {
        super.invalidate()
//        pageInfo = nil
        isAvailable = false
    }

}
