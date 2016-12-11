//
//  FirechatMappingModel.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 09/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import Foundation

class FirechatMappingModel: NSObject {
    func mapUserObject(user: NSDictionary) -> FirechatContact
    {
        let contact = FirechatContact.init();
        contact.emailID = user.value(forKey: "email") as! String
        contact.username = user.value(forKey: "username") as! String
        contact.userKey = user.value(forKey: "key") as! String
        let convoKeys: NSDictionary = (user.value(forKey: "Messages") != nil) ? user.value(forKey: "Messages") as! NSDictionary : NSDictionary.init()
        contact.convoKeys = convoKeys.allValues as! NSArray
        contact.userPhotoURI = user.value(forKey: "userPhoto") as! String
        return contact
    }
}
