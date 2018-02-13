//
//  Event.swift
//  NexmoConversation
//
//  Created by James Green on 06/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation
import Gloss

/// Event model
@objc(NXMEvent)
public class Event: NSObject {
    
    // MARK:
    // MARK: Enum
    
    /// Event type
    ///
    /// - memberInvited: invited
    /// - memberJoined: joined
    /// - memberLeft: lefted
    /// - textTypingOn: is typing
    /// - textTypingOff: is not typing
    /// - eventDelete: deleted event
    /// - text: text
    /// - textDelivered: text delivered
    /// - textSeen: text seen
    /// - image: image
    /// - imageDelivered: image delivered
    /// - imageSeen: image seen
    /// - rtcNew: new session
    /// - rtcOffer: offer model
    /// - rtcIce: ICE model
    /// - rtcAnswer: answer model
    /// - rtcTerminate: call terminated
    /// - memberMedia: member media
    /// - audioPlay: audio play
    /// - audioPlayDone: audio play done
    /// - audioSay: audio say
    /// - audioSayDone: audio say done
    /// - audioDtmf: audio dtmf
    /// - audioRecord: audio record
    /// - audioRecordDone: audio record done
    /// - audioUnmute: audio unmute
    /// - audioUnearmuff: audio unearmuff
    /// - audioSpeakingOff: audio speaking off
    /// - audioMute: audio mute
    /// - audioEarmuffed: audio earmuffed
    /// - audioSpeakingOn: audio speaking on
    public enum EventType: String, Equatable {
        case memberInvited = "member:invited"
        case memberJoined = "member:joined"
        case memberLeft = "member:left"
        case textTypingOn = "text:typing:on"
        case textTypingOff = "text:typing:off"
        case eventDelete = "event:delete"
        case text = "text"
        case textDelivered = "text:delivered"
        case textSeen = "text:seen"
        case image = "image"
        case imageDelivered = "image:delivered"
        case imageSeen = "image:seen"
        case rtcNew = "rtc:new"
        case rtcOffer = "rtc:offer"
        case rtcIce = "rtc:ice"
        case rtcAnswer = "rtc:answer"
        case rtcTerminate = "rtc:terminate"
        case memberMedia = "member:media"
        case audioPlay = "audio:play"
        case audioPlayDone = "audio:play:done"
        case audioSay = "audio:say"
        case audioSayDone = "audio:say:done"
        case audioDtmf = "audio:dtmf"
        case audioRecord = "audio:record"
        case audioRecordDone = "audio:record:done"
        case audioUnmute = "audio:mute:off"
        case audioUnearmuff = "audio:earmuff:off"
        case audioSpeakingOff = "audio:speaking:off"
        case audioMute = "audio:mute:on"
        case audioEarmuffed = "audio:earmuff:on"
        case audioSpeakingOn = "audio:speaking:on"
        case sipHangUp = "sip:hangup"
        
        // MARK:
        // MARK: Helper
        
        internal var toInt32: Int32 {
            switch self {
            case .memberInvited: return 1
            case .memberJoined: return 2
            case .memberLeft: return 3
            case .textTypingOn: return 4
            case .textTypingOff: return 5
            case .text: return 6
            case .eventDelete: return 7
            case .textDelivered: return 8
            case .image: return 9
            case .imageDelivered: return 10
            case .textSeen: return 11
            case .imageSeen: return 12
            case .rtcNew: return 13
            case .rtcOffer: return 14
            case .rtcIce: return 15
            case .rtcAnswer: return 16
            case .rtcTerminate: return 17
            case .memberMedia: return 18
            case .audioPlay: return 19
            case .audioPlayDone: return 20
            case .audioSay: return 21
            case .audioSayDone: return 22
            case .audioDtmf: return 23
            case .audioRecord: return 24
            case .audioRecordDone: return 25
            case .audioUnmute: return 26
            case .audioUnearmuff: return 27
            case .audioSpeakingOff: return 28
            case .audioMute: return 29
            case .audioEarmuffed: return 30
            case .audioSpeakingOn: return 31
            case .sipHangUp: return 32
            }
        }
        
        internal static func fromInt32(_ from: Int32) -> EventType? {
            switch from {
            case 1: return .memberInvited
            case 2: return .memberJoined
            case 3: return .memberLeft
            case 4: return .textTypingOn
            case 5: return .textTypingOff
            case 6: return .text
            case 7: return .eventDelete
            case 8: return .textDelivered
            case 9: return .image
            case 10: return .imageDelivered
            case 11: return .textSeen
            case 12: return .imageSeen
            case 13: return .rtcNew
            case 14: return .rtcOffer
            case 15: return .rtcIce
            case 16: return .rtcAnswer
            case 17: return .rtcTerminate
            case 18: return .memberMedia
            case 19: return .audioPlay
            case 20: return .audioPlayDone
            case 21: return .audioSay
            case 22: return .audioSayDone
            case 23: return .audioDtmf
            case 24: return .audioRecord
            case 25: return .audioRecordDone
            case 26: return .audioUnmute
            case 27: return .audioUnearmuff
            case 28: return .audioSpeakingOff
            case 29: return .audioMute
            case 30: return .audioEarmuffed
            case 31: return .audioSpeakingOn
            case 32: return .sipHangUp
            default: return nil
            }
        }
    }
    
    // MARK:
    // MARK: Body
    
    /// Wrapper around of Event Body
    internal enum Body {
        
    }
    
    // MARK:
    // MARK: Properties

    /// ID of event
    internal var id: String
    
    /// user who trigged the event
    internal var from: String?
    
    /// event sent to
    internal var to: String?
    
    /// body
    internal var body: JSON?
    
    /// time of event
    internal var timestamp: Date
    
