//
//  BaseVM.swift
//  GTTest
//
//  Created by Jason Poon on 15/12/2020.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}
