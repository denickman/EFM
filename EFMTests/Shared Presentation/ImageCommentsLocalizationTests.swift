//
//  ImageCommentsLocalizationTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 19.03.2025.
//


import XCTest
import EFM

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExist(bundle, table)
    }
}
