//
//  NSNotificationCenter Support.swift
//  GlueKit
//
//  Created by Károly Lőrentey on 2015-11-30.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

import Foundation

extension NotificationCenter {
    /// Creates a Source that observes the specified notifications and forwards it to its connected sinks.
    ///
    /// The returned source holds strong references to the notification center and the sender (if any).
    /// The source will only observe the notification while a sink is actually connected.
    ///
    /// @param name The name of the notification to observe.
    /// @param sender The sender of the notifications to observe, or nil for any object. This parameter is nil by default.
    /// @param queue The operation queue on which the source will trigger. If you pass nil, the sinks are run synchronously on the thread that posted the notification. This parameter is nil by default.
    /// @returns A Source that triggers when the specified notification is posted.
    public func sourceForNotification(_ name: String, sender: AnyObject? = nil, queue: OperationQueue? = nil) -> Source<Notification> {
        let mutex = Mutex()
        var observer: NSObjectProtocol? = nil

        let signal = Signal<Notification>(
            start: { signal in
                mutex.withLock {
                    precondition(observer == nil)
                    observer = self.addObserver(forName: NSNotification.Name(rawValue: name), object: sender, queue: queue) { [unowned signal] notification in
                        signal.send(notification)
                    }
                }
            },
            stop: { signal in
                mutex.withLock {
                    precondition(observer != nil)
                    self.removeObserver(observer!)
                    observer = nil
                }
        })

        return signal.source
    }
}
