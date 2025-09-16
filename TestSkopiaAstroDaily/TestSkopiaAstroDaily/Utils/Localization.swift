import Foundation

extension String {
    /// Retorna a string localizada para a chave fornecida
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Retorna a string localizada com argumentos
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// Constantes para as strings localizadas
enum Strings {
    // Splash Screen
    static let splashAppName = "splash.app_name".localized
    static let splashSubtitle = "splash.subtitle".localized
    
    // Tabs
    static let tabToday = "tab.today".localized
    static let tabList = "tab.list".localized
    static let tabFavorites = "tab.favorites".localized
    
    // Feed View
    static let feedTitle = "feed.title".localized
    static let feedLoading = "feed.loading".localized
    static let feedNoPhoto = "feed.no_photo".localized
    static let feedTryAgainLater = "feed.try_again_later".localized
    static let feedReload = "feed.reload".localized
    static let feedLoadingImage = "feed.loading_image".localized
    static let feedImageError = "feed.image_error".localized
    static let feedNoMedia = "feed.no_media".localized
    
    // List View
    static let listTitle = "list.title".localized
    static let listLoading = "list.loading".localized
    
    // Favorites View
    static let favoritesTitle = "favorites.title".localized
    static let favoritesUpdate = "favorites.update".localized
    static let favoritesNoFavorites = "favorites.no_favorites".localized
    static let favoritesAddTip = "favorites.add_favorites_tip".localized
    
    // Detail View
    static let detailTitle = "detail.title".localized
    static let detailNoMedia = "detail.no_media".localized
    
    // Error Messages
    static let errorNetwork = "error.network".localized
    static let errorTryAgain = "error.try_again".localized
    static let errorNoDataForDate = "error.no_data_for_date".localized
    static let errorHttp = "error.http".localized
    static let errorDecoding = "error.decoding".localized
    static let errorInvalidResponse = "error.invalid_response".localized
    
    // AppError specific messages
    static let errorNoData = "error.noData".localized
    static let errorCacheFailure = "error.cacheFailure".localized
    static let errorInvalidDate = "error.invalidDate".localized
    
    // Recovery suggestions
    static let errorRecoveryNoData = "error.recovery.noData".localized
    static let errorRecoveryNetwork = "error.recovery.network".localized
    static let errorRecoveryTryAgain = "error.recovery.tryAgain".localized
    static let errorRecoveryRestart = "error.recovery.restart".localized
    static let errorRecoverySelectValidDate = "error.recovery.selectValidDate".localized
    
    // Common
    static let copyright = "copyright".localized
    static let loading = "loading".localized
}