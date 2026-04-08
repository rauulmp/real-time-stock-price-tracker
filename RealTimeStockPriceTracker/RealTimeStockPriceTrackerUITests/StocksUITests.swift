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
        let stopButton = app.buttons["Stop Feed"]
        if stopButton.waitForExistence(timeout: 5) {
            stopButton.tap()
        }

        let rowSymbolTextElement = app.staticTexts["stock_row_symbol"].firstMatch
        XCTAssertTrue(rowSymbolTextElement.waitForExistence(timeout: 5), "No symbol row cell found")

        let cellToTap = app.cells.containing(.staticText, identifier: rowSymbolTextElement.identifier).firstMatch
        cellToTap.tap()

        let aboutHeader = app.staticTexts["ABOUT"]
        XCTAssertTrue(aboutHeader.waitForExistence(timeout: 5), "Detail screen failed to load")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Market"].waitForExistence(timeout: 5))
    }

    func testToggleServiceConnection() {
        let stopButton = app.buttons["Stop Feed"]
        let startButton = app.buttons["Start Feed"]
        
        if stopButton.waitForExistence(timeout: 3) {
            stopButton.tap()
            XCTAssertTrue(startButton.waitForExistence(timeout: 2))
        } else if startButton.exists {
            startButton.tap()
            XCTAssertTrue(stopButton.waitForExistence(timeout: 2))
        }
    }

    func testSortingMenuInteraction() {
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 2))
        sortButton.tap()
        
        let changeOption = app.buttons["Change"]
        XCTAssertTrue(changeOption.exists)
        changeOption.tap()
        
        XCTAssertFalse(changeOption.exists)
    }
    
}
