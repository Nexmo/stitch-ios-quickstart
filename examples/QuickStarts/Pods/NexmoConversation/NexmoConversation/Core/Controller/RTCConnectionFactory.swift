//
//  RTCConnectionFactory.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 19/10/17.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import WebRTC

/// Peer connection factory
internal struct RTCConnectionFactory {
    
    // MARK:
    // MARK: Properties
    
    internal let constraints = RTCMediaConstraints(
        mandatoryConstraints: [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue],
        optionalConstraints: nil
    )
    
    /// Helper to build peer connection, note: SDK crashes if we don't retain object
    private let factory = RTCPeerConnectionFactory()
    
    // MARK:
    // MARK: Factory
    
    /// Build new peer connection
    internal func connection(with delegate: RTCPeerConnectionDelegate) -> RTCPeerConnection {
        Log.info(.rtc, "Creating peer connection")
        
        let stream = self.factory.mediaStream(withStreamId: "ARDAMS")
        stream.addAudioTrack(self.factory.audioTrack(withTrackId: "ARDAMSa0"))
        
        let peerConnection = self.factory.peerConnection(
            with: RTCConfiguration.configuration,
            constraints: self.constraints,
            delegate: delegate
        )
        
        peerConnection.add(stream)
        
        return peerConnection
    }
}
