//
//  MutableObservable.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 16/02/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Just like a `Observable` class but observers can subscribe to the subject to receive the initial value and all subsequent notifications.
public class MutableObservable<Element>: NexmoConversation.Observable<Element> {
    
    // MARK:
    // MARK: Typealias
    
    /// Type of elements in sequence.
    public typealias E = Element
    
    // MARK:
    // MARK: Value
    
    /// Gets current value inside observable.
    ///
    /// Whenever a new value is set, all the observers are notified of the change.
    public var value: E { return subject.value }
    
    // MARK:
    // MARK: Properties - Observable
    
    /// Observers can subscribe to the subject to receive the initial value  all subsequent notifications.
    internal let subject: RxSwift.Variable<E>
    
    // MARK:
    // MARK: Initializers
    
    internal init(_ behaviorSubject: RxSwift.Variable<E>) {
        subject = behaviorSubject
        
        // converted to driver so it doesn't fail and dispose
        super.init(behaviorSubject.asDriver().asObservable())
    }
    
    // MARK:
    // MARK: Subscribe
    
    /**
     Subscribes an element handler to a observable sequence that does not complete.
     
     - parameter onNext: An Observable calls this method whenever the Observable emits any items. This method takes as a parameter the item emitted by the Observable.
     */
    public func subscribe(_ onNext: @escaping ((E) -> Void)) {
        rx
         .subscribe(onNext: onNext)
         .disposed(by: ConversationClient.instance.disposeBag)
    }
}
