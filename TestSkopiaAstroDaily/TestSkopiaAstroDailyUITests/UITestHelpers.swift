import XCTest

extension XCUIApplication {
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    func waitForLoadingToFinish(timeout: TimeInterval = 15) {
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            let hasLoadingIndicator = activityIndicators.firstMatch.exists
            let hasLoadingText = staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'loading' OR label CONTAINS[c] 'carregando'")).firstMatch.exists
            
            if !hasLoadingIndicator && !hasLoadingText {
                break
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        Thread.sleep(forTimeInterval: 1)
    }
    
    func hasAnyContent() -> Bool {
        return staticTexts.firstMatch.exists || 
               images.firstMatch.exists || 
               navigationBars.firstMatch.exists ||
               buttons.firstMatch.exists
    }
    
    func isResponsive() -> Bool {
        return state == .runningForeground && hasAnyContent()
    }
    
    func waitForStableState(timeout: TimeInterval = 10) {
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if isResponsive() && !activityIndicators.firstMatch.exists {
                break
            }
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
}

extension XCTestCase {
    
    func assertAppIsResponsive(_ app: XCUIApplication,
                              message: String = "App deve estar responsivo",
                              file: StaticString = #file, 
                              line: UInt = #line) {
        XCTAssertTrue(app.isResponsive(), message, file: file, line: line)
    }
    
    func assertHasContent(_ app: XCUIApplication,
                         message: String = "App deve ter algum conteúdo",
                         file: StaticString = #file, 
                         line: UInt = #line) {
        XCTAssertTrue(app.hasAnyContent(), message, file: file, line: line)
    }
    
    func findAndTapButton(in app: XCUIApplication, 
                         containing keywords: [String],
                         timeout: TimeInterval = 5) -> Bool {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            let allButtons = app.buttons
            
            for i in 0..<min(allButtons.count, 15) {
                let button = allButtons.element(boundBy: i)
                if button.exists && button.isHittable {
                    let label = button.label.lowercased()
                    let identifier = button.identifier.lowercased()
                    
                    for keyword in keywords {
                        if label.contains(keyword.lowercased()) || identifier.contains(keyword.lowercased()) {
                            button.tap()
                            return true
                        }
                    }
                }
            }
            
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        return false
    }
    
    func navigateToFavoritesTab(in app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        let favoriteTabKeywords = ["favorite", "favorito", "star", "heart", "♥"]
        let tabBars = app.tabBars.firstMatch
        if tabBars.exists {
            let favoriteTab = tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'favorite' OR label CONTAINS[c] 'favorito'")).firstMatch
            if favoriteTab.exists && favoriteTab.isHittable {
                favoriteTab.tap()
                return true
            }
        }
        
        return findAndTapButton(in: app, containing: favoriteTabKeywords, timeout: timeout)
    }
}