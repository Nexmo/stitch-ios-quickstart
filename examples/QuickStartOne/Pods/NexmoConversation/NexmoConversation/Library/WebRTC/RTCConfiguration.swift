//
//  RTCConfiguration.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 16/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import WebRTC

/// RTC Configuration
internal struct RTCConfiguration {

    // MARK:
    // MARK: Configuration

    /// Default configuration for RTC
    internal static var configuration: WebRTC.RTCConfiguration {
        let configuration = WebRTC.RTCConfiguration()
        configuration.tcpCandidatePolicy = .disabled
        configuration.bundlePolicy = .balanced
        configuration.rtcpMuxPolicy = .require
        configuration.continualGatheringPolicy = .gatherOnce
        configuration.keyType = .ECDSA
        configuration.iceConnectionReceivingTimeout = 5
        configuration.iceCheckMinInterval = 5
        
        let hostUrl = "turn:138.68.169.35:3478?transport=tcp"
        Log.info(.rtc, "Ice Server: \(hostUrl)")
        Log.info(.rtc, "RTC config: \(configuration)")
        
        configuration.iceServers = [
            // RTCIceServer(urlStrings: [BaseURL.stun])
            // TODO: TEST Turn servers for access within office
            RTCIceServer(urlStrings: [hostUrl], username: "foo2", credential: "bar")
        ]

        return configuration
    }
}
