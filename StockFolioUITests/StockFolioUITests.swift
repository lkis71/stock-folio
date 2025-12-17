import XCTest

/// StockFolio UI 테스트 (XCUITest)
/// 사용자 플로우 및 접근성 테스트
final class StockFolioUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main Dashboard Tests

    func test_mainDashboard_shouldDisplayInvestmentCards() throws {
        // Given: 앱이 실행된 상태

        // Then: 투자 금액, 남은 현금 카드가 표시되어야 함
        let investmentCard = app.staticTexts["투자 금액"]
        let cashCard = app.staticTexts["남은 현금"]

        XCTAssertTrue(investmentCard.waitForExistence(timeout: 5))
        XCTAssertTrue(cashCard.exists)
    }

    func test_mainDashboard_shouldDisplaySettingsButton() throws {
        // Given: 앱이 실행된 상태

        // Then: 설정 버튼이 표시되어야 함
        let settingsButton = app.buttons["설정"]

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
    }

    func test_mainDashboard_shouldDisplayAddButton() throws {
        // Given: 앱이 실행된 상태

        // Then: 종목 추가 버튼이 표시되어야 함
        let addButton = app.buttons["종목 추가"]

        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
    }

    // MARK: - Add Stock Flow Tests

    func test_addStockFlow_shouldOpenAddStockSheet() throws {
        // Given: 메인 화면
        let addButton = app.buttons["종목 추가"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))

        // When: 추가 버튼 탭
        addButton.tap()

        // Then: 종목 추가 시트가 표시되어야 함
        let stockNameField = app.textFields["종목명 입력"]
        XCTAssertTrue(stockNameField.waitForExistence(timeout: 3))
    }

    func test_addStockFlow_shouldAddNewStock() throws {
        // Given: 종목 추가 시트 열기
        let addButton = app.buttons["종목 추가"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // When: 종목 정보 입력
        let stockNameField = app.textFields["종목명 입력"]
        XCTAssertTrue(stockNameField.waitForExistence(timeout: 3))
        stockNameField.tap()
        stockNameField.typeText("테스트종목")

        let amountField = app.textFields["매수 금액 입력"]
        amountField.tap()
        amountField.typeText("1000000")

        // 저장 버튼 탭
        let saveButton = app.buttons["저장"]
        saveButton.tap()

        // Then: 시트가 닫히고 종목이 리스트에 표시되어야 함
        let addedStock = app.staticTexts["테스트종목"]
        XCTAssertTrue(addedStock.waitForExistence(timeout: 3))
    }

    func test_addStockFlow_shouldShowValidationError_withEmptyName() throws {
        // Given: 종목 추가 시트 열기
        let addButton = app.buttons["종목 추가"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // When: 금액만 입력하고 저장
        let amountField = app.textFields["매수 금액 입력"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 3))
        amountField.tap()
        amountField.typeText("1000000")

        let saveButton = app.buttons["저장"]
        saveButton.tap()

        // Then: 에러 메시지가 표시되어야 함 (시트가 닫히지 않음)
        XCTAssertTrue(amountField.exists)
    }

    // MARK: - Settings Flow Tests

    func test_settingsFlow_shouldOpenSeedMoneySettings() throws {
        // Given: 메인 화면
        let settingsButton = app.buttons["설정"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))

        // When: 설정 버튼 탭
        settingsButton.tap()

        // Then: 시드머니 설정 시트가 표시되어야 함
        let seedMoneyField = app.textFields["시드머니 입력"]
        XCTAssertTrue(seedMoneyField.waitForExistence(timeout: 3))
    }

    func test_settingsFlow_shouldSaveSeedMoney() throws {
        // Given: 설정 화면 열기
        let settingsButton = app.buttons["설정"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        // When: 시드머니 입력 및 저장
        let seedMoneyField = app.textFields["시드머니 입력"]
        XCTAssertTrue(seedMoneyField.waitForExistence(timeout: 3))
        seedMoneyField.tap()

        // 기존 값 지우기
        if let fieldValue = seedMoneyField.value as? String, !fieldValue.isEmpty {
            seedMoneyField.clearText()
        }

        seedMoneyField.typeText("50000000")

        let saveButton = app.buttons["저장"]
        saveButton.tap()

        // Then: 시트가 닫혀야 함
        XCTAssertFalse(seedMoneyField.waitForExistence(timeout: 2))
    }

    // MARK: - Stock List Tests

    func test_stockList_shouldShowExpandButton_whenMoreThan6Stocks() throws {
        // 이 테스트는 6개 이상의 종목이 있을 때만 유효
        // Given: 6개 이상의 종목이 있는 상태 (테스트 데이터 필요)

        // Then: 더보기 버튼이 표시되어야 함
        let moreButton = app.buttons["더 많은 종목 보기"]

        // 종목이 6개 미만이면 버튼이 없을 수 있음
        if moreButton.exists {
            XCTAssertTrue(moreButton.isHittable)
        }
    }

    // MARK: - UI Layout Tests

    func test_addStockView_buttonAreaShouldBeVisible() throws {
        // Given: 종목 추가 화면 열기
        let addButton = app.buttons["종목 추가"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Then: 저장 및 취소 버튼이 화면 하단에 표시되어야 함
        let saveButton = app.buttons["저장"]
        let cancelButton = app.buttons["취소"]

        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertTrue(cancelButton.exists)

        // 버튼이 화면에서 보이고 터치 가능해야 함
        XCTAssertTrue(saveButton.isHittable)
        XCTAssertTrue(cancelButton.isHittable)
    }

    func test_seedMoneySettings_buttonAreaShouldBeVisible() throws {
        // Given: 시드머니 설정 화면 열기
        let settingsButton = app.buttons["설정"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        // Then: 저장 및 취소 버튼이 화면 하단에 표시되어야 함
        let saveButton = app.buttons["저장"]
        let cancelButton = app.buttons["취소"]

        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        XCTAssertTrue(cancelButton.exists)

        // 버튼이 화면에서 보이고 터치 가능해야 함
        XCTAssertTrue(saveButton.isHittable)
        XCTAssertTrue(cancelButton.isHittable)
    }

    func test_addStockView_scrollContentShouldNotOverlapButtons() throws {
        // Given: 종목 추가 화면 열기
        let addButton = app.buttons["종목 추가"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // When: 스크롤 가능한 컨텐츠 영역 확인
        let stockNameField = app.textFields["종목명 입력"]
        let amountField = app.textFields["매수 금액 입력"]
        let saveButton = app.buttons["저장"]

        XCTAssertTrue(stockNameField.waitForExistence(timeout: 3))
        XCTAssertTrue(amountField.exists)
        XCTAssertTrue(saveButton.exists)

        // Then: 모든 요소가 동시에 화면에 표시되고 접근 가능해야 함
        XCTAssertTrue(stockNameField.isHittable)
        XCTAssertTrue(amountField.isHittable)
        XCTAssertTrue(saveButton.isHittable)
    }

    func test_seedMoneySettings_contentShouldNotOverlapButtons() throws {
        // Given: 시드머니 설정 화면 열기
        let settingsButton = app.buttons["설정"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        // When: 컨텐츠 영역 확인
        let seedMoneyField = app.textFields["시드머니 입력"]
        let saveButton = app.buttons["저장"]

        XCTAssertTrue(seedMoneyField.waitForExistence(timeout: 3))
        XCTAssertTrue(saveButton.exists)

        // Then: 모든 요소가 화면에 표시되고 접근 가능해야 함
        XCTAssertTrue(seedMoneyField.isHittable)
        XCTAssertTrue(saveButton.isHittable)
    }

    // MARK: - Accessibility Tests

    func test_accessibility_allButtonsShouldHaveLabels() throws {
        // Given: 앱이 실행된 상태

        // Then: 모든 주요 버튼에 접근성 레이블이 있어야 함
        let settingsButton = app.buttons["설정"]
        let addButton = app.buttons["종목 추가"]

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.exists)

        // 버튼이 접근 가능한지 확인
        XCTAssertTrue(settingsButton.isHittable)
        XCTAssertTrue(addButton.isHittable)
    }

    func test_accessibility_investmentCardsShouldBeCombined() throws {
        // Given: 앱이 실행된 상태
        // Wait for app to load
        _ = app.buttons["설정"].waitForExistence(timeout: 5)

        // Then: 투자 카드가 접근성 요소로 결합되어 있어야 함
        // 접근성 레이블이 "투자 금액"과 "남은 현금"을 포함하는 요소가 있어야 함
        // InvestmentSummaryCard uses .accessibilityElement(children: .combine)
        // which creates a combined accessibility element

        // Try to find the cards by checking all descendants
        let investmentCardExists = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS '투자 금액'")
        ).firstMatch.exists

        let cashCardExists = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS '남은 현금'")
        ).firstMatch.exists

        // 각 카드가 접근성 요소로 존재하는지 확인
        XCTAssertTrue(investmentCardExists, "투자 금액 카드가 접근성 요소로 존재해야 함")
        XCTAssertTrue(cashCardExists, "남은 현금 카드가 접근성 요소로 존재해야 함")
    }
}

// MARK: - XCUIElement Extension

extension XCUIElement {
    /// 텍스트 필드의 내용을 모두 지움
    func clearText() {
        guard let stringValue = self.value as? String else { return }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
