//
//  ViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 02/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var emailIdTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    var keyboardFrame: CGRect = CGRect.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Firechat"
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem?.title = ""
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.contentSize = self.parentView.frame.size
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func signInAction(_ sender: AnyObject) {
        self.loader.startAnimating()
        self.loader.isHidden = false
        self.parentView.isUserInteractionEnabled = false
        FirechatManager.sharedManager.signInToFirechat(username: emailIdTxt.text!, password: passwordTxt.text!) { (result) in
            var success: Bool = false
            if( result.value(forKey: "success") != nil ){
                success = result.value(forKey: "success") as! Bool
            }

            var error: NSError? = nil
            
            if( result.value(forKey: "error") != nil ){
                error = result.value(forKey: "error") as? NSError
            }
            
            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ActiveConversationsViewController") as! ActiveConversationsViewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else
            {
                let alert = UIAlertController(title: "Warning", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.loader.stopAnimating()
                self.loader.isHidden = true
                self.parentView.isUserInteractionEnabled = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage=textField.tag+1;
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
        }
        
        if( textField.tag == 1 )
        {
            self.signInAction(self)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        //If textfield is hiding below textfield, pull textfield on visible part off the screen by setting offset
        if (textField.frame.origin.y + textField.frame.size.height + 20 + self.parentView.frame.origin.y) > keyboardFrame.origin.y {
            if( ((textField.frame.origin.y + textField.frame.size.height + 20 + self.parentView.frame.origin.y) - keyboardFrame.origin.y) < 150 )
            {
                let point: CGPoint = CGPoint(x: 0, y: ((textField.frame.origin.y + textField.frame.size.height + 20 + self.parentView.frame.origin.y) - keyboardFrame.origin.y))
                self.scrollView.setContentOffset(point, animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

