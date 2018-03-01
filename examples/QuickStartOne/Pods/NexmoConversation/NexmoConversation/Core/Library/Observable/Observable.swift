//
//  Observable.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 15/02/18.
//  Copyright © 2018 Nexmo. All rights reserved.
//

import Foundation
import RxSwift

/// Observable Type
public protocol ObservableConvertible {
    
    // MARK:
    // MARK: Associated Type
    
    /// Type of elements
    associatedtype E
    
    // MARK:
    // MARK: Properties - Observable
    
    /// :nodoc:
    var rx: RxSwift.Observable<E> { get }
}

/// Observable object interfaces provide a generalized mechanism that represents the result of an operation via subscribing with onSuccess and onError.
public class Observable<Element>: ObservableConvertible {
    
    // MARK:
    // MARK: Typealias
    
    /// Type of elements in sequence.
    public typealias E = Element
    
    // MARK:
    // MARK: Properties - Observable
    
    /// :nodoc:
    public let rx: RxSwift.Observable<E>
    
    // MARK:
    // MARK: Threading
    
    /// Async mainthread of where the result is sent after this point, only to be used for UI
    public var mainThread: NexmoConversation.Observable<E> {
        return NexmoConversation.Observable(rx.observeOnMainThread())
    }
    
    /// Background thread of where the result is sent after this point
    public var backgroundThread: NexmoConversation.Observable<E> {
        return NexmoConversation.Observable(rx.observeOnBackground())
    }
    
    // MARK:
    // MARK: Initializers
    
    internal init(_ observable: RxSwift.Observable<E>) {
        rx = observable
    }
    
    // MARK:
    // MARK: Subscribe
    
    /**
     Subscribes an element handler and an error handler to an observable sequence.
     
     - parameter onSuccess: An Observable calls this method whenever the Observable emits an item. This method takes as a parameter the item emitted by the Observable.
     - parameter onError: An Observable calls this method to indicate that it has failed to generate the expected data or has encountered some other error. It will not make further calls to onSuccess. The onError method takes as its parameter an indication of what caused the error.
     
     @info: `MutableObservable` will never call `onError:` as it does not produce a errors. All streams of values will be sent to `onSuccess:`
     */
    public func subscribe(onSuccess: ((E) -> Void)?=nil, onError: ((Error) -> Void)?=nil) {
        rx
         .subscribe(onNext: onSuccess, onError: onError)
         .disposed(by: ConversationClient.instance.disposeBag)
        // used client as the owner so we never have issues with operation not completion
    }
    
    // MARK:
    // MARK: Filter
    
    /**
     Filters the elements of an observable sequence based on a predicate.
     
     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (E) throws -> Bool) -> NexmoConversation.Observable<E> {
        return NexmoConversation.Observable(rx.filter(predicate))
    }
    
    // MARK:
    // MARK: Reduce
    
    /**
     Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.
     
     - parameter seed: The initial accumulator value.
     - parameter accumulator: A accumulator function to be invoked on each element.
     - returns: An observable sequence containing a single element with the final accumulator value.
     */
    public func reduce<A>(_ seed: A, accumulator: @escaping (A, E) throws -> A) -> NexmoConversation.Observable<A> {
        return NexmoConversation.Observable<A>(rx.reduce(seed, accumulator: accumulator))
    }
    
    /**
     Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.
     
     - parameter seed: The initial accumulator value.
     - parameter accumulator: A accumulator function to be invoked on each element.
     - parameter mapResult: A function to transform the final accumulator value into the result value.
     - returns: An observable sequence containing a single element with the final accumulator value.
     */
    public func reduce<A, R>(_ seed: A, accumulator: @escaping (A, E) throws -> A, mapResult: @escaping (A) throws -> R) -> NexmoConversation.Observable<R> {
        return NexmoConversation.Observable<R>(rx.reduce(seed, accumulator: accumulator, mapResult: mapResult))
    }
    
    // MARK:
    // MARK: Map
    
    /**
     Projects each element of an observable sequence into a new form.
     
     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func map<R>(_ transform: @escaping (E) throws -> R) -> NexmoConversation.Observable<R> {
        return NexmoConversation.Observable<R>(rx.map(transform))
    }
    
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     
     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<O: ObservableConvertible>(_ selector: @escaping (E) -> O) -> NexmoConversation.Observable<O.E> {
        return NexmoConversation.Observable<O.E>(rx.flatMap { selector($0).rx })
    }
}
