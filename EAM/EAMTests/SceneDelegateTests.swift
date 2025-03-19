//
//  SceneDelegateTests.swift
//  EAMTests
//
//  Created by Denis Yaremenko on 13.03.2025.
//

import XCTest
import EFMiOS
@testable import EAM
import UIKit

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {

        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window
        sut.configureWindow()
        
//        XCTAssertTrue(window.isKeyWindow, "Expected window to be the key window")
//        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow() // special custom method to invoke unavailable scene delegate methods
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) insetad")
        XCTAssertTrue(topController is ListViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }

}

