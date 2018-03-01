//
//  RTCDevice.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 24/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift

/// Device manager
internal class RTCDevice {

    /// Observable for when device interrupe audio
    internal lazy var audioInterruption: RxSwift.Observable<Notification> = {
        return NotificationCenter.default.rx
            .notification(.AVAudioSessionInterruption)
            .do(onNext: { _ in Log.info(.rtc, "interruption") })
    }()

    /// Observable for when input/output changes
    internal lazy var audioRouteChanged: RxSwift.Observable<AVAudioSessionRouteChangeReason> = {
        return NotificationCenter.default.rx
            .notification(.AVAudioSessionRouteChange)
            .do(onNext: { notification in
                guard let raw = (notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
                    let rawType = AVAudioSessionRouteChangeReason(rawValue: raw) else { return }

                let routes = notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
                let inputs = (routes?.inputs.map { $0.uid } ?? []).joined(separator: " ,")
                let outputs = (routes?.outputs.map { $0.uid } ?? []).joined(separator: " ,")
                let reason: String

                switch rawType {
                case .newDeviceAvailable: reason = "newDeviceAvailable"
                case .oldDeviceUnavailable: reason = "oldDeviceUnavailable"
                case .categoryChange: reason = "categoryChange"
                case .override: reason = "override"
                case .wakeFromSleep: reason = "wakeFromSleep"
                case .noSuitableRouteForCategory: reason = "noSuitableRouteForCategory"
                case .routeConfigurationChange: reason = "routeConfigurationChange"
                default: reason = "unknown"
                }

                Log.info(.rtc, "Route change: \(reason), inputs: \(inputs), outputs: \(outputs)")
            })
            .map { notification -> AVAudioSessionRouteChangeReason? in
                guard let raw = (notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
                    let rawType = AVAudioSessionRouteChangeReason(rawValue: raw) else { return nil }

                return rawType
            }
            .unwrap()
    }()

    /// Checks for audio permission
    internal var hasAudioPermission: Bool {
        guard case AVAudioSessionRecordPermission.granted = AVAudioSession.sharedInstance().recordPermission() else {
            Log.info(.rtc, "App does not have audio permission")

            return false
        }

        return true
    }

    /// Set loudspeaker option
    internal var loudspeaker: Bool = false {
        didSet {
            if loudspeaker {
                _ = try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            } else {
                _ = try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            }
        }
    }

    // MARK:
    // MARK: Initializers

    internal init() {

    }
}
