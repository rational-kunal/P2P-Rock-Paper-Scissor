//
//  Hand.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 10/02/24.
//

import Foundation

enum Hand: Codable {
    case none, rock, paper, scissor
    
    static func from(data: Data) -> Hand? {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Hand.self, from: data)
        } catch {
            fatalError("TODO: Error handling")
        }
    }
    
    func toData() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            return try encoder.encode(self)
        } catch {
            fatalError("TODO: Error handling")
        }
    }
}
