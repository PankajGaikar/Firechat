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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.status.text = "Hey there! I'm using Firechat"
        self.emailID.text = self.contact.emailID
        self.username.text = self.contact.username
        self.profilePhoto.imageFromServerURL(urlString: self.contact.userPhotoURI)
        self.logoutButton.isHidden = self.otherUser
    }
    
    @IBAction func logoutOfFirechat(_ sender: AnyObject) {
        FirechatManager.sharedManager.logout { (result) in
            if result{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
