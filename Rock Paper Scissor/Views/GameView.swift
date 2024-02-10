//
//  GameView.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 05/02/24.
//

import UIKit

fileprivate let HandFontSize = 60.0
fileprivate let HandLabelOffset = 40.0
fileprivate let ResultFontSize = 98.0
fileprivate let InputButtonStackOffset = 40.0
fileprivate let InputButtonSpacing = 2.5
fileprivate let InputButtonFontSize = 30.0
fileprivate let InputButtonsLockOpacity = 0.3
fileprivate let InputButtonConfiguration: UIButton.Configuration = {
    var configuration = UIButton.Configuration.plain()
    configuration.buttonSize = .medium
    configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.font = UIFont.systemFont(ofSize: InputButtonFontSize)
        return outgoing
    }
    return configuration
}()
fileprivate let StateChangeAnimationDuration = 0.3
fileprivate var StateChangeAnimationDispatchTime: DispatchTime {
    get { .now().advanced(by: .milliseconds(400)) }
}
fileprivate let NeutralBackgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.90, alpha: 1.00)
fileprivate let SuccessBackgroundColor = UIColor(red: 0.51, green: 0.87, blue: 0.33, alpha: 1.00)
fileprivate let ErrorBackgroundColor = UIColor(red: 0.89, green: 0.21, blue: 0.21, alpha: 1.00)

protocol GameViewDelegate {
    func didSelect(hand: Hand)
}

class GameView: UIView {
    lazy var theirLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: HandFontSize)
        return label
    }()

    lazy var ourLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: HandFontSize)
        return label
    }()
    
    lazy var resultLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: ResultFontSize)
        return label
    }()
    
    lazy var rockButton: UIButton = {
        let action = UIAction(title: label(forHand: .rock)) { (action) in
            self.delegate?.didSelect(hand: .rock)
        }
        let btn = UIButton(configuration: InputButtonConfiguration, primaryAction: action)
        return btn
    }()

    lazy var paperButton: UIButton = {
        let action = UIAction(title: label(forHand: .paper)) { (action) in
            self.delegate?.didSelect(hand: .paper)
        }
        let btn = UIButton(configuration: InputButtonConfiguration, primaryAction: action)
        return btn
    }()
    
    lazy var scissorButton: UIButton = {
        let action = UIAction(title: label(forHand: .scissor)) { (action) in
            self.delegate?.didSelect(hand: .scissor)
        }
        let btn = UIButton(configuration: InputButtonConfiguration, primaryAction: action)
        return btn
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [rockButton, paperButton, scissorButton])
        stack.axis = .horizontal
        stack.spacing = InputButtonSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var delegate: GameViewDelegate?
    
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
        addSubview(theirLabel)
        addSubview(ourLabel)
        addSubview(resultLabel)
        addSubview(buttonStack)
    }
    
    func setupConstraints() {
        theirLabel.centerXToSuperview()
        theirLabel.centerYToSuperview(multiplier: 0.5, offset: HandLabelOffset)
        
        ourLabel.centerXToSuperview()
        ourLabel.centerYToSuperview(multiplier: 1.5, offset: -HandLabelOffset)
        
        resultLabel.centerInSuperview()

        buttonStack.topToBottom(of: ourLabel, offset: InputButtonStackOffset)
        buttonStack.centerXToSuperview()
    }
    
    func stylize() {
        
    }
    
    func configure(forGameState gameState: GameState) {
        theirLabel.setAnimatedText(gameState.shouldHintTheirHand ? "✅" : label(forHand: gameState.theirHand))
        ourLabel.setAnimatedText(label(forHand: gameState.ourHand))

        if gameState.didEnd {
            DispatchQueue.main.asyncAfter(deadline: StateChangeAnimationDispatchTime) { [self] in
                resultLabel.layer.opacity = 1.0
                resultLabel.setAnimatedText(resultLabel(forGameState: gameState), wiggle: true)
            }
        } else {
            UIView.animate(springDuration: StateChangeAnimationDuration) { [self] in
                resultLabel.layer.opacity = 0.0
                resultLabel.text = resultLabel(forGameState: gameState)
            }
        }

        rockButton.isEnabled = !gameState.shouldLockSelection
        paperButton.isEnabled = !gameState.shouldLockSelection
        scissorButton.isEnabled = !gameState.shouldLockSelection
        UIView.animate(springDuration: StateChangeAnimationDuration) { [self] in
            buttonStack.layer.opacity = gameState.shouldLockSelection ? Float(InputButtonsLockOpacity) : 1.0
            self.backgroundColor = backgroundColor(forGameState: gameState)
        }
    }

    private func label(forHand hand: Hand) -> String {
        switch hand {
        case .none:
            "🤔"
        case .rock:
            "🪨"
        case .paper:
            "📄"
        case .scissor:
            "✂️"
        }
    }
    
    private func resultLabel(forGameState gameState: GameState) -> String {
        if gameState.didWin {
            return "🎉"
        } else if gameState.didEnd { // Lost
            return "😞"
        } else { // On-going
            return ""
        }
    }
    
    private func backgroundColor(forGameState gameState: GameState) -> UIColor {
        if gameState.didWin {
            return SuccessBackgroundColor
        } else if gameState.didEnd { // Lost
            return ErrorBackgroundColor
        } else { // On-going
            return NeutralBackgroundColor
        }
    }
}

extension UILabel {
    private static let DefaultAnimationTimeInterval = 0.3
    private static let AnimationScaleDownConstant = 0.8
    private static let WiggleAnimationDuration = 0.1
    private static let WiggleAnimationAngle = CGFloat.pi / 30.0

    func setAnimatedText(_ newText: String, duration: TimeInterval = DefaultAnimationTimeInterval, wiggle: Bool = false) {
        guard self.text != newText else {
            return
        }

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: UILabel.AnimationScaleDownConstant, y: UILabel.AnimationScaleDownConstant)
        }

        animator.addCompletion { _ in
            self.text = newText
            self.alpha = 1.0

            UIView.animate(springDuration: duration) {
                self.alpha = 1.0
                self.transform = CGAffineTransform.identity
            }

            if wiggle {
                self.wiggleAnimation()
            }
        }

        animator.startAnimation()
    }

    private func wiggleAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = UILabel.WiggleAnimationDuration
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.fromValue = -UILabel.WiggleAnimationAngle
        animation.toValue = UILabel.WiggleAnimationAngle
        
        self.layer.add(animation, forKey: "wiggleAnimation")
    }
}
