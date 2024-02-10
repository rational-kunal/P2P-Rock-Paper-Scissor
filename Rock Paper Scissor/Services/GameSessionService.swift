//
//  GameSessionService.swift
//  Rock Paper Scissor
//
//  Created by Kunal Kamble on 04/02/24.
//

import Foundation
import MultipeerConnectivity
import OSLog

fileprivate let RPS_SERVICE_TYPE = "rps-game"
fileprivate let RPS_INTENT = "rps-game-intent"

fileprivate let logger = Logger(subsystem: "GameSession", category: "Info")

protocol GameSessionManageDelegate {
    func didUpdate(gameState: GameState)
}

class GameSessionService: NSObject {
    private lazy var peerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    private lazy var session: MCSession = {
        let mcSession = MCSession(peer: peerID)
        mcSession.delegate = self
        return mcSession
    }()
    
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    
    private var nearByServiceBrowser: MCNearbyServiceBrowser?
    
    var delegate: GameSessionManageDelegate?
    
    private var gameState = GameState(sessionState: .none, ourHand: .none, theirHand: .none)

    func host() {
        guard gameState.sessionState == .none else {
            logger.error("Unexpected current state \(self.gameState.sessionState)")
            return
        }
        
        gameState.sessionState = .hosting
        notifyGameStateUpdate()

        let advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: [RPS_INTENT: RPS_INTENT],
            serviceType: RPS_SERVICE_TYPE)
        advertiserAssistant.delegate = self
        advertiserAssistant.startAdvertisingPeer()
        self.advertiserAssistant = advertiserAssistant
        logger.info("Started advertising peer")
    }
    
    func join() {
        guard gameState.sessionState == .none else {
            logger.error("Unexpected current state \(self.gameState.sessionState)")
            return
        }
        
        gameState.sessionState = .joining
        notifyGameStateUpdate()
        
        let serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: RPS_SERVICE_TYPE)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        self.nearByServiceBrowser = serviceBrowser
        logger.info("Started looking for peers")
    }
    
    func startNewGame() {
        gameState.startNewGame()
        delegate?.didUpdate(gameState: gameState)
    }
    
    func select(hand: Hand) {
        guard let handData = hand.toData() else {
            fatalError("TODO: Error handling")
        }

        gameState.ourHand = hand
        send(data: handData)
        notifyGameStateUpdate()
    }
    
    private func send(data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            logger.error("Unable to send data with error \(error)")
        }
    }
    
    private func notifyGameStateUpdate() {
        DispatchQueue.main.async { [self] in
            delegate?.didUpdate(gameState: gameState)
        }
    }
}

extension GameSessionService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if (state == .connected) {
            gameState.sessionState = .connected
            notifyGameStateUpdate()
            logger.info("Connected to \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        logger.info("Received \(data.count) from \(peerID.displayName)")

        if let receivedHand = Hand.from(data: data) {
            gameState.theirHand = receivedHand
            notifyGameStateUpdate()
        } else {
            fatalError()
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // No-op
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // No-op
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // No-op
    }
}

extension GameSessionService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        logger.info("Did recieve invitation from \(peerID)")
        invitationHandler(true, session)
        self.nearByServiceBrowser?.stopBrowsingForPeers()
    }
}

extension GameSessionService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        logger.info("Found peer \(peerID)")
        
        if (info?[RPS_INTENT]) != nil {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 2.0)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // No-op
    }
}
