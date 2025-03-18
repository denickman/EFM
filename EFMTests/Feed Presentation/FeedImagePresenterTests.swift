//
//  FeedImagePresenterTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import XCTest
import EFM

final class FeedImagePresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(image)

        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
}
