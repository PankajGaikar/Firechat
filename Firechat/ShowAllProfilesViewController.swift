//
//  ShowAllProfilesViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 03/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ShowAllProfilesViewController: UITableViewController
{
    var usersInfo: NSArray = NSArray();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.title = "All Contacts"
        FirechatManager.sharedManager.fetchAllContacts { (array) in
            self.usersInfo = array
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactDetailCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactDetailCell
        
        let contact = self.usersInfo.object(at: indexPath.row) as! FirechatContact
        
        cell.contactName.text = contact.username
        cell.statusLabel?.text = contact.status
        cell.profileImage?.imageFromServerURL(urlString: contact.userPhotoURI)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
        viewController.otherUser = self.usersInfo.object(at: indexPath.row) as! FirechatContact
        self.navigationController?.pushViewController(viewController, animated: true)
        self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count)! - 2)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ConversationsViewController
        destinationVC.otherUser = sender as! FirechatContact
    }
}
