//
//  LabelX.swift
//  GTTest
//
//  Created by Jason Poon on 15/12/2020.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UILabel {
    var textColor: Binder<UIColor> {
        return Binder(base) { label, color in
            label.textColor = color
        }
    }
}
