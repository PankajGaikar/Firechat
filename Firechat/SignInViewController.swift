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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.title = "Firechat"
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func signInAction(_ sender: AnyObject) {
        self.loader.startAnimating()
        self.loader.isHidden = false
        self.parentView.isUserInteractionEnabled = false
        FirechatManager.sharedManager.signInToFirechat(username: emailIdTxt.text!, password: passwordTxt.text!) { (result) in
            var success: Bool = false
            if( result.value(forKey: "success") != nil ){
                success = result.value(forKey: "result") as! Bool
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
        let point: CGPoint = CGPoint(x: 0, y:textField.frame.origin.y)
        self.scrollView.setContentOffset(point, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

