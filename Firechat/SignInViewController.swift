//
//  ViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 02/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailIdTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signInAction(_ sender: AnyObject) {
        FirechatManager.sharedManager.signInToFirechat(username: emailIdTxt.text!, password: passwordTxt.text!) { (result) in
            if result {
                self.performSegue(withIdentifier: "UserSignedIn", sender: self)
            }
        }
    }
}

