//
//  RTCConnection.swift
//  NexmoConversation
//
//  Created by May Ben Arie on 9/27/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import WebRTC

/// RTC Manager
internal class RTCConnection: NSObject {

    internal typealias LocalSDPResult = Result<RTCSessionDescription>
    internal typealias RemoteSDPResult = Result<Void>

    // MARK:
    // MARK: Enum
    
    /// RTC Error
    ///
    /// - failedToGetLocalSDP: failed to read local SDP
    /// - failedToSetLocalSDP: failed to set new local SDP
    /// - failedToCreateOffer: failed to get offer
    internal enum Errors: Error {
        case failedToGetLocalSDP
        case failedToSetLocalSDP
        case failedToCreateOffer
    }

    // MARK:
    // MARK: Properties
    
    /// Connection Factory
    private let factory = RTCConnectionFactory()
    
    /// Non processed ice candidates
    internal var iceCandidates = [RTCIceCandidate]()
    
    /// Response from local SDP
    internal var localSDPCompletion: ((LocalSDPResult) -> Void)?
   
    /// Connection
    internal lazy var peerConnection: RTCPeerConnection = { return self.factory.connection(with: self) }()

    // MARK:
    // MARK: Initializers

    internal override init() {
        super.init()
        
        setup()
    }

    // MARK:
    // MARK: Setup

    private func setup() {
        connectionSetup()

        switch ConversationClient.configuration.logLevel {
        case .error: RTCSetMinDebugLogLevel(.error)
        case .warning: RTCSetMinDebugLogLevel(.error)
        case .info: RTCSetMinDebugLogLevel(.error)
        case .none: break
        }
    }
    
    private func connectionSetup() {
        // start connection
        guard peerConnection.signalingState == .closed else { return }

        peerConnection.close()

        peerConnection = factory.connection(with: self)
    }

    // MARK:
    // MARK: SDP

    /// Create local SDP and set it as the local description
    internal func setLocalSDP(_ completion: @escaping ((LocalSDPResult) -> Void)) {
        Log.info(.rtc, "Creating local SDP")
        
        connectionSetup()
        
        localSDPCompletion = completion
        
        // Create offer from media type
        peerConnection.offer(for: factory.constraints, completionHandler: { sdp, error in
            guard let sdp = sdp, error == nil else {
                Log.warn(.rtc, "Failed to create an offer")
                completion(.failed(Errors.failedToCreateOffer))

                return
            }

            self.peerConnection.setLocalDescription(sdp, completionHandler: { error in
                guard error == nil else {
                    Log.warn(.rtc, "Failed to set local SDP")
                    completion(.failed(Errors.failedToSetLocalSDP))

                    return
                }
                    
                Log.info(.rtc, "Set local SDP")
                // we need to wait for the ice candidate to complete. don't send the sdp here!
            })
        })
    }
    
    /// Set remote SDP
    internal func setRemoteSDP(_ sdp: String, _ completion: @escaping ((RemoteSDPResult) -> Void)) {
        Log.info(.rtc, "Setting remote SDP")

        let sdp = RTCSessionDescription(type: .prAnswer, sdp: sdp)

        peerConnection.setRemoteDescription(sdp, completionHandler: { error in
            if let error = error {
                Log.warn(.rtc, "Failed to set remote SDP")
                completion(.failed(error))

                return
            }
            
            Log.info(.rtc, "Set remote SDP")

            completion(.success(()))
            
            self.popIceCandidates()
        })
    }

    // MARK:
    // MARK: Connection
    
    /// Stop close connection
    internal func close() {
        Log.info(.rtc, "Peer connection closing")

        peerConnection.stopRtcEventLog()
        peerConnection.close()
        peerConnection.delegate = nil
        iceCandidates.removeAll()
    }
}
