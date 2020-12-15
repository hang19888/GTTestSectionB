//
//  GTTestTests.swift
//  GTTestTests
//
//  Created by Jason Poon on 15/12/2020.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Contacts
@testable import GTTest

class GTTestTests: XCTestCase {
    
    var vm: ViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vm = ViewModel()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAC3() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        vm.input.contact.onNext(("Hank", "(555) 766-4823"))
        XCTAssertEqual(try vm.output.name.toBlocking().first() , "Hank")
        XCTAssertEqual(try vm.output.phone.toBlocking().first()  , "(555) 766-4823")
    }
    
    func testAlert() throws {
        let alert = scheduler.createObserver(String.self)
        
        vm.output.alert
            .drive(alert)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
                .next(0, nil),
                .next(1, ("Hank", "(555) 766-4823"))]
            )
            .bind(to: vm.input.contact)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
                .next(0, ""),
                .next(1, ""),
                .next(2, "0"),
                .next(3, "10000")]
            )
            .bind(to: vm.input.money)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
                .next(0, ()),
                .next(1, ()),
                .next(2, ()),
                .next(3, ())]
            )
            .bind(to: vm.input.submit)
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(alert.events, [
            .next(0, "Please select the contact from contact book first"),
            .next(1, "Incorrect money input. Please enter again"),
            .next(2, "Incorrect money input. Please enter again"),
            .next(3, "Transferring USD larger than or equal to 10,000 is not supported yet.")
        ])
    }
    
    func testUSDConcurrcy() throws {
        let usd = scheduler.createObserver(NSDecimalNumber.self)
        
        vm.output.result
            .drive(usd)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
                .next(0, ("Hank", "(555) 766-4823"))]
            )
            .bind(to: vm.input.contact)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
                .next(0, "100"),
                .next(1, "5"),
                .next(2, "1"),
                .next(3, "9999"),
                .next(4, "0"),
                .next(5, "10000")]
            )
            .bind(to: vm.input.money)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
                .next(0, ()),
                .next(1, ()),
                .next(2, ()),
                .next(3, ()),
                .next(4, ()),
                .next(5, ())]
            )
            .bind(to: vm.input.submit)
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertEqual(usd.events, [
            .next(0, NSDecimalNumber(value: 12.82)),
            .next(1, NSDecimalNumber(value: 0.64)),
            .next(2, NSDecimalNumber(value: 0.13)),
            .next(3, NSDecimalNumber(value: 1281.92)),
            .next(4, NSDecimalNumber.zero),
            .next(5, NSDecimalNumber.zero)
        ])
    }


}
