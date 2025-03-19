//
//  ImageCommentsPresenterTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 19.03.2025.
//

import Testing
import EFM
import Foundation

struct ImageCommentsPresenterTests {
    
    @Test
    func title_isLocalized() {
        #expect(ImageCommentsPresenter.title == localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    @Test
    func map_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.adding(minutes: -5, calendar: calendar),
                username: "a username"
            ),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(days: -1, calendar: calendar),
                username: "another username"
            )
        ]
        
        let viewModel = ImageCommentsPresenter.map(comments, currentDate: now, calendar: calendar, locale: locale)
        
        let expectedComments = [
            ImageCommentViewModel(message: "a message", date: "5 minutes ago", username: "a username"),
            ImageCommentViewModel(message: "another message", date: "1 day ago", username: "another username")
        ]
        
        #expect(viewModel.comments == expectedComments)
    }
    
    // MARK: - Helpers
    
    private func localized(_ key: String) -> String {
        
        func printBundleContents(for bundle: Bundle) {
            do {
                // Получаем все ресурсы в корне бандла
                let rootURLs = try FileManager.default.contentsOfDirectory(
                    at: bundle.bundleURL,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                
                print("Bundle path: \(bundle.bundlePath)")
                print("Contents of bundle (root):")
                for url in rootURLs {
                    print("- \(url.lastPathComponent)")
                    
                    // Если это папка .lproj, смотрим её содержимое
                    if url.pathExtension == "lproj" {
                        print("  Contents of \(url.lastPathComponent):")
                        let subURLs = try FileManager.default.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil,
                            options: []
                        )
                        for subURL in subURLs {
                            print("    - \(subURL.lastPathComponent)")
                        }
                    }
                }
            } catch {
                print("Error accessing bundle contents: \(error)")
            }
        }

        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = String(
            localized: String.LocalizationValue(key), // Ключ как LocalizationValue
            table: table,
            bundle: bundle
        )
        
        printBundleContents(for: bundle)
        
        // Проверка через Bundle.localizedString, так как String(localized:) не даёт прямого доступа к "сырому" значению
        let rawValue = bundle.localizedString(forKey: key, value: nil, table: table)
        #expect(rawValue != key, "Missing localized string for key: \(key) in table: \(table)")
        
        return value
    }
}
