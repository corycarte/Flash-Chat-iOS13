//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        if let userEmail = emailTextfield.text, let userPass = passwordTextfield.text {
                print("Authenticate with...\nEmail: \(userEmail)\nPass:  \(userPass)")
            emailTextfield.text = ""
            passwordTextfield.text = ""
            Auth.auth().signIn(withEmail: userEmail, password: userPass) { [weak self] authResult, error in
                if let e = error {
                    print(e)
                    return
                }
                guard let strongSelf = self else { return }
              
                strongSelf.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
        }
    }
    
}
