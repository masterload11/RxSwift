//
//  Lock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol Lock {
    func lock()
    func unlock()
}

/**
Simple wrapper for spin lock.
*/
class SpinLock {
    private var _lock = OS_SPINLOCK_INIT
    
    init() {
        
    }

    func lock() {
        if #available(iOS 8.0, *) {
            OSSpinLockLock(&_lock)
        }
    }

    func unlock() {
        if #available(iOS 8.0, *) {
            OSSpinLockUnlock(&_lock)
        }
    }
    
    func performLocked(@noescape action: () -> Void) {
        if #available(iOS 8.0, *) {
            OSSpinLockLock(&_lock)
            action()
            OSSpinLockUnlock(&_lock)
        } else {
            action()
        }
    }
    
    func calculateLocked<T>(@noescape action: () -> T) -> T {
        if #available(iOS 8.0, *) {
            OSSpinLockLock(&_lock)
            let result = action()
            OSSpinLockUnlock(&_lock)
            return result
        } else {
            return action()
        }
    }

    func calculateLockedOrFail<T>(@noescape action: () throws -> T) throws -> T {
        if #available(iOS 8.0, *) {
            OSSpinLockLock(&_lock)
            defer {
                OSSpinLockUnlock(&_lock)
            }
            let result = try action()
            return result
        } else {
            return try action()
        }
    }
}

extension NSRecursiveLock : Lock {
    func performLocked(@noescape action: () -> Void) {
        if #available(iOS 8.0, *) {
            self.lock()
            action()
            self.unlock()
        } else {
            action()
        }
    }
    
    func calculateLocked<T>(@noescape action: () -> T) -> T {
        if #available(iOS 8.0, *) {
            self.lock()
            let result = action()
            self.unlock()
            return result
        } else {
            return action()
        }
    }
    
    func calculateLockedOrFail<T>(@noescape action: () throws -> T) throws -> T {
        if #available(iOS 8.0, *) {
            self.lock()
            defer {
            self.unlock()
            }
            let result = try action()
            return result
        } else {
            return try action()
        }
    }
}

/*
let RECURSIVE_MUTEX = _initializeRecursiveMutex()

func _initializeRecursiveMutex() -> pthread_mutex_t {
    var mutex: pthread_mutex_t = pthread_mutex_t()
    var mta: pthread_mutexattr_t = pthread_mutexattr_t()

    pthread_mutex_init(&mutex, nil)
    pthread_mutexattr_init(&mta)
    pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(&mutex, &mta)

    return mutex
}

extension pthread_mutex_t {
    mutating func lock() {
        pthread_mutex_lock(&self)
    }

    mutating func unlock() {
        pthread_mutex_unlock(&self)
    }
}
*/