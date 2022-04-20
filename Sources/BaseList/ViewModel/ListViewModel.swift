//
//  File.swift
//  
//
//  Created by ERM on 20/04/2022.
//

import Combine
import Foundation

// MARK: FetchDataState

public enum FetchDataState: String {
    case none
    case initial
    case fetching
    case refreshing
    case filtering
    case searching
}

// MARK: LoadMoreType

public enum LoadMoreType {
    case previous
    case next
}

// MARK: SubmitDataState

public enum SubmitDataState: Equatable, Identifiable, CustomStringConvertible {
    case none
    case submitting
    case success
    case error(String)
    case warning(String)
    case progress(String, Progress)
    case existed(String)
    public var description: String {
        switch self {
        case .none: return "None"
        case .submitting: return "Submitting"
        case .success: return "Success"
        case let .error(message): return "Error: \(message)"
        case let .warning(message): return "Warning: \(message)"
        case let .progress(text, progress): return "[Progress] - [\(text)]: \(progress.fractionCompleted)"
        case let .existed(message): return "Existed: \(message)"
        }
    }

    public var id: Int { description.hash }
    public static func == (lhs: SubmitDataState, rhs: SubmitDataState) -> Bool {
        return lhs.description == rhs.description
    }
    
    public var isFailure: Bool {
        if case .error(_) = self { return true }
        else if case .warning(_) = self { return true }
        else if case .existed(_) = self { return true }
        return false
    }
}

// MARK: IDataSource

public protocol IDataSource {}

// MARK:

open class ListViewModel<T: Hashable, E: EventType>: ViewModel<E>, IDataSource, ObservableObject, Identifiable {
    @Published var items: [T] = []
    @Published var isRefreshing = false
    @Published var isHiddenEmptyDataView = true
    private var state: FetchDataState = .none
    public var loadMoreType: LoadMoreType = .next
        
    var isFetchingMore: Bool { state == .fetching && !items.isEmpty }
    var isInitialFetching: Bool { state == .initial }
    var isSearching: Bool { state == .searching }
    var isFiltering: Bool { state == .filtering }
    var isShowLoadingIndicator: Bool { isFetchingMore || isInitialFetching || isSearching || isFiltering }
    var isShowEmptyDataView: Bool { items.count == 0  && !isShowLoadingIndicator && !isRefreshing && !isHiddenEmptyDataView }
    internal var canLoadMorePages: Bool = false

    public func isLastItem(_ item: T?) -> Bool {
        guard let item = item else {
            return false
        }
        let index = items.firstIndex(of: item)
        return items.count - 1 == index
    }

    public func isFirstItem(_ item: T?) -> Bool {
        guard let item = item else {
            return false
        }
        let index = items.firstIndex(of: item)
        return index == 0
    }

    open func invalidate() {
        items.removeAll() /// remove all items
    }

    open func resetState() {
        state = .none
        isHiddenEmptyDataView = false
        isRefreshing = false
    }

    open func refreshIfNeeded() {
        guard state == .none else {
            return
        }
        debugPrint("refreshIfNeeded")
        invalidate() /// reset all
        isHiddenEmptyDataView = false
        /// start load new
        state = .refreshing
        fetch()
    }
    
    open func filter() {
        guard state == .none else {
            return
        }
        debugPrint("refreshIfNeeded")
        invalidate() /// reset all
        isHiddenEmptyDataView = false
        /// start load new
        state = .filtering
        fetch()
    }
    
    open func searchData() {
        guard state == .none else {
            return
        }
        debugPrint("refreshIfNeeded")
        invalidate()
        isHiddenEmptyDataView = false
        state = .searching
        fetch()
    }
    open func loadInitialData() {
        guard state == .none && items.isEmpty else { return }
        state = .initial
        isHiddenEmptyDataView = false
        debugPrint("loadInitialData ---> \(state.rawValue)")
        fetch()
    }

    open func loadNextPageIfNeeded(at item: T? = nil) {
        guard let item = item else {
            loadMoreContent()
            return
        }

        if (loadMoreType == .next && isLastItem(item)) ||
            (loadMoreType == .previous && isFirstItem(item)) {
            loadMoreContent()
        }
    }

    private func loadMoreContent() {
        guard state == .none && canLoadMorePages else {
            return
        }
        debugPrint("loadMoreContent ---> \(state.rawValue)")
        state = .fetching
        isHiddenEmptyDataView = false
        fetch()
    }

    open func fetch() { fatalError("Absolutely override it.") }
}
open class PaginatedListViewModel<T: Hashable>: ListViewModel<T, String> {}

