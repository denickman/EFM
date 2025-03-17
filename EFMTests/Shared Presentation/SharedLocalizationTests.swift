//
//  SharedLocalizationTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 17.03.2025.
//

import Testing
import EFM
import Foundation
/*
 Если ты хочешь, чтобы Shared.xcstrings был доступен как файл в runtime, добавь его как сырой ресурс:
 В Build Phases → Copy Bundle Resources он уже есть, но убедись, что он не обрабатывается как локализация.
 В настройках проекта отключи Use Compiler to Extract Swift Strings (в Build Settings → Extract Localization Strings), чтобы Xcode не компилировал его автоматически.
 */

// TODO: - не находит файл с расширением
/*
final class SharedLocalizationTests {
    
    private class StubView: ResourceView {
        typealias ResourceViewModel = String
        func display(_ viewModel: String) {}
    }
    
    @Test("Check all string catalogs for empty values")
    func testStringCatalogsHaveValues() async throws {
        
        let bundle = Bundle(for: LoadResourcePresenter<String, StubView>.self)
        
        let catalogFiles = getStringCatalogFiles(bundle: bundle)
        
        #expect(!catalogFiles.isEmpty, "No .xcstrings files found in the bundle")
        
        for fileURL in catalogFiles {
            let strings = try extractStrings(from: fileURL)
            let fileName = fileURL.lastPathComponent
            
            for (key, localizations) in strings {
                for (language, value) in localizations {
                    #expect(
                        !value.isEmpty,
                        "Key '\(key)' in '\(fileName)' has no value for language '\(language)'"
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    struct StringCatalog: Decodable {
        
        let strings: [String: LocalizationEntry]
    }
    
    struct LocalizationEntry: Decodable {
        let localizations: [String: StringUnit]
    }
    
    struct StringUnit: Decodable {
        let stringUnit: Value?
        
        struct Value: Decodable {
            let value: String
        }
    }
    
    // Извлечение всех .xcstrings файлов из бандла
    func getStringCatalogFiles(bundle: Bundle) -> [URL] {
  
        let allFiles = bundle.paths(forResourcesOfType: nil, inDirectory: nil)
        for file in allFiles {
            print(file)
        }
   
        return bundle.paths(forResourcesOfType: "xcstrings", inDirectory: nil)
            .map { URL(fileURLWithPath: $0) }
    }
    
    // Парсинг файла и извлечение строк
    func extractStrings(from url: URL) throws -> [String: [String: String]] {
        let data = try Data(contentsOf: url)
        let catalog = try JSONDecoder().decode(StringCatalog.self, from: data)
        
        var result: [String: [String: String]] = [:]
        
        for (key, entry) in catalog.strings {
            
            var localizedValues: [String: String] = [:]
            
            for (language, unit) in entry.localizations {
                localizedValues[language] = unit.stringUnit?.value ?? ""
            }
            result[key] = localizedValues
        }
        return result
    }
}
*/
