//
//  FirechatManager.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 08/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit
import CoreData
import FirebaseStorage

class FirechatManager: NSObject
{
    var databaseReference: FIRDatabaseReference = FIRDatabaseReference()
    var messagesReference: FIRDatabaseReference = FIRDatabaseReference()
    var usersReference: FIRDatabaseReference = FIRDatabaseReference()
    var currentUser: FirechatContact = FirechatContact()
    var activeConvoWithUser: FirechatContact = FirechatContact()
    var conversationNode : FIRDatabaseReference = FIRDatabaseReference()
    static let sharedManager = FirechatManager()

    private override init() {
        FIRDatabase.database().persistenceEnabled = true
        databaseReference = FIRDatabase.database().reference()
        databaseReference.keepSynced(true)
        super.init()
        initializeNodes()
    }
    
    func initializeNodes() {
        if(( FIRAuth.auth()?.currentUser ) != nil)
        {
            messagesReference = databaseReference.child(FirechatUsersString).child(FIRAuth.auth()!.currentUser!.uid).child(FirechatMessagesString)
            usersReference = databaseReference.child(FirechatUsersString)
            conversationNode = messagesReference
            self.fetchCurrentUser()
        }
    }
    
    func fetchCurrentUser() {
        fetchContactForKey(contactKey: (FIRAuth.auth()?.currentUser?.uid)!) { (contact) in
            self.currentUser = contact
        }
    }
    
