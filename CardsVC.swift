//
//  CardsVC.swift
//  VRSideKick
//
//  Created by Gaurav on 18/04/22.
//

import UIKit

class CardsVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var imgNoData: UIImageView!

    var cards : [ CardsModelData ]?
    override func viewDidLoad() {
        super.viewDidLoad()

        initialLoads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = true
        
        getCards()
        
    }
   
    //MARK: - Button Actions
    
    @IBAction func btnAddCard(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as! AddCardVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Functions

extension CardsVC{
    func initialLoads(){
        configureNaviBar(title: ViewControllerTitles.card, isBackButton: true)
    }
}


extension CardsVC:UITableViewDataSource,UITableViewDelegate{
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cards?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "CardsTblCell", for: indexPath) as! CardsTblCell

        cell.selectionStyle = .none
        
        let card = cards?[ indexPath.row ]
        
        if let cardNumber = card?.last_four {
            
            if let brand = card?.brand {
               
                cell.lblCardNumber.text = "\(brand)**** **** **** \(cardNumber)"
                
            }
            
        }
        
        cell.callBackRemove = { [ weak self ] in
            
            if let self = self {
                
                if let cardId = card?.card_id {
                    
                    self.showAlertWithOkAndCancel(message: AlertMessages.sureToRemoveCard, strtitle: "", okTitle: Strings.delete, cancel: Strings.cancel) { ok in
                        
                        self.deleteCard(id: cardId)
                        
                    } handlerCancel: { cancel in
                        
                        
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 71
    
    }
    

}

//MARK: - Api Methods

extension CardsVC{
    
    func getCards() {
        
        let params = [String:Any]()
        
        RVApiManager.getAPI(Apis.cards, parameters: params, Vc: self, showLoader: true) { [weak self] (data:CardsModel) in
            
            if let success = data.success{
                
                if success{
                    
                    if let responseData = data.data{
                       
                        self?.cards = responseData
                        
                        if self?.cards?.count ?? 0 > 0 {
                            
                            self?.tblView.isHidden = false
                            self?.imgNoData.isHidden = true
                            self?.imgNoData.image = nil
                            
                        } else {
                            
                            self?.tblView.isHidden = true
                            self?.imgNoData.isHidden = false
                            self?.imgNoData.loadGif(name: "noData")

                        }
                        
                        self?.tblView.reloadData()
                        
                    }
                    
                } else {
                    
                    if let message = data.message {
                        
                        self?.showAlert(message: message, title: "")
                        
                    } else {
                        self?.showAlert(message: AlertMessages.somethingWentWrong, title: "")
                    }
                }
            } else {
                
                self?.showAlert(message: AlertMessages.somethingWentWrong, title: "")
                
            }
        }
    }
    
    func deleteCard(id:String) {
        
        let params = ["card_id":id]
        
        RVApiManager.postAPI(Apis.deleteCard, parameters: params, Vc: self, showLoader: true) { [weak self] (data:LoginModel) in
            
            if let success = data.success{
                
                if success{
                    
                    self?.getCards()
                    
                } else {
                    
                    if let message = data.message {
                        
                        self?.showAlert(message: message, title: "")
                        
                    } else {
                        self?.showAlert(message: AlertMessages.somethingWentWrong, title: "")
                    }
                }
            } else {
                
                self?.showAlert(message: AlertMessages.somethingWentWrong, title: "")
                
            }
        }
    }

}
