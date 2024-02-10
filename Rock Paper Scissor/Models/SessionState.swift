//
//  SessionState.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 10/02/24.
//

import Foundation

enum SessionState: String, CustomStringConvertible {
    case none, hosting, joining, connected
    var description: String {
        return self.rawValue
    }
}
