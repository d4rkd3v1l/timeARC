//
//  TimerViewTests.swift
//  timeARCTests
//
//  Created by d4Rk on 13.03.21.
//

import XCTest
import ViewInspector
import SwiftUI
import SwiftUIFlux
@testable import timeARC

extension Inspection: InspectionEmissary where V: Inspectable { }

protocol InspectableConnectedView: ConnectedView, Inspectable {
    var inspection: Inspection<Self> { get }
}

extension TimerView: InspectableConnectedView {}

extension StoreConnector: Inspectable {}
extension TimerArcView: Inspectable {}
extension ArcViewFull: Inspectable {}

class TimerViewTests: XCTestCase {
//    func testArcView() throws {
//        self.injectTestStore(into: TimerView()) { sut in
//            let timerArcView = try sut.find(ArcViewFull.self)
//            try timerArcView.find(text: "0")
//            try timerArcView.find(text: "00:00:00")
//
//            try timerArcView.callOnTapGesture()
//
//            self.async(after: 0.5) {
//                try! timerArcView.find(text: "-08:00:00")
//            }
//        }
//    }

    func testArcView2() throws {
        let sut = TimerView()

        let exp = sut.inspection.inspect { view in
            let arcView = try view.find(ArcViewFull.self)
            _ = try arcView.find(text: "0")
            _ = try arcView.find(text: "00:00:00")

            try arcView.callOnTapGesture()

            let innerExp = self.expectation(description: "inner")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                try! arcView.find(text: "-08:00:00")
                innerExp.fulfill()
            }
            self.wait(for: [innerExp], timeout: 0.5)
        }

        ViewHosting.host(view: sut.environmentObject(testStore))
        wait(for: [exp], timeout: 1)
    }

//    func testStartButton() throws {
//        let exp = self.injectTestStore(into: TimerView()) { sut in
//            let button = try sut.find(button: "start")
//            try button.tap()
//
//            let blub = AsyncOperation {
//                try? sut.find(button: "stop")
//            }
//
//
//
//            let bla: InspectableView<ViewType.Button>? = self.async { callback in
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
//                    let result = try? sut.find(button: "stop")
//                    callback(result)
//                }
//            }
//
//            XCTAssertEqual(try bla!.accentColor(), .green)
//
//            //            self.async(after: 0.6) {
//            //                XCTFail("Fuck this shit!")
////                try! sut.find(button: "stop")
////            }
//        }
//        self.wait(for: [exp], timeout: 4)
//    }
//
//    func testThisShit() throws {
////        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
////        let exp = self.injectTestStore(into: TimerView()) { sut in
//
//
//        let bla = AsyncOperation {  }
//
//
//        let bla = async { bla in
//            bla("String")
//        }
//        XCTAssertEqual(bla, "String")
//
////        self.async(after: 0) {
////            self.async(after: 0.5) {
////                print("bla")
////                XCTFail("FUCK IT")
////            }
////        }
//
//        //        }
//        //        }
////        self.wait(for: [exp], timeout: 10)
//    }
//
//    private func async(after delay: TimeInterval, action: @escaping () -> Void) {
//        let exp = self.expectation(description: "Async action failed.")
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1_000))) {
//            action()
//            exp.fulfill()
//        }
//        self.wait(for: [exp], timeout: delay * 2)
//    }
//
//    func async<A>(timeout: TimeInterval = 4.0,
//                  _ callbackMethod: (@escaping (A) -> Void) -> Void,
//                  description: String = "Async Execution",
//                  handler: XCWaitCompletionHandler? = nil) -> A {
//        let expectaction = self.expectation(description: description)
//
//        var result: A!
//        callbackMethod {
//            result = $0
//            expectaction.fulfill()
//        }
//
//        waitForExpectations(timeout: timeout, handler: handler )
//        return result
//    }
    
    private func injectTestStore<T: InspectableConnectedView>(into sut: T,
                                                              _ actualTest: @escaping (InspectableView<ViewType.View<StoreConnector<AppState, T>>>) throws -> Void)
    -> XCTestExpectation {
        let exp = sut.inspection.inspect { view in
            try actualTest(view.view(StoreConnector<AppState, T>.self))
        }

        ViewHosting.host(view: sut.environmentObject(testStore))
        return exp
    }
}

extension XCTestCase {
    func await<T>(_ function: (@escaping (T) -> Void) -> Void) throws -> T {
        let expectation = self.expectation(description: "Async call")
        var result: T?

        function() { value in
            result = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)

        guard let unwrappedResult = result else {
            throw AwaitError()
        }

        return unwrappedResult
    }
}

extension XCTestCase {
    // We'll add a typealias for our closure types, to make our
    // new method signature a bit easier to read.
    typealias Function<T> = (T) -> Void

    func await<A, R>(_ function: @escaping Function<(A, Function<R>)>,
                     calledWith argument: A) throws -> R {
        return try await { handler in
            function((argument, handler))
        }
    }
}

struct AsyncOperation<Value> {
    let queue: DispatchQueue = .main
    let closure: () -> Value

    func perform(then handler: @escaping (Value) -> Void) {
        queue.async {
            let value = self.closure()
            handler(value)
        }
    }
}

struct AwaitError: Error {}
