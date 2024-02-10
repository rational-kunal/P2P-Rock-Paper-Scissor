//
//  GameState.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 10/02/24.
//

import Foundation

struct GameState {
    var sessionState: SessionState
    
    var sessionConnecting: Bool {
        return sessionState == .hosting || sessionState == .joining
    }

    var ourHand: Hand
    
    var shouldLockSelection: Bool {
        return ourHand != .none
    }
    
    var shouldHintTheirHand: Bool {
        return theirHand != .none && ourHand == .none
    }
    
    var theirHand: Hand

    var shouldShowResult: Bool {
        return ourHand != .none && theirHand != .none
    }

    var didWin: Bool {
        guard ourHand != .none, theirHand != .none else {
            return false
        }

        switch ourHand {
        case .none:
            fatalError()
        case .rock:
            return theirHand == .scissor
        case .paper:
            return theirHand == .rock
        case .scissor:
            return theirHand == .paper
        }
    }
    
    var didEnd: Bool {
        return ourHand != .none && theirHand != .none
    }
    
    mutating func startNewGame() {
        ourHand = .none
        theirHand = .none
    }
}