    /// conversation id
    internal var cid: String
    
    // MARK:
    // MARK: Extra
    
    /// Type of event
    internal let type: EventType
    
    /// state of event 
    internal var state: EventState?
    
    /// generated transaction id of event used for draft events
    internal var tid: String?
    
    // MARK:
    // MARK: Initializers

    internal init(cid: String, id: String, from: String?, to: String?, timestamp: Date, type: EventType) {
        self.cid = cid
        self.from = from
        self.to = to
        self.timestamp = timestamp
        self.id = id
        self.type = type
        self.tid = nil
    }
    
    internal init(cid: String, type: EventType, memberId: String, body: JSON?=nil) {
        self.timestamp = Date()
        self.from = memberId
        self.cid = cid
        self.id = "0"
        self.type = type
        self.body = body
        self.tid = nil
    }

    internal init?(conversationUuid: String?=nil, type: EventType?=nil, json: JSON) {
        self.from = "from" <~~ json
        self.to = "to" <~~ json

        // TODO: Anything that from conversation service is conversation_id, but if it goes via CAPI(socket) then it becomes cid.
        guard let cid: String = conversationUuid ?? ("cid" <~~ json ?? "conversation_id" <~~ json) else { return nil }
        self.cid = cid

        guard let body: JSON = "body" <~~ json else { return nil }
        self.body = body

        guard let formatter = DateFormatter.ISO8601,
            let timestamp: Date = Decoder.decode(dateForKey: "timestamp", dateFormatter: formatter)(json) else {
            return nil
        }
        
        self.timestamp = timestamp
        self.state = "state" <~~ json

        guard let id: Int32 = "id" <~~ json else { return nil }
        guard let type: EventType = type ?? "type" <~~ json else { return nil }
        
        self.id = "\(id)"
        self.type = type
        self.tid = nil
        
        if let tid: AnyObject = "tid" <~~ body {
            if let str = tid as? String {
                self.tid = str
            } else if let num = tid as? NSNumber {
                // this 'shouldn't' occur in the real world, but during testing I received numbers back. possibly due to sending Ints before changing eventId to String, and residual data still existing.
                let intValue = num.int64Value
                self.tid = "\(intValue)"
            }
        }
    }
    
    internal init(conversationUuid: String, type: EventType, eventId: String, memberId: String) {
        // TODO: Anything that from conversation service is conversation_id, but if it goes via CAPI(socket) then it becomes cid.
        
        self.to = ""
        self.from = memberId
        self.cid = conversationUuid
        self.body = ["event_id": eventId]
        self.timestamp = Date()
        self.id = eventId
        self.type = type
    }
    
    // MARK:
    // MARK: Body
    
    /// Unwrap body
    internal func model<T: Gloss.JSONDecodable>() -> T? {
        guard let body = body else { return nil }
        
        return T(json: body)
    }
}

// MARK:
// MARK: Compare

/// Compare EventType
/// :nodoc:
public func ==(lhs: Event.EventType, rhs: Event.EventType) -> Bool {
    switch (lhs, rhs) {
    case (.memberInvited, .memberInvited): return true
    case (.memberJoined, .memberJoined): return true
    case (.memberLeft, .memberLeft): return true
    case (.textTypingOn, .textTypingOn): return true
    case (.textTypingOff, .textTypingOff): return true
    case (.eventDelete, .eventDelete): return true
    case (.text, .text): return true
    case (.textDelivered, .textDelivered): return true
    case (.textSeen, .textSeen): return true
    case (.image, .image): return true
    case (.imageDelivered, .imageDelivered): return true
    case (.imageSeen, .imageSeen): return true
    case (.rtcNew, .rtcNew): return true
    case (.rtcOffer, .rtcOffer): return true
    case (.rtcIce, .rtcIce): return true
    case (.rtcAnswer, .rtcAnswer): return true
    case (.rtcTerminate, .rtcTerminate): return true
    case (.memberMedia, .memberMedia): return true
    case (.audioPlay, .audioPlay): return true
    case (.audioPlayDone, .audioPlayDone): return true
    case (.audioSay, .audioSay): return true
    case (.audioSayDone, .audioSayDone): return true
    case (.audioDtmf, .audioDtmf): return true
    case (.audioRecord, .audioRecord): return true
    case (.audioRecordDone, .audioRecordDone): return true
    case (.audioUnmute, .audioUnmute): return true
    case (.audioUnearmuff, .audioUnearmuff): return true
    case (.audioSpeakingOff, .audioSpeakingOff): return true
    case (.audioMute, .audioMute): return true
    case (.audioEarmuffed, .audioEarmuffed): return true
    case (.audioSpeakingOn, .audioSpeakingOn): return true
    case (.sipHangUp, .sipHangUp): return true
    case (.imageSeen, _),
         (.memberInvited, _),
         (.memberJoined, _),
         (.memberLeft, _),
         (.textTypingOn, _),
         (.textTypingOff, _),
         (.eventDelete, _),
         (.text, _),
         (.textDelivered, _),
         (.textSeen, _),
         (.image, _),
         (.imageDelivered, _),
         (.rtcNew, _),
         (.rtcOffer, _),
         (.rtcIce, _),
         (.rtcAnswer, _),
         (.rtcTerminate, _),
         (.memberMedia, _),
         (.audioPlay, _),
         (.audioPlayDone, _),
         (.audioSay, _),
         (.audioSayDone, _),
         (.audioDtmf, _),
         (.audioRecord, _),
         (.audioRecordDone, _),
         (.audioUnmute, _),
         (.audioUnearmuff, _),
         (.audioSpeakingOff, _),
         (.audioMute, _),
         (.audioEarmuffed, _),
         (.audioSpeakingOn, _),
         (.sipHangUp, _): return false
    }
}
