//
//  ViewController.swift
//  CMS-iOS
//
//  Created by Hridik Punukollu on 09/08/19.
//  Copyright © 2019 Hridik Punukollu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import SwiftKeychainWrapper
import RealmSwift
class LoginViewController: UIViewController {
    
    @IBOutlet weak var keyField: UITextField!
    let constant = Constants.Global.self
    
    var currentUser = User()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        
        SVProgressHUD.dismiss()
        if Reachability.isConnectedToNetwork() {
            checkSavedPassword()
        }else{
            
            // get user from realm
            let realm = try! Realm()
            if let realmUser = realm.objects(User.self).first{
                currentUser = realmUser
            }
            
            
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Unable to connect", message: "You are not connected to the internet. Please check your connection and relaunch the app.", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default) { _ in
                
                let realm = try! Realm()
                let users = realm.objects(User.self)
                if (users.count != 0){
                    self.currentUser = users[0]
                }
                
                self.performSegue(withIdentifier: "goToDashboard", sender: self)

                
                
            }
            alert.addAction(dismiss)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier ?? ""
        switch segueID {
        case "goToDashboard":
            let tabVC = segue.destination as! UITabBarController
            let nextVC = tabVC.viewControllers![0] as! UINavigationController
            let destinationVC = nextVC.topViewController as! DashboardViewController
            
            destinationVC.userDetails = self.currentUser
        default:
            break
        }
    }
    
    func checkSavedPassword() {
        if let retrievedPassword: String = KeychainWrapper.standard.string(forKey: "userPassword") {
            self.view.isUserInteractionEnabled = false
            logIn (password: retrievedPassword, loggedin: true) {
                print(retrievedPassword)
                print("Password Retrieved. Logging in.")
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func logIn(password: String, loggedin: Bool, completion : @escaping () -> Void) {
        print("Password used for request is: \(password)")
        let params : [String:String] = ["wstoken" : password]
        let FINAL_URL = constant.BASE_URL + constant.LOGIN
        
        SVProgressHUD.show()
        Alamofire.request(FINAL_URL, method: .get, parameters: params, headers: constant.headers).responseJSON { (response) in
            if response.result.isSuccess {
                let userData = JSON(response.value as Any)
                if (userData["exception"].string != nil) {
                    let alert = UIAlertController(title: "Invalid key", message: "The key that you have entered is invalid. Please check and try again.", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(dismiss)
                    self.present(alert, animated: true, completion: {
                        self.keyField.text = ""
                    })
                    print("Enter the key again.")
                } else {
                    if loggedin == false {
                        let savedPassword : Bool = KeychainWrapper.standard.set(password, forKey: "userPassword")
                        print(savedPassword)
                        
                    }
                    
                    self.currentUser.name = userData["firstname"].string!.capitalized
                    self.currentUser.userid = userData["userid"].int!
                    
                    let user = User()
                    user.name = self.currentUser.name
                    user.email = self.currentUser.email
                    user.loggedIn = self.currentUser.loggedIn
                    user.userid = self.currentUser.userid
                    let realm = try! Realm()
                    try! realm.write {
                        
                        
                        realm.add(user)
                    }
                    
                    
                    self.keyField.text = ""
                    self.performSegue(withIdentifier: "goToDashboard", sender: self)
                    completion()
                }
            }
        }
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if keyField.text != "" {
            self.view.isUserInteractionEnabled = false
            logIn(password: keyField.text!, loggedin: false) {
                self.view.isUserInteractionEnabled = true
                print("Continue")
            }
        }
        else {
            let alert = UIAlertController(title: "Enter a key", message: "You have not entered a key. Please enter a valid key or press help.", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(dismiss)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://docs.google.com/document/d/1F21bBNZ-h7MQh0HWM-rSbo6j2qKLoOaFY5Tl_If9C_0/edit?usp=sharing")!, options: [:], completionHandler: nil)
        
    }
    
    
}

