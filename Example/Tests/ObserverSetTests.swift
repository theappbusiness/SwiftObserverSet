//
//  ObserverSetTests.swift
//  ObserverSetTests
//
//  Created by Mike Ash on 1/22/15.
//  Copyright (c) 2015 Mike Ash. All rights reserved.
//

import XCTest
@testable import TABObserverSet

class ObserverSetTests: XCTestCase {
    
    class TestObservee {
        let voidObservers = ObserverSet<Void>()
        let stringObservers = ObserverSet<String>()
        let twoStringObservers = ObserverSet<(String, String)>()
        let intObservers = ObserverSet<(Int, Int)>()
        let intAndStringObservers = ObserverSet<(Int, String)>()
        
        func testNotify() {
            voidObservers.notify(())
            stringObservers.notify("Sup")
            twoStringObservers.notify(("hello", "world"))
            intObservers.notify((42, 43))
            intAndStringObservers.notify((42, "hello"))
        }
    }
    
    class TestObserver {
        
        var stringNotificationsReceived = [String]()
        var twoStringNotificationsReceived = [(String, String)]()
        
        init(observee: TestObservee) {
            observee.voidObservers.add(self, type(of: self).voidSent)
            observee.stringObservers.add(self, type(of: self).stringChanged)
            observee.twoStringObservers.add(self, type(of: self).twoStringChanged)
            observee.intObservers.add(self, type(of: self).intChanged)
            observee.intAndStringObservers.add(self, type(of: self).intAndStringChanged)
        }
        
        deinit {
            print("deinit!!!!")
        }
        
        func voidSent() {
            print("void sent")
        }
        
        func stringChanged(s: String) {
            print("stringChanged: " + s)
            stringNotificationsReceived.append(s)
        }
        
        func twoStringChanged(s1: String, s2: String) {
            print("twoStringChanged: \(s1) \(s2)")
            twoStringNotificationsReceived.append(s1, s2)
        }
        
        func intChanged(i: Int, j: Int) {
            print("intChanged: \(i) \(j)")
        }
        
        func intAndStringChanged(i: Int, s: String) {
            print("intAndStringChanged: \(i) \(s)")
        }
        
        func namedParameterSent(name: String, count: Int) {
            print("Named parameters: \(name) \(count)")
        }
    }
    
    func testBasics() {
        let observee = TestObservee()
        var obj: TestObserver? = TestObserver(observee: observee)
        let token = observee.intAndStringObservers.add{ print("int and string closure: \($0) \($1)") }
        observee.testNotify()
        print("Destroying test observer \(String(describing: obj))")
        obj = nil
        observee.testNotify()
        observee.intAndStringObservers.remove(token)
        observee.testNotify()
    }
    
    func testRemoveObserver() {
        let sut = TestObservee()
        let observer = TestObserver(observee: sut)
        sut.testNotify()
        XCTAssertEqual(observer.stringNotificationsReceived, ["Sup"])
        XCTAssertTrue(observer.twoStringNotificationsReceived.elementsEqual([("hello", "world")], by: ==))
        sut.twoStringObservers.removeObserver(observer)
        sut.testNotify()
        XCTAssertEqual(observer.stringNotificationsReceived, ["Sup", "Sup"])
        XCTAssertTrue(observer.twoStringNotificationsReceived.elementsEqual([("hello", "world")], by: ==))
    }
}
