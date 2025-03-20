//
//  XCTestCase+Snapshot.swift
//  EFMiOSTests
//
//  Created by Denis Yaremenko on 19.03.2025.
//

import XCTest

extension XCTestCase {
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        /// переменная file (параметр по умолчанию #filePath) представляет собой путь к исходному файлу, который содержит тест. Это означает, что переменная file будет указывать на файл теста, например, FeedSnapshotTests.swift.
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    /// check if the new snapshots are exactly the same as stored ones
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at url: \(snapshotURL). Use the record method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        /// если код внутри блока if не выполняется, и тест завершается без ошибки, что считается успешным выполнением теста.
        // in order to simplify the comparing between not equal snapshots we can write a new snapshot data
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        /// store the snapshot
        /// // ../EssentialFeediOSTests/snapshots/name.png
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return data
        
    }
}

