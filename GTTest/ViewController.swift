//
//  ViewController.swift
//  GTTest
//
//  Created by Jason Poon on 15/12/2020.
//

import UIKit
import RxSwift
import RxCocoa
import ContactsUI

class ViewController: UIViewController {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var tfMoney: UITextField!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnContact: UIBarButtonItem!
    
    let vm = ViewModel()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user trigger
        btnContact.rx.tap
            .map{ CNContactPickerViewController() }
            .subscribe( onNext:{ [unowned self] contactVC in
                contactVC.delegate = self
                self.present(contactVC, animated: true)
            })
            .disposed(by: bag)
        
        tfMoney.rx.text.orEmpty
            .bind(to: vm.input.money)
            .disposed(by: bag)
        
        btnSubmit.rx.tap
            .bind(to: vm.input.submit)
            .disposed(by: bag)
        
        //binding
        vm.output.name.map{ "Send to \($0)" }.drive(lblName.rx.text).disposed(by: bag)
        vm.output.phone.map{ "Phone: \($0)" }.drive(lblPhone.rx.text).disposed(by: bag)
        
        vm.output.alert.drive(lblMessage.rx.text).disposed(by: bag)
        vm.output.alert.map{ _ in .red }.drive(lblMessage.rx.textColor).disposed(by: bag)
        
        vm.output.resultText.drive(lblMessage.rx.text).disposed(by: bag)
        vm.output.resultText.map{ _ in .black }.drive(lblMessage.rx.textColor).disposed(by: bag)
    }
}

extension ViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //did select contact
        vm.input.contact.onNext((contact.givenName, contact.phoneNumbers.first?.value.stringValue))
    }
}

