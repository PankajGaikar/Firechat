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
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    var keyboardFrame: CGRect = CGRect.init()
    
    let picker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Firechat
        navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped(img:)))
        
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        picker.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollview.contentSize = self.parentView.frame.size
        self.scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @IBAction func signUpAction(_ sender: AnyObject) {
        self.loader.startAnimating()
        self.loader.isHidden = false
        self.parentView.isUserInteractionEnabled = false
        FirechatManager.sharedManager.signUpWithFirechat(username: self.usernameTxt.text!,email: self.emailTxt.text! ,password: self.passwordTxt.text!, image: self.profileImage.image!) { (result) in
            var success: Bool = false
            if( result.value(forKey: "success") != nil ){
                success = result.value(forKey: "success") as! Bool
            }
            
            var error: NSError? = nil
            
            if( result.value(forKey: "error") != nil ){
                error = result.value(forKey: "error") as? NSError
            }
            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ActiveConversationsViewController") as! ActiveConversationsViewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            else
            {
                let alert = UIAlertController(title: "Warning", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.loader.stopAnimating()
                self.loader.isHidden = true
                self.parentView.isUserInteractionEnabled = true
            }
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage=textField.tag+1;
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
        }
        
        if( textField.tag == 2 )
        {
            self.signUpAction(self)
        }
        return true
    }
    
    func keyboardWasShown(notification: NSNotification){
        keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }

    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField.frame.origin.y + textField.frame.size.height + 20 + self.parentView.frame.origin.y) > keyboardFrame.origin.y {
            if( ((textField.frame.origin.y + textField.frame.size.height + 20 + self.parentView.frame.origin.y) - keyboardFrame.origin.y) < 150 )
            {
                let point: CGPoint = CGPoint(x: 0, y: ((textField.frame.origin.y + textField.frame.size.height + 20 + self.parentView.frame.origin.y) - keyboardFrame.origin.y))
                self.scrollview.setContentOffset(point, animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
