//
//  RTCConnection+Ice.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 16/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import WebRTC

/// RTCConnection Ice 
extension RTCConnection {

    // MARK:
    // MARK: Ice

    /// Remove and add all candidates to peer connection
    internal func popIceCandidates() {
        /// Only allowed to add candidates when we set remote and completed ice
        guard peerConnection.iceGatheringState == .complete else { return Log.info(.rtc, "Insert ice failed with incorrect gathering state") }
        guard peerConnection.remoteDescription != nil else { return Log.info(.rtc, "Insert ice failed with no remote sdp") }

        Log.info(.rtc, "Inserting ice candidates(\(iceCandidates.count))")

        while let candidate = iceCandidates.popLast() { peerConnection.add(candidate) }
    }

    /// Add new ice candidate
    internal func insert(_ candidate: RTCIceCandidate) {
        iceCandidates.append(candidate)

        popIceCandidates()
    }

    /// Remove pending ice from candidates queue and peer connection
    internal func remove(_ candidates: [RTCIceCandidate]) {
        peerConnection.remove(candidates)

        candidates.forEach { candidate in
            guard let index = self.iceCandidates.index(where: { candidate.sdpMid == $0.sdpMid }) else { return }

            self.iceCandidates.remove(at: index)
        }
    }
}
