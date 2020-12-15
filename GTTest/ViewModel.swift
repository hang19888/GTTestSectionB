//
//  ViewModel.swift
//  GTTest
//
//  Created by Jason Poon on 15/12/2020.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import Contacts

final class ViewModel: ViewModelType {
    var input: Input
    var output: Output
    
    let bag = DisposeBag()
    
    private let contact = BehaviorSubject<(String, String?)?>(value: nil)
    private let money = BehaviorSubject<String>(value: "")
    private let submit = PublishSubject<Void>()
    private let alert = PublishSubject<String>()
    private let result = PublishSubject<NSDecimalNumber>()
    private let resultText = PublishSubject<String>()
    private let isValid = PublishSubject<Bool>()
    
    struct Input {
        let contact: AnyObserver<(String, String?)?>
        let money: AnyObserver<String>
        let submit: AnyObserver<Void>
    }
    
    struct Output {
        let name: Driver<String>
        let phone: Driver<String>
        let alert: Driver<String>
        let result: Driver<NSDecimalNumber>
        let resultText: Driver<String>
        let isValid: Driver<Bool>
    }
    
    init() {
        input = .init(
            contact: contact.asObserver(),
            money: money.asObserver(),
            submit: submit.asObserver()
        )
    
        
        output = .init(
            name: contact.map{ $0?.0 ?? "-" }.asDriver(onErrorJustReturn: "-"),
            phone: contact.map{ $0?.1 ?? "-" }.asDriver(onErrorJustReturn: "-"),
            alert: alert.asDriver(onErrorJustReturn: ""),
            result: result.asDriver(onErrorJustReturn: NSDecimalNumber.zero),
            resultText: resultText.asDriver(onErrorJustReturn: ""),
            isValid: isValid.asDriver(onErrorJustReturn: false)
        )
        
        submit
            .withLatestFrom(contact).filter{ $0 == nil}
            .map{ _ in "Please select the contact from contact book first" }
            .bind(to: alert)
            .disposed(by: bag)
        
        let decimal = submit
            .withLatestFrom(contact).filterNil()
            .withLatestFrom(money).filter{ $0.isNumeric}
            .map{ NSDecimalNumber(string: $0) }
            .share()
        
        decimal
            .filter{ $0.moreThan(9999)}
            .map{ _ in "Transferring USD larger than or equal to 10,000 is not supported yet."}
            .bind(to: alert)
            .disposed(by: bag)
        
        let checkNumeric = submit
            .withLatestFrom(contact).filterNil()
            .withLatestFrom(money).filter{ !$0.isNumeric}
            .map{ _ in}
        
        Observable.merge(
                checkNumeric,
                decimal.filter{ $0.lessThan(1)}.map{ _ in}
            )
            .map{ _ in "Incorrect money input. Please enter again" }
            .bind(to: alert)
            .disposed(by: bag)
        
        let invalid = Observable.merge(
                checkNumeric,
                decimal.filter{ $0.lessThan(1) || $0.moreThan(9999)}.map{ _ in}
            )
            .share()
        
        let valid = decimal
            .filter{ money in money.moreThan(0) && money.lessThan(10000) }
            .map{ money in money.dividing(by: NSDecimalNumber(7.8)).round(2) }
            .share()
        
        Observable
            .merge(
                valid,
                invalid.map{ NSDecimalNumber.zero }
            )
            .bind(to: result)
            .disposed(by: bag)
        
        Observable
            .merge(
                valid.map{ _ in true},
                invalid.map{ _ in false}
            )
            .bind(to: isValid)
            .disposed(by: bag)
        
        result
            .filter{ money in money.moreThan(0) && money.lessThan(10000) }
            .withLatestFrom(
                Driver.combineLatest(
                    contact.map{ $0?.0 ?? "-" }.asDriver(onErrorJustReturn: "-"),
                    contact.map{ $0?.1 ?? "-" }.asDriver(onErrorJustReturn: "-")
                )
            ){ ($0, $1.0, $1.1) }
            .map{ amount, name, phone in
                "Send USD \(amount) to \(name) with phone number: \(phone)"
            }
            .bind(to: resultText)
            .disposed(by: bag)
        
    }
    
    
}
