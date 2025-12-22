import Foundation

struct PaginationRequest {
    let limit: Int
    let offset: Int
}

struct PaginationResult<T> {
    let items: [T]
    let totalCount: Int
    let hasMore: Bool
}
