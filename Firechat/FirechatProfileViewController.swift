//
//  FirechatProfileViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 25/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation
import UIKit

class FirechatProfileViewController: UIViewController {
    
    var contact: FirechatContact = FirechatContact()
    var otherUser: Bool = false
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var emailID: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var editStatusButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.title = self.contact.username
        self.status.text = self.contact.status
        self.emailID.text = self.contact.emailID
        self.username.text = self.contact.username
        self.profilePhoto.imageFromServerURL(urlString: self.contact.userPhotoURI)
        self.logoutButton.isHidden = self.otherUser
        self.editStatusButton.isHidden = self.otherUser
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func logoutOfFirechat(_ sender: AnyObject) {
        FirechatManager.sharedManager.logout { (result) in
            if result{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "FirechatLoadingViewController") as! FirechatLoadingViewController
                self.navigationController?.viewControllers = [viewController]
            
            }
        }
    }
    
    @IBAction func editStatusAction(_ sender: AnyObject) {
        self.status.isHidden = true
        self.editStatusButton.isHidden = true
        self.statusTextField.isHidden = false
        self.statusTextField.text = ""
        self.statusTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.characters.count == 0{
            return false
        }
        FirechatManager.sharedManager.updateUserStatus(status: textField.text!) { (result) in
            if result{
                self.status.text = textField.text!
            }
        }
        self.status.isHidden = false
        self.editStatusButton.isHidden = false
        self.statusTextField.isHidden = true
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWasShown(notification: NSNotification){
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        animateViewMoving(up: true, moveValue: frame.height-100)
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        animateViewMoving(up: false, moveValue: frame.height+100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
