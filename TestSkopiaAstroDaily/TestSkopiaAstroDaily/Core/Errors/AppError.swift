import Foundation

enum AppError: LocalizedError, Equatable {
    case network(NetworkError)
    case noData
    case cacheFailure
    case invalidDate
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .network(let networkError):
            return networkError.errorDescription
        case .noData:
            return Strings.errorNoData
        case .cacheFailure:
            return Strings.errorCacheFailure
        case .invalidDate:
            return Strings.errorInvalidDate
        case .unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network(.http(404)):
            return Strings.errorRecoveryNoData
        case .network:
            return Strings.errorRecoveryNetwork
        case .noData:
            return Strings.errorRecoveryTryAgain
        case .cacheFailure:
            return Strings.errorRecoveryRestart
        case .invalidDate:
            return Strings.errorRecoverySelectValidDate
        case .unknown:
            return Strings.errorRecoveryTryAgain
        }
    }
    
    static func from(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(networkError)
        }
        return .unknown(error.localizedDescription)
    }
    
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.network(let lhsError), .network(let rhsError)):
            return lhsError == rhsError
        case (.noData, .noData),
             (.cacheFailure, .cacheFailure),
             (.invalidDate, .invalidDate):
            return true
        case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .network(.http(let code)):
            return code != 404
        case .network:
            return true
        case .noData, .cacheFailure, .unknown:
            return true
        case .invalidDate:
            return false
        }
    }
}
