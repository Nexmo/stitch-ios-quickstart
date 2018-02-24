//
//  Signal.swift
//
//  Created by James Green on 11/07/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

// TODO Make thread safe: add locking, and add a mechanism to call on UI thread.

import Foundation

/// Base Signal class
public class SignalBase {
    
    // MARK:
    // MARK: Handler
    
    /// Add listener
    internal func subscribe(_ target: AnyObject, selector: Selector) -> SignalReference {
        fatalError("This method must be overriden by the subclass")
    }
    
    internal func removeSubscriber(_ ref: SignalReference) {
        fatalError("This method must be overriden by the subclass")
    }
}

/**
 The main signal class which uses generics to convey the parameter types of the signal
 */
public class Signal<T>: SignalBase {
    
    // MARK:
    // MARK: Properties
    
    /* Here we maintain a list of both types of handler. */
    private var selectors = [SignalReference: SignalSelectorWrapper]()
    private var handlers = [SignalReference: SignalHandlerWrapper]()
    private var closures = [SignalReference: SignalClosureWrapper]()
    
    /// Current value of signal
    internal var value: T?
    
    // MARK:
    // MARK: Subscribe
    
    /**
     Add a "selector" handler.
     
     - parameter target:   The target object.
     - parameter selector: The selector to be called on the target object.
     
     - returns: A reference that can be used to remove the handler.
     */
    @discardableResult internal override func subscribe(_ target: AnyObject, selector: Selector) -> SignalReference {
        fatalError("implement logic in concrete class") // Interop with ObjC is not currently working. The reflection in emit() cannot cope with all the types it can encounter.
        
        /* Add the handler. */
//        let ref = SignalHandlerRef(parent: self)
//        let wrapper = SignalSelectorWrapper(onUIThread: Thread.isMainThread, target: target, selector: selector)
//        selectors.updateValue(wrapper, forKey: ref)
//        return ref
    }

    /**
     Add a "swift" handler that is a class method.
     
     - parameter target:  The target object.
     - parameter handler: The handler method.
     
     - returns: A reference that can be used to remove the handler.
     */
    @discardableResult internal func subscribe<U: AnyObject>(_ target: U, handler: @escaping (U) -> (T) -> Void) -> SignalReference {
        /* Add the handler. */
        let ref = SignalReference(parent: self)
        let wrapper = SignalHandlerContainer(onUIThread: Thread.isMainThread, target: target, handler: handler)
        handlers.updateValue(wrapper, forKey: ref)
        
        return ref
    }

    /**
     Add a "swift" handler that is a closure.
     
     - parameter closure: The closure.
     
     - returns: A reference that can be used to remove the handler.
     */
    @discardableResult public func subscribe(onSuccess: ((T) -> Void)?=nil, onError: ((Error) -> Void)?=nil) -> SignalReference {
        /* Add the handler. */
        let ref = SignalReference(parent: self)
        let closure: ((T) -> Void) = onSuccess ?? { _ in }
        let wrapper = SignalClosureContainer(onUIThread: Thread.isMainThread, closure: closure)
        closures.updateValue(wrapper, forKey: ref)
        
        return ref
    }
    
    /**
     Remove this handler from signal.
     
     - parameter ref: The reference returned by the original call to subscribe().
     */
    public override func removeSubscriber(_ ref: SignalReference) {
        selectors.removeValue(forKey: ref)
        handlers.removeValue(forKey: ref)
        closures.removeValue(forKey: ref)
    }
    
    // MARK:
    // MARK: Emit
    
    /**
     Raise/trigger the signal.
     
     - parameter data: The signal data.
     */
    internal func emit(_ data: T) {
        value = data
        
        if !selectors.isEmpty {
            /* Extract the parameters into something more suitable for selectors. */
            var parameters = [AnyObject?]()
            let mirror = Mirror(reflecting: data)
            
            for param in mirror.children {
                let value = param.value
                if value is Protocol {
                    let object = value as! Protocol
                    parameters.append(object)
                } else {
                    let valueMirror = Mirror(reflecting: value)
                    let displayStyle = valueMirror.displayStyle
                    if displayStyle == Mirror.DisplayStyle.enum {
                        // TODO Get the rawValue as an Int. Couldn't work out how to do this,
                        // So at the moment we cannot pass enums through to selectors, and therefore we are
                        // not able to support Objective C.
                        parameters.append(nil)
                    } else {
                        assert(false) // Unsupported parameter type.
                    }
                }
            }
            
            /* Call selector handlers. */
            var disposedSelectors = [SignalReference]()
            for item in selectors {
                let wrapper = item.1
                
                /* See if target has been garbage collected. */
                if wrapper.isTargetGarbageCollected() {
                    disposedSelectors.append(item.0)
                    continue
                }
                
                /* Invoke selector. */
                // TODO Should be able to do a helpful runtime check that the selector arguments types match those of T.
                wrapper.invoke(parameters: parameters)
            }
            
            /* Tidy away any disposed selector handlers. */
            for item in disposedSelectors {
                selectors.removeValue(forKey: item)
            }
        }
        
        /* Call swift handlers. */
        if !handlers.isEmpty {
            var disposedHandlers = [SignalReference]()
            for item in handlers {
                let wrapper = item.1
                
                /* See if target has been garbaged collected. */
                if wrapper.isTargetGarbageCollected() {
                    disposedHandlers.append(item.0)
                    continue
                }
                
                /* Invoke handler. */
                wrapper.invoke(data)
            }
            
            /* Tidy away any disposed swift handlers. */
            for item in disposedHandlers {
                handlers.removeValue(forKey: item)
            }
        }
        
        /* Call closures. */
        if !closures.isEmpty {
            var disposedClosures = [SignalReference]()
            for item in closures {
                let wrapper = item.1
                
                /* See if target has been garbaged collected. */
                if wrapper.isTargetGarbageCollected() {
                    disposedClosures.append(item.0)
                    continue
                }
                
                /* Invoke handler. */
                wrapper.invoke(data)
            }
            
            /* Tidy away any disposed swift handlers. */
            for item in disposedClosures {
                closures.removeValue(forKey: item)
            }
        }
    }
}
