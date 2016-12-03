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
        FIRAuth.auth()?.signIn(withEmail: emailIdTxt.text!, password: passwordTxt.text!, completion: { (user, error) in
            if(( error ) != nil)
            {
                print(error?.localizedDescription)
            }
            
            if(( user ) != nil)
            {
                print("SIgn in success")
                self.performSegue(withIdentifier: "UserSignedIn", sender: self)
            }
        })
    }
}

