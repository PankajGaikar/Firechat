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

class FirechatManager: NSObject
{
    var databaseReference: FIRDatabaseReference;
    var messagesReference: FIRDatabaseReference;
    var usersReference: FIRDatabaseReference;
    var user: FIRUser;
    var currentUser: FirechatContact = FirechatContact();
    
    static let sharedManager = FirechatManager()

    private override init() {
        FIRDatabase.database().persistenceEnabled = true
        databaseReference = FIRDatabase.database().reference()
        databaseReference.keepSynced(true)
        user = (FIRAuth.auth()?.currentUser)!;
        messagesReference = databaseReference.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("Messages")
        usersReference = databaseReference.child("users")
        super.init()
        fetchContactForKey(contactKey: self.user.uid) { (contact) in
            self.currentUser = contact
        }
    }
    
    //@TODO: Remove duplicate method
    func fetchUser(userKey: (String), CompletionHandler: @escaping (FirechatContact) -> ())
    {
        self.usersReference.child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
            CompletionHandler(FirechatMappingModel.init().mapUserObject(user: snapshot.value as! NSDictionary))
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchActiveConvoContactKeys(CompletionHandler: @escaping (NSArray) -> ())
    {
        self.messagesReference.observe(.value, with: { snapshot in
            if(snapshot.hasChildren())
            {
                let response = snapshot.value as! NSDictionary
                CompletionHandler(response.allKeys as NSArray)
            }
        })
    }
    
    func fetchContactForKey(contactKey: (String), CompletionHandler: @escaping (FirechatContact) -> () )
    {
        let ref = FIRDatabase.database().reference().child("users").child(contactKey)
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
                allContacts.add(FirechatMappingModel.init().mapUserObject(user: contact))
            }
            CompletionHandler(allContacts as NSArray)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func sendNewMessage( message: (String))
    {
        
    }
}
