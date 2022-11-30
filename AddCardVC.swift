//
//  AddCardVC.swift
//  VRSideKick
//
//  Created by Gaurav on 18/04/22.
//

import UIKit
import CreditCardForm
import Stripe

class AddCardVC: UIViewController {
    
    @IBOutlet private weak var creditCardView : CreditCardFormView!
    let paymentTextField = STPPaymentCardTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialLoads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = true

    }
    
    //MARK: - Actions
    
    @IBAction func btnAdd(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - Functions

extension AddCardVC {
    
    func initialLoads() {
        
        //        self.creditCardView.cardHolderString =  String.removeNil(User.main.firstName)+" "+String.removeNil(User.main.lastName)
        self.creditCardView.defaultCardColor = #colorLiteral(red: 0.007843137255, green: 0.4901960784, blue: 1, alpha: 1)
        self.createTextField()
        self.navigationController?.isNavigationBarHidden = false
        let attributes = [NSAttributedString.Key.font: UIFont(name: AppFonts.semiBold, size: 18)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "backBlack").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = ViewControllerTitles.addCard
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.done, style: .done, target: self, action: #selector(self.doneButtonClick))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.dismissKeyBoardonTap()
    }
    
    func createTextField() {
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.delegate = self
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        paymentTextField.postalCodeEntryEnabled = false
        view.addSubview(paymentTextField)
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardView.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK:- Done Button Click
    
    @IBAction private func doneButtonClick() {
        
        Indicator.shared.start()
        
        let cardparams = STPCardParams()
        cardparams.number = paymentTextField.cardNumber
        cardparams.expMonth = UInt(paymentTextField.expirationMonth)
        cardparams.expYear = UInt(paymentTextField.expirationYear)
        cardparams.cvc = paymentTextField.cvc
        creditCardView.cardHolderString  = cardparams.name ?? ""
        
        
        STPAPIClient.shared.createToken(withCard:cardparams) { (stpToken, error) in
            Indicator.shared.stop()
            guard let token = stpToken?.tokenId else {
                self.view.makeToast(error.debugDescription)
                return
            }
            self.addCard(token: token)
        }
    }
    
    @IBAction func backButtonClick() {
        
        self.navigationController?.popViewController(animated: true)
        
    }
}

// MARK:- STPPaymentCardTextFieldDelegate

extension AddCardVC : STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = textField.isValid
        creditCardView.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: UInt(textField.expirationYear), expirationMonth: UInt(textField.expirationMonth), cvc: textField.cvc)
        let cardparams = STPCardParams()
        creditCardView.cardHolderString = cardparams.name ?? ""
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingExpiration(expirationYear: UInt(textField.expirationYear))
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingCVC()
    }
}

//MARK: - Api Methods

extension AddCardVC{
    
    func addCard(token:String){
        let params = ["stripe_token":token]
        
        RVApiManager.postAPI(Apis.addCard, parameters: params, Vc: self, showLoader: true) {  [weak self] (data:LoginModel) in
            if let success = data.success{
                if success{
                    if let message = data.message{
                        self?.showAlert(message: message, title: "", handler: { ok in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    }
                }else{
                    if let message = data.message{
                        self?.showAlert(message: message, title: "", handler: { ok in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    }else {
                        self?.showAlert(message: AlertMessages.somethingWentWrong, title: "")
                    }
                }
            } else {
                self?.showAlert(message: AlertMessages.somethingWentWrong, title: "")
            }
        }
    }
}
