//
//  StartMenuView.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 04/02/24.
//

import UIKit

protocol StartMenuViewDelegate {
    func didTapOnHost()
    func didTapOnJoin()
}

class StartMenuView: UIView {
    var gameState: GameState?

    var delegate: StartMenuViewDelegate?
    
    lazy var heroLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.text = "🪨📄✂️"
        label.font = .systemFont(ofSize: 48.0)
        return label
    }()

    lazy var hostButton: UIButton = {
        let action = UIAction(title: "Host") { (action) in
            self.delegate?.didTapOnHost()
        }
        let btn = UIButton(configuration: .tinted(), primaryAction: action)
        btn.configurationUpdateHandler = { [self] button in
            guard var config = button.configuration,
                  let gameState else {
                      return
                  }
            
            config.buttonSize = .medium
            config.showsActivityIndicator = gameState.sessionState == .hosting
            config.imagePlacement = .trailing
            config.imagePadding = 6.0
            button.isEnabled = !gameState.sessionConnecting
            button.configuration = config
        }
        return btn
    }()

    lazy var joinButton: UIButton = {
        let action = UIAction(title: "Join") { (action) in
            self.delegate?.didTapOnJoin()
        }
        let btn = UIButton(configuration: .tinted(), primaryAction: action)
        btn.configurationUpdateHandler = { [self] button in
            guard var config = button.configuration,
                  let gameState else {
                      return
                  }
            
            config.buttonSize = .medium
            config.showsActivityIndicator = gameState.sessionState == .joining
            config.imagePlacement = .trailing
            config.imagePadding = 6.0
            button.isEnabled = !gameState.sessionConnecting
            button.configuration = config
        }
        return btn
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [heroLabel, hostButton, joinButton])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewHeirarchy()
        setupConstraints()
        stylize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewHeirarchy() {
        addSubview(mainStack)
    }
    
    func setupConstraints() {
        mainStack.centerInSuperview()
    }
    
    func stylize() {
        
    }
    
    func configure(forGameState gameState: GameState) {
        self.gameState = gameState
        hostButton.setNeedsUpdateConfiguration()
        joinButton.setNeedsUpdateConfiguration()
    }
    
}
