//
//  ConversationViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 04/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var otherUser: FirechatContact = FirechatContact();
    var currentUser: FirechatContact = FirechatContact();
    var conversationNode = FIRDatabase.database().reference()
    var convoList = NSMutableArray.init()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTxt: UITextField!
    
    override func viewDidLoad() {
        self.title = self.otherUser.username
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let otherUserButton = UIButton(frame: CGRect(x: 100, y: 100, width: 35, height: 35))
        otherUserButton.setBackgroundImage(UIImage.init(named: "user_placeholder.png"), for: .normal)
        otherUserButton.cornerRadius = 17.5
        otherUserButton.addTarget(self, action: #selector(self.showOtherProfile), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = otherUserButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.currentUser = FirechatManager.sharedManager.currentUser
        URLSession.shared.dataTask(with: NSURL(string: self.otherUser.userPhotoURI)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                otherUserButton.setBackgroundImage(image, for: .normal)
            })
        }).resume()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 50.0;
        self.hideKeyboardWhenTappedAround()
        FirechatManager.sharedManager.checkIfConversationNodeExist(user: otherUser) { (response) in
            if response{
                print("Success")
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(activeConvoObserver), name: NSNotification.Name(rawValue: "activeConvoObserver"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "activeConvoObserver"), object: nil);
        FirechatManager.sharedManager.removeActiveConvoObserver()
    }
    
    func activeConvoObserver( message: NSNotification)
    {
        print(message)
        let x = message.object as! NSDictionary
        self.convoList.insert(x, at: self.convoList.count)
        self.tableView.reloadData()
        self.tableViewScrollToBottom(animated: true)
    }
    
    @IBAction func sendMessageAction(_ sender: AnyObject) {
        if (self.messageTxt.text?.characters.count)! > 0{
            self.sendMessage(message: self.messageTxt.text!)
            self.messageTxt.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.convoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageBundle = self.convoList.object(at: indexPath.row) as! NSDictionary
        let sender = messageBundle.object(forKey: "sender") as! String
        if sender == (self.currentUser.userKey)
        {
            let cell: MessageFromMeCell = tableView.dequeueReusableCell(withIdentifier: "Me", for: indexPath) as! MessageFromMeCell
            cell.message.text = messageBundle.object(forKey: "Message") as? String
            cell.profileImage.imageFromServerURL(urlString: self.currentUser.userPhotoURI)
            cell.timestamp.text = self.formatDate(date: messageBundle.value(forKey: "time") as! Double)
            return cell
        }
        else
        {
            let cell: MessageFromYouCell = tableView.dequeueReusableCell(withIdentifier: "You", for: indexPath) as! MessageFromYouCell
            cell.message.text = messageBundle.object(forKey: "Message") as? String
            cell.profileImage.imageFromServerURL(urlString: self.otherUser.userPhotoURI)
            let x:Double = messageBundle.value(forKey: "time") as! Double
            print(NSDate(timeIntervalSince1970: x/1000))
            cell.timestamp.text = self.formatDate(date: messageBundle.value(forKey: "time") as! Double)
            return cell
        }
    }
    
    func formatDate(date: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "MMMM dd, hh:mm a"
        let time = dateFormatter.string(from: NSDate(timeIntervalSince1970: date/1000) as Date)
        return time as String
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let newMessage = textField.text
        if (newMessage?.characters.count)! > 0 {
            textField.text = ""
            self.sendMessage(message: newMessage!)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func sendMessage(message: String)
    {
        FirechatManager.sharedManager.sendNewMessage(message: message)
        self.tableViewScrollToBottom(animated: true)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        let numberOfSections = self.tableView.numberOfSections
        let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
        if numberOfRows > 0 {
            let indexPath = NSIndexPath.init(row: numberOfRows-1, section: numberOfSections-1)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: animated)
        }
    }
    
    func keyboardWasShown(notification: NSNotification){
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        animateViewMoving(up: true, moveValue: frame.height)

    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        animateViewMoving(up: false, moveValue: frame.height)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func showOtherProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FirechatProfileViewController") as! FirechatProfileViewController
        viewController.contact = self.otherUser
        viewController.otherUser = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
