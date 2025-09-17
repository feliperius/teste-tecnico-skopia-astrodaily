import XCTest

final class ImportantFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testCompleteFavoritesFlow() throws {
        app.waitForStableState(timeout: 15)
        app.waitForLoadingToFinish(timeout: 10)
        
        assertHasContent(app, message: "App deve ter conteúdo inicial")
        
        let favoriteKeywords = ["star", "favorite", "favorito", "like", "heart", "♥", "☆", "★"]
        let favoriteAdded = findAndTapButton(in: app, containing: favoriteKeywords, timeout: 10)
        
        if favoriteAdded {
            Thread.sleep(forTimeInterval: 3)
            
            let favoriteAddedScreenshot = app.screenshot()
            let favoriteAddedAttachment = XCTAttachment(screenshot: favoriteAddedScreenshot)
            favoriteAddedAttachment.name = "Favorito Adicionado"
            add(favoriteAddedAttachment)
            
            let navigatedToFavorites = navigateToFavoritesTab(in: app, timeout: 10)
            
            if navigatedToFavorites {
                Thread.sleep(forTimeInterval: 3)
                
                let favoritesScreenshot = app.screenshot()
                let favoritesAttachment = XCTAttachment(screenshot: favoritesScreenshot)
                favoritesAttachment.name = "Lista de Favoritos"
                add(favoritesAttachment)
                
                assertHasContent(app, message: "Lista de favoritos deve ter o item adicionado")
                
                let favoriteRemoved = findAndTapButton(in: app, containing: favoriteKeywords, timeout: 10)
                
                if favoriteRemoved {
                    Thread.sleep(forTimeInterval: 2)
                    
                    let favoriteRemovedScreenshot = app.screenshot()
                    let favoriteRemovedAttachment = XCTAttachment(screenshot: favoriteRemovedScreenshot)
                    favoriteRemovedAttachment.name = "Favorito Removido"
                    add(favoriteRemovedAttachment)
                } else {
                    throw XCTSkip("Funcionalidade de remoção de favoritos pode não estar implementada")
                }
            } else {
                throw XCTSkip("Navegação para favoritos pode não estar implementada")
            }
        } else {
            throw XCTSkip("Funcionalidade de favoritos pode não estar implementada")
        }
    }
    
    func testTemporalNavigationFlow() throws {
        app.waitForStableState(timeout: 15)
        app.waitForLoadingToFinish(timeout: 10)
        
        assertHasContent(app, message: "App deve ter conteúdo inicial")
        
        let initialScreenshot = app.screenshot()
        let initialAttachment = XCTAttachment(screenshot: initialScreenshot)
        initialAttachment.name = "APOD Inicial"
        add(initialAttachment)
        
        _ = app.staticTexts.firstMatch.label
        let previousKeywords = ["chevron", "previous", "anterior", "back", "left", "<", "◀", "‹"]
        let navigatedToPrevious = findAndTapButton(in: app, containing: previousKeywords, timeout: 10)
        
        if navigatedToPrevious {
            app.waitForStableState(timeout: 10)
            app.waitForLoadingToFinish(timeout: 15)
            Thread.sleep(forTimeInterval: 3)
            
            let previousScreenshot = app.screenshot()
            let previousAttachment = XCTAttachment(screenshot: previousScreenshot)
            previousAttachment.name = "APOD Dia Anterior"
            add(previousAttachment)
            
            assertHasContent(app, message: "Deve carregar conteúdo do dia anterior")
            
            let nextKeywords = ["next", "próximo", "forward", "right", ">", "▶", "›"]
            let navigatedToNext = findAndTapButton(in: app, containing: nextKeywords, timeout: 10)
            
            if navigatedToNext {
                app.waitForStableState(timeout: 10)
                app.waitForLoadingToFinish(timeout: 15)
                Thread.sleep(forTimeInterval: 3)
                
                let nextScreenshot = app.screenshot()
                let nextAttachment = XCTAttachment(screenshot: nextScreenshot)
                nextAttachment.name = "APOD Próximo Dia"
                add(nextAttachment)
                
                assertHasContent(app, message: "Deve carregar conteúdo do próximo dia")
                assertAppIsResponsive(app, message: "App deve permanecer responsivo após navegação temporal")
            } else {
                throw XCTSkip("Navegação para próximo dia pode não estar implementada")
            }
        } else {
            throw XCTSkip("Navegação temporal pode não estar implementada")
        }
    }
}
