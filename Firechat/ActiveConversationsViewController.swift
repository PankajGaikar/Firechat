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
            for index in 0 ..< keys.count
            {
                FirechatManager.sharedManager.fetchContactForKey(contactKey: keys.object(at: index) as! (String), CompletionHandler: { (dictionary) in
                    self.users.add(dictionary)                    
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
        let user = self.users.object(at: indexPath.row) as! NSDictionary
        
        cell.profileImage.imageFromServerURL(urlString: user.value(forKey: "userPhoto") as! String)
        cell.contactName.text = user.value(forKey: "username") as? String
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ResumeConversation", sender: self.users.object(at: indexPath.row) as! NSDictionary)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResumeConversation"
        {
            let destinationVC = segue.destination as! ConversationsViewController
            destinationVC.otherUser = sender as! NSDictionary
        }
        
    }
}
