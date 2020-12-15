//
//  StringX.swift
//  GTTest
//
//  Created by Jason Poon on 15/12/2020.
//

import Foundation

extension String {

    var isNumeric : Bool {
        return NumberFormatter().number(from: self) != nil
    }

}
