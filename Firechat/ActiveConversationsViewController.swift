//
//  ConversationsListViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 03/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

class ActiveConversationsViewController: UITableViewController
{
    var users = NSMutableArray.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        FirechatManager.sharedManager.fetchActiveConvoContactKeys { (keys) in
            let keysArray = keys.allKeys as NSArray
            for index in 0 ..< keysArray.count
            {
                FirechatManager.sharedManager.fetchContactForKey(contactKey: keysArray.object(at: index) as! (String), CompletionHandler: { (contact) in
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    dict.setValue(contact, forKey: "Contact")
                    let status = keys.object(forKey: keysArray.object(at: index)) as! NSDictionary
                    dict.setValue(status.object(forKey: "LastMessage"), forKey: "LastMessage")
                    var flag = 0;
                    for index in 0 ..< self.users.count
                    {
                        let x = self.users.object(at: index) as! NSDictionary
                        let oldContact = x.object(forKey: "Contact") as! FirechatContact
                        if oldContact.userKey == contact.userKey
                        {
                            self.users.replaceObject(at: index, with: dict)
                            flag += 1
                            break;
                        }
                    }
                    if flag == 0{
                        self.users.add(dict)
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationListCell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationListCell
        let dict = self.users.object(at: indexPath.row) as! NSDictionary
        let user = dict.object(forKey: "Contact") as! FirechatContact
        cell.profileImage.imageFromServerURL(urlString: user.userPhotoURI)
        cell.contactName.text = user.username
        cell.message.text = dict.value(forKey: "LastMessage") as? String
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.users.object(at: indexPath.row) as! NSDictionary
        let user = dict.object(forKey: "Contact") as! FirechatContact
        self.performSegue(withIdentifier: "ResumeConversation", sender: user)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResumeConversation"
        {
            let destinationVC = segue.destination as! ConversationsViewController
            destinationVC.otherUser = sender as! FirechatContact
        }
        
    }
}
