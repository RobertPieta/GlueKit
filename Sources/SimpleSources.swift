//
//  SimpleSources.swift
//  GlueKit
//
//  Created by Károly Lőrentey on 2015-11-30.
//  Copyright © 2015 Károly Lőrentey. All rights reserved.
//

extension SourceType {
    /// Returns a source that never fires.
    public static func empty() -> AnySource<Value> {
        return NeverSource<Value>().anySource
    }

    /// Returns a source that never fires.
    public static func never() -> AnySource<Value> {
        return NeverSource<Value>().anySource
    }
}

class NeverSource<Value>: _AbstractSource<Value> {
    override func add<Sink: SinkType>(_ sink: Sink) -> Bool where Sink.Value == Value {
        // Do nothing.
        return false
    }

    override func remove<Sink: SinkType>(_ sink: Sink) -> Bool where Sink.Value == Value {
        // Do nothing.
        return false
    }
}

extension SourceType {
    /// Returns a source that fires exactly once with the given value, then never again.
    public static func just(_ value: Value) -> AnySource<Value> {
        return JustSource(value).anySource
    }
}

class JustSource<Value>: _AbstractSource<Value> {
    private var value: Value

    init(_ value: Value) {
        self.value = value
        super.init()
    }

    override func add<Sink: SinkType>(_ sink: Sink) -> Bool where Sink.Value == Value {
        sink.receive(value)
        return false
    }

    override func remove<Sink: SinkType>(_ sink: Sink) -> Bool where Sink.Value == Value {
        // Do nothing.
        return false
    }
}
