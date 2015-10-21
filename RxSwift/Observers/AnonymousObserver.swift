//
//  AnonymousObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AnonymousObserver<ElementType> : ObserverBase<ElementType> {
    typealias Element = ElementType
    
    typealias EventHandler = RxEvent<Element> -> Void
    
    private let _eventHandler : EventHandler
    
    init(_ eventHandler: EventHandler) {
#if TRACE_RESOURCES
        AtomicIncrement(&resourceCount)
#endif
        _eventHandler = eventHandler
    }

    override func onCore(event: RxEvent<Element>) {
        return _eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        AtomicDecrement(&resourceCount)
    }
#endif
}
