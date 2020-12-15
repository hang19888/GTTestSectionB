//
//  NSDecimalNumberX.swift
//  GTTest
//
//  Created by Jason Poon on 15/12/2020.
//

import Foundation

extension NSDecimalNumber {
    public func round(_ decimals:Int) -> NSDecimalNumber {
        return self.rounding(accordingToBehavior:
            NSDecimalNumberHandler(roundingMode: .plain,
                                   scale: Int16(decimals),
                                   raiseOnExactness: false,
                                   raiseOnOverflow: false,
                                   raiseOnUnderflow: false,
                                   raiseOnDivideByZero: false))
    }
    
    public func moreThan(_ value: Int) -> Bool {
        return self.compare(NSDecimalNumber(value: value)) == .orderedDescending
    }
    
    public func lessThan(_ value: Int) -> Bool {
        return self.compare(NSDecimalNumber(value: value)) == .orderedAscending
    }
}
