//
//  HTTPURLResponse+StatusCode.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

extension HTTPURLResponse {
    
    private static var OK_200: Int {  200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
