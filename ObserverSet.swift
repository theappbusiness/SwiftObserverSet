/*
 ObserverSet is distributed under a BSD license, as listed below.
 
 Copyright (c) 2015, Michael Ash
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
 Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// Modified by Kane Cheshire on 21 February 2017

import Dispatch

/// A reference to an entry in the list of observers. Use this to remove an observer.
public class ObserverSetEntry<Parameters> {

	fileprivate var isExpired: Bool { false }

	fileprivate func call(_ parameters: Parameters) {
		// overridden
	}
}

private class ObserverSetEntryImpl<ObserverType: AnyObject, Parameters>: ObserverSetEntry<Parameters> {
	
	typealias ObserverCallback = (ObserverType) -> (Parameters) -> Void
	
	private(set) weak var observer: ObserverType?
	private let callBack: ObserverCallback
	private let queue: DispatchQueue?
	
	override var isExpired: Bool { observer == nil }
	
	init(queue: DispatchQueue?, observer: ObserverType, callBack: @escaping ObserverCallback) {
		self.queue = queue
		self.observer = observer
		self.callBack = callBack
	}
	
	override func call(_ parameters: Parameters) {
		if let observer = observer {
			let callBack = self.callBack(observer)
			if let queue = queue {
				queue.async {
					callBack(parameters)
				}
			} else {
				callBack(parameters)
			}
		}
	}
	
}

/// A set of observers that can be notified of certain actions. A more Swift-like version of NSNotificationCenter.
open class ObserverSet<Parameters> {
	
	// MARK: - Private properties
	
	private var entries: [ObserverSetEntry<Parameters>] = []
	
	// MARK: - Initialisers
	
	/**
	Creates a new instance of an observer set.
	
	- returns: A new instance of an observer set.
	*/
	public init() {}
	
	// MARK: - Public functions
	
	/**
	Adds a new observer to the set.
	
	- parameter queue: The queue to call the function on when the notification is delivered. If nil (the default) it will be delivered on the same queue the notification was sent.
	- parameter observer: The object that is to be notified.
	- parameter callBack: The function to call on the observer when the notification is to be delivered.
	
	- returns: An entry in the list of observers, which can be used later to remove the observer.
	*/
	@discardableResult
	open func add<ObserverType: AnyObject>(queue: DispatchQueue? = nil, _ observer: ObserverType, _ callBack: @escaping (ObserverType) -> (Parameters) -> Void) -> ObserverSetEntry<Parameters> {
		let entry = ObserverSetEntryImpl<ObserverType, Parameters>(queue: queue, observer: observer, callBack: callBack)
		synchronized {
			self.entries.append(entry)
		}
		return entry
	}
	
	/**
	Adds a new function (or closure) to call when a notification is to be delivered.
	This callback will be notified until it is removed by passing the return value to the `remove(_:)` method
	
	The return value is not discardable as the callback should be removed manually. To attach it to the life cycle of an object, use the `add` method that takes a `lifeCycleObserver` parameter.
	
	- parameter queue: The queue to call the function on when the notification is delivered. If nil (the default) it will be delivered on the same queue the notification was sent.
	- parameter callBack: The function to call when the notification is to be delivered.
	
	- returns: An entry in the list of observers, which should be used later to remove the observer.
	*/
	open func add(queue: DispatchQueue? = nil, _ callBack: @escaping (Parameters) -> Void) -> ObserverSetEntry<Parameters> {
		add(queue: queue, self) { _ in callBack }
	}
	
	/**
	Adds a new function (or closure) to call when a notification is to be delivered.
	The callback will be removed when the `lifeCycleObserver` object is deallocated
	
	- parameter queue: The queue to call the function on when the notification is delivered. If nil (the default) it will be delivered on the same queue the notification was sent.
	- parameter callBack: The function to call when the notification is to be delivered.
	
	- returns: An entry in the list of observers, which can be used later to remove the observer.
	*/
	@discardableResult
	open func add<ObserverType: AnyObject>(queue: DispatchQueue? = nil, _ lifeCycleObserver: ObserverType, _ callBack: @escaping (Parameters) -> Void) -> ObserverSetEntry<Parameters> {
		add(queue: queue, lifeCycleObserver) { _ in callBack }
	}
	
	/**
	Sets the keyPath on an observer to the value received when a notification is delivered.
	
	- parameter queue: The queue to call the function on when the notification is delivered. If nil (the default) it will be delivered on the same queue the notification was sent.
	- parameter keyPath: The keyPath to set when the notification is to be delivered.
	
	- returns: An entry in the list of observers, which can be used later to remove the observer.
	*/
	@discardableResult
	open func add<ObserverType: AnyObject>(queue: DispatchQueue? = nil, _ observer: ObserverType, _ keyPath: ReferenceWritableKeyPath<ObserverType, Parameters>) -> ObserverSetEntry<Parameters> {
		add(queue: queue, observer) { observer in { observer[keyPath: keyPath] = $0 } }
	}
	
	/**
	Removes an observer from the list, using the entry which was returned when adding.
	
	- parameter entry: An entry returned when adding a new observer.
	*/
	open func remove(_ entry: ObserverSetEntry<Parameters>) {
		synchronized {
			self.entries = self.entries.filter{ $0 !== entry }
		}
	}
	
	
	/**
	Removes an observer from the list.
	
	- parameter observer: An observer to remove from the list of observers.
	*/
	open func removeObserver<ObserverType: AnyObject>(_ observer: ObserverType) {
		synchronized {
			self.entries.removeAll(where: { ($0 as? ObserverSetEntryImpl<ObserverType, Parameters>)?.observer === observer })
		}
	}
	
	/**
	Call this method to notify all observers.
	
	- parameter parameters: The parameters that are required parameters specified using generics when the instance is created.
	*/
	open func notify(_ parameters: Parameters) {
		let callBackList = synchronized { () -> [ObserverSetEntry<Parameters>] in
			self.entries.removeAll(where: { $0.isExpired })
			return self.entries
		}
		for callBack in callBackList {
			callBack.call(parameters)
		}
	}
	
	// MARK: - Private functions
	// MARK: Locking support
	
	private var queue = DispatchQueue(label: "com.theappbusiness.ObserverSet", attributes: [])
	
	private func synchronized<T>(_ f: () -> T) -> T {
		queue.sync(execute: f)
	}
}

public extension ObserverSet where Parameters == Void {
	
	/**
	Call this method to notify all observers.
	*/
	func notify() {
		notify(())
	}
	/**
	Adds a new observer to the set.
	
	Convenience method so that the callback function can be `func callback() { ... }` instead of `func callback(_: Void) { ... }`

	- parameter queue: The queue to call the function on when the notification is delivered. If nil (the default) it will be delivered on the same queue the notification was sent.
	- parameter observer: The object that is to be notified.
	- parameter callBack: The function to call on the observer when the notification is to be delivered.
	
	- returns: An entry in the list of observers, which can be used later to remove the observer.
	*/
	@discardableResult
	func add<ObserverType: AnyObject>(queue: DispatchQueue? = nil, _ observer: ObserverType, _ callBack: @escaping (ObserverType) -> () -> Void) -> ObserverSetEntry<Parameters> {
		add(queue: queue, observer) { observer in
			{ _ in
				callBack(observer)()
			}
		}
	}
	
}
