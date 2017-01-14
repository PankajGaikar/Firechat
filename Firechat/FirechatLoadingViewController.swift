//
//  FirechatLoadingViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 25/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FirechatLoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        self.title = Firechat
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let viewController: UIViewController;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if ( FIRAuth.auth()?.currentUser != nil)
        {
            viewController = storyboard.instantiateViewController(withIdentifier: "ActiveConversationsViewController") as! ActiveConversationsViewController
        }
        else
        {
            viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
