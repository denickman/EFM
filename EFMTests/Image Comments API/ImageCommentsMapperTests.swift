//
//  ImageCommentsMapperTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 16.03.2025.
//

import Testing
import EFM
import Foundation

struct ImageCommentsMapperTests {
    
    @Test(arguments: [199, 150, 300, 400, 500])
    func map_throwsErrorOnNon2xxHTTPResponse(statusCode: Int) throws {
 
        let data = makeItemsJSON([])

        #expect(throws: ImageCommentsMapper.Error.invalidData, "Error not thrown in bad status response and emtpy data") {
            let response = HTTPURLResponse(statusCode: statusCode)
            _ = try ImageCommentsMapper.map(data, response: response)
        }
    }
    
    @Test(arguments: [199, 150, 300, 400, 500])
    func map_throwsErrorOn2xxHTTPResponseWithInvalidData(statusCode: Int) throws {
        let data = Data("invalid_json".utf8)

        #expect(throws: ImageCommentsMapper.Error.invalidData, "Error not thrown in bad status response and bad data") {
            let response = HTTPURLResponse(statusCode: statusCode)
            _ = try ImageCommentsMapper.map(data, response: response)
        }
    }
    
    @Test(arguments: [200, 201, 250, 280, 299])
    func map_deliversNoItemsOn2xxHTTPResponseWithEmptyData(statusCode: Int) throws {
        let emtpyData = makeItemsJSON([])
        
        let response = HTTPURLResponse(statusCode: statusCode)
        let result = try ImageCommentsMapper.map(emtpyData, response: response)
        
        #expect(result.isEmpty, "Items are empty on 2xx response with emtpy data")
    }
    
    @Test(arguments: [200, 201, 250, 280, 299])
    func map_devliersItemsOn2xxHTTPResponseWithJSONItems(statusCode: Int) throws {
        
        let item1 = makeItem(
                    id: UUID(),
                    message: "a message",
                    createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                    username: "a username")
        
        let item2 = makeItem(
                     id: UUID(),
                     message: "another message",
                     createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                     username: "another username")
        
        let jsonData = makeItemsJSON([item1.json, item2.json])
        
        let response = HTTPURLResponse(statusCode: statusCode)
        let result = try ImageCommentsMapper.map(jsonData, response: response)
        
        #expect(result == [item1.model, item2.model])
    }

    // MARK: - Helpers
    
    private func makeItem(
        id: UUID,
        message: String,
        createdAt: (date: Date, iso8601String: String),
        username: String
    ) -> (model: ImageComment, json: [String : Any]) {
        
        let model = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String : Any] = [
            "id" : id.uuidString,
            "message" : message,
            "created_at" : createdAt.iso8601String,
            "author" : [
                "username" : username
            ]
        ]
        
        return (model, json)
    }
    
}