    func signInToFirechat(username: String, password: String, CompletionHandler: @escaping (NSDictionary) -> () )
    {
        FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: { (user, error) in
            if(( error ) != nil)
            {
                print(error?.localizedDescription)
                CompletionHandler(["error": error])
            }
            
            if(( user ) != nil)
            {
                print("Sign in success")
                self.initializeNodes()
                CompletionHandler(["success": true])
            }
        })
    }
    
    func signUpWithFirechat(username: String, email: String, password: String, image: UIImage, CompletionHandler: @escaping (NSDictionary) -> () )
    {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if(( error ) != nil)
            {
                print(error?.localizedDescription)
                CompletionHandler(["error": error])
            }
            if(( user ) != nil)
            {
                var data = NSData()
                data = UIImageJPEGRepresentation(image, 0.8)! as NSData
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(FirechatUserPhotoString)"
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpg"
                
                let storageRef = FIRStorage.storage().reference()
                storageRef.child(filePath).put(data as Data, metadata: metaData, completion: { (storageMetadata, error ) in
                    if(( error ) != nil)
                    {
                        print(error?.localizedDescription)
                    }
                    else
                    {
                        let downloadURL = storageMetadata?.downloadURL()!.absoluteString
                        
                        
                        let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = storageMetadata?.downloadURL()
                        changeRequest?.commitChanges() { (error) in
                            if( error == nil )
                            {
                                print("Commit success")
                            }
                        }
                        //store downloadURL at database
                        let child = FIRDatabase.database().reference().child(FirechatUsersString).child(FIRAuth.auth()!.currentUser!.uid)
                        child.updateChildValues([FirechatUserPhotoString: downloadURL! as String])
                        child.updateChildValues([FirechatUserNameString: username])
                        child.updateChildValues([FirechatEmailString: email])
                        child.updateChildValues([FirechatKeyString: child.key as String])
                        child.updateChildValues([FirechatStatusString: FirechatDefaultStatus])
                        
                        self.initializeNodes()
                        CompletionHandler(["success": true])
                    }
                })
            }
        })
    }
    
    func logout(CompletionHandler: @escaping (Bool) -> ()) {
        try! FIRAuth.auth()?.signOut()
        CompletionHandler(true)
    }
    
    func fetchActiveConvoContactKeys(CompletionHandler: @escaping (NSDictionary) -> ())
    {
        self.messagesReference.observe(.value, with: { snapshot in
            if(snapshot.hasChildren())
            {
                let response = snapshot.value as! NSDictionary
                CompletionHandler(response)
            }
        })
    }
    
    func fetchContactForKey(contactKey: (String), CompletionHandler: @escaping (FirechatContact) -> () )
    {
        let ref = FIRDatabase.database().reference().child(FirechatUsersString).child(contactKey)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChildren())
            {
                let contact: FirechatContact = FirechatMappingModel.init().mapUserObject(user: snapshot.value as! NSDictionary)
                CompletionHandler(contact)
            }
        })
    }
    
    func fetchAllContacts(CompletionHandler: @escaping (NSArray) -> () )
    {
        self.usersReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let allContactsDictionary = snapshot.value as! NSDictionary
            let allContacts = NSMutableArray.init()
            let keysArray: NSArray = allContactsDictionary.allKeys as NSArray
            for index in 0 ..< keysArray.count
            {
                let contact = allContactsDictionary.object(forKey: keysArray.object(at: index)) as! NSDictionary
                let mappedContact = FirechatMappingModel.init().mapUserObject(user: contact) as FirechatContact
                if mappedContact.emailID != self.currentUser.emailID
                {
                    allContacts.add(mappedContact)
                }
            }
            CompletionHandler(allContacts as NSArray)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func checkIfConversationNodeExist(user: FirechatContact, CompletionHandler: @escaping (Bool) -> () )
    {
        self.activeConvoWithUser = user;
        let node = self.messagesReference;
        node.child(user.userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.hasChildren())
            {
                print("Node exists\(snapshot.value)")
                let response = snapshot.value as! NSDictionary
                self.conversationNode = FIRDatabase.database().reference().child(FirechatConversationsString).child(response.object(forKey: FirechatConvoKeyString) as! String)
            }
            else
            {
                self.conversationNode = FIRDatabase.database().reference().child(FirechatConversationsString).childByAutoId()
                node.child(user.userKey).setValue([FirechatConvoKeyString: self.conversationNode.key])
                //Add node to user profile
                FIRDatabase.database().reference().child(FirechatUsersString).child(user.userKey).child(FirechatMessagesString).child(self.currentUser.userKey).updateChildValues([FirechatConvoKeyString: self.conversationNode.key])
            }
            self.startObservingActiveConvo()
            CompletionHandler(true)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func startObservingActiveConvo()
    {
        self.conversationNode.observe(.childAdded, with: { snapshot in
            if snapshot.hasChildren() {
                let message = snapshot.value as! NSDictionary
                let notificationName = Notification.Name(NSNOTIFICATION_ActiveConvoObserver)
                NotificationCenter.default.post(name: notificationName, object: message)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    func removeActiveConvoObserver()
    {
        self.conversationNode.removeAllObservers()
    }
    
    func sendNewMessage( message: (String))
    {
        let convo = self.conversationNode.childByAutoId()
        print(FIRAuth.auth()?.currentUser?.displayName)
        
        let sender = self.currentUser.userKey
        let timestamp = FIRServerValue.timestamp()
        convo.setValue([FirechatSenderString: sender,
                        FirechatMessageTextString: message,
                        FirechatTimeString: timestamp] )
        self.messagesReference.child(self.activeConvoWithUser.userKey).updateChildValues([FirechatLastMessageString: message, FirechatTimeString: timestamp])
        FIRDatabase.database().reference().child(FirechatUsersString).child(self.activeConvoWithUser.userKey).child(FirechatMessagesString).child(self.currentUser.userKey).updateChildValues([FirechatLastMessageString: message, FirechatTimeString: timestamp])
    }
    
    func updateUserStatus(status: String, CompletionHandler: @escaping (Bool) -> ()) {
        let child = FIRDatabase.database().reference().child(FirechatUsersString).child(FIRAuth.auth()!.currentUser!.uid)
        child.updateChildValues([FirechatStatusString: status])
        self.fetchCurrentUser()
        CompletionHandler(true)
    }
    
}
