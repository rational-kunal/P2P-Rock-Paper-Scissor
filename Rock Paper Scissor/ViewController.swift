//
//  ViewController.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 04/02/24.
//

import MultipeerConnectivity
import OSLog
import TinyConstraints
import UIKit

fileprivate let BackgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.90, alpha: 1.00)
fileprivate var StartGameDelayDispatchTime: DispatchTime {
    get { .now().advanced(by: .seconds(3)) }
}


class ViewController: UIViewController {
    lazy var gameSessionService: GameSessionService = {
        let manager = GameSessionService()
        manager.delegate = self
        return manager
    }()

    lazy var startMenuView: StartMenuView = {
        let view = StartMenuView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    lazy var gameView: GameView = {
        let view = GameView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHeirarchy()
        setupConstraints()
        stylize()
    }
    
    private func setupViewHeirarchy() {
        view.addSubview(startMenuView)
        view.addSubview(gameView)
    }
    
    private func setupConstraints() {
        startMenuView.edgesToSuperview()
        gameView.edgesToSuperview()
    }
    
    private func stylize() {
        view.backgroundColor = BackgroundColor
    }
}

extension ViewController: StartMenuViewDelegate {
    func didTapOnHost() {
        gameSessionService.host()
    }
    
    func didTapOnJoin() {
        gameSessionService.join()
    }
}

extension ViewController: GameViewDelegate {
    func didSelect(hand: Hand) {
        gameSessionService.select(hand: hand)
    }
}

extension ViewController: GameSessionManageDelegate {
    func didUpdate(gameState: GameState) {
        if gameState.sessionState == .connected {
            startMenuView.isHidden = true
            gameView.isHidden = false
        }

        gameView.configure(forGameState: gameState)
        startMenuView.configure(forGameState: gameState)

        if gameState.didEnd {
            DispatchQueue.main.asyncAfter(deadline: StartGameDelayDispatchTime) { [weak self] in
                self?.gameSessionService.startNewGame()
            }
        }
    }
}
