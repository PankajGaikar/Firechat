//
//  SignUpViewController.swift
//  Firechat
//
//  Created by Pankaj Gaikar on 03/12/16.
//  Copyright © 2016 Tricks Machine. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    let picker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped(img:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        picker.delegate = self
    }
    
    @IBAction func signInAction(_ sender: AnyObject) {
       _ = self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
        FIRAuth.auth()?.createUser(withEmail: emailTxt.text!, password: passwordTxt.text!, completion: { (user, error) in
            if(( error ) != nil)
            {
                print(error?.localizedDescription)
            }
            if(( user ) != nil)
            {
                var data = NSData()
                data = UIImageJPEGRepresentation(self.profileImage.image!, 0.8)! as NSData
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
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
                        //store downloadURL at database
                        let child = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
                        
                        child.updateChildValues(["userPhoto": downloadURL! as String])
                        child.updateChildValues(["username": self.usernameTxt.text! as String])
                        child.updateChildValues(["email": self.emailTxt.text! as String])
                        child.updateChildValues(["key": child.key as String])                        
                        self.performSegue(withIdentifier: "UserCreated", sender: self)
                    }
                })
            }
        })
    }
    
    func imageTapped(img: AnyObject)
    {
        print("Image tapped")
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profileImage.contentMode = .scaleAspectFit
        self.profileImage.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
