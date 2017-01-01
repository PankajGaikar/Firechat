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

class ActiveConversationsViewController: UITableViewController
{
    @IBOutlet weak var currentUserButton: UIButton!
    var users = NSMutableArray.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Firechat"

        self.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.currentUserButton.frame = CGRect.init(x: 0, y: 0, width: 35, height: 35)
        self.currentUserButton.cornerRadius = 17.5
        
        if FIRAuth.auth()?.currentUser?.photoURL != nil {
            self.currentUserButton.imageFromServerURL(urlString: (FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!)
        }
        else
        {
            self.currentUserButton.setBackgroundImage(#imageLiteral(resourceName: "user_placeholder"), for: .normal)
        }
        
        FirechatManager.sharedManager.fetchActiveConvoContactKeys { (keys) in
            let keysArray = keys.allKeys as NSArray

            for index in 0 ..< keysArray.count
            {
                FirechatManager.sharedManager.fetchContactForKey(contactKey: keysArray.object(at: index) as! (String), CompletionHandler: { (contact) in
                    let dict: NSMutableDictionary = NSMutableDictionary()
                    dict.setValue(contact, forKey: "Contact")
                    let status = keys.object(forKey: keysArray.object(at: index)) as! NSDictionary
                    dict.setValue(status.object(forKey: "LastMessage"), forKey: "LastMessage")
                    dict.setValue(status.object(forKey: "time"), forKey: "time")
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
                    if( index == keysArray.count-1 ){
                        self.sortUsersWithTime()
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func sortUsersWithTime() {
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        let sortedResults = self.users.sortedArray(using: [descriptor]) as NSArray
        self.users = sortedResults.mutableCopy() as! NSMutableArray
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
        cell.time.text = formatDate(date: dict.value(forKey: "time") as! Double)
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = self.users.object(at: indexPath.row) as! NSDictionary
        let user = dict.object(forKey: "Contact") as! FirechatContact
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
        viewController.otherUser = user
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func formatDate(date: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "hh:mm a"
        let time = dateFormatter.string(from: NSDate(timeIntervalSince1970: date/1000) as Date)
        return time as String
    }
    
    @IBAction func profileButtonAction(_ sender: AnyObject) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FirechatProfileViewController") as! FirechatProfileViewController
        viewController.contact = FirechatManager.sharedManager.currentUser
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
