//
//  StocksUITests.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import XCTest


final class StocksUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func testNavigationAndBackFlow() {
        let toggleButton = app.buttons["connection_toggle_button"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5))

        toggleButton.tap()
        
        let rowSymbolTextElement = app.staticTexts["stock_row_symbol"].firstMatch
        XCTAssertTrue(rowSymbolTextElement.waitForExistence(timeout: 5), "No symbol row cell found")

        let cellToTap = app.cells.containing(.staticText, identifier: rowSymbolTextElement.identifier).firstMatch
        cellToTap.tap()

        let aboutHeader = app.staticTexts["detail_screen_about"]
        XCTAssertTrue(aboutHeader.waitForExistence(timeout: 5), "Detail screen failed to load")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testToggleServiceConnection() {
        let toggleButton = app.buttons["connection_toggle_button"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5))

        let initialLabel = toggleButton.label
        
        toggleButton.tap()

        let predicate = NSPredicate(format: "label != %@", initialLabel)
        let expectation = expectation(for: predicate, evaluatedWith: toggleButton, handler: nil)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertNotEqual(toggleButton.label, initialLabel, "El texto del botón no cambió tras el tap")
    }

    func testSortingMenuInteraction() {
        let sortButton = app.buttons["sort_menu"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 2))
        sortButton.tap()
        
        let changeOption = app.buttons["sort_option_change"]
        XCTAssertTrue(changeOption.exists)
        changeOption.tap()
        
        XCTAssertFalse(changeOption.exists)
    }
    
}
