//
//  RTCConnection+Delegate.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 03/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import WebRTC

/// RTCPeerConnectionDelegate
extension RTCConnection: RTCPeerConnectionDelegate {

    // MARK:
    // MARK: State

    /** Called when the SignalingState changed. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        signalingState = stateChanged
        
        let state: String

        switch stateChanged {
        case .stable: state = "stable"
        case .haveLocalOffer, .haveLocalPrAnswer: state = "have local offer"
        case .haveRemoteOffer, .haveRemotePrAnswer: state = "have remote offer"
        case .closed: state = "closed"
        }

        Log.info(.rtc, "Peer connection state: \(state)")
    }
    
    // MARK:
    // MARK: Negotiate

    /** Called when negotiation is needed, for example ICE has restarted. */
    internal func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        Log.info(.rtc, "Peer connection should negotiate")
    }
    
    // MARK:
    // MARK: Stream
    
    /** Called when media is received on a new stream from remote peer. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        Log.info(.rtc, "Peer connection add stream: \(stream.streamId)")
    }
    
    /** Called when a remote peer closes a stream. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        Log.info(.rtc, "Peer connection remove stream: \(stream.streamId)")
    }
    
    // MARK:
    // MARK: Ice

    /** Called any time the IceConnectionState changes. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        let state: String

        switch newState {
        case .new: state = "new"
        case .checking: state = "checking"
        case .connected: state = "connected"
        case .completed: state = "completed"
        case .failed: state = "failed"
        case .disconnected: state = "disconnected"
        case .closed: state = "closed"
        case .count: state = "count"
        }

        Log.info(.rtc, "Peer connection ice connection state: \(state)")
    }

    /** Called any time the IceGatheringState changes. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        let state: String

        switch newState {
        case .new:
            state = "new"
        case .gathering:
            state = "gathering"
        case .complete:
            state = "complete at \(Date())"

            guard let local = peerConnection.localDescription else {
                localSDPCompletion?(.failed(Errors.failedToGetLocalSDP))

                return
            }
            
            /// Now send RTC:New
            localSDPCompletion?(.success(local))

            popIceCandidates()
        }

        Log.info(.rtc, "Peer connection ice gathering state: \(state)")
    }

    /** New ice candidate has been found. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        Log.info(.rtc, "Peer connection generated ice candidate: \(candidate.sdpMid ?? "")")
        
        // Wait before add candidate is complete gathering
        insert(candidate)
    }

    /** Called when a group of local Ice candidates have been removed. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        Log.info(.rtc, "Peer connection removed ice candidates: \(candidates.count)")

        remove(candidates)
    }

    // MARK:
    // MARK: Data Channel
    
    /** New data channel has been opened. */
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        Log.info(.rtc, "Peer connection opened channel: \(dataChannel.channelId)")
    }
}
