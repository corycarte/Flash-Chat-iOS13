//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true;
        navigationItem.title = K.appName
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970],
                completion: {
                (error) in if let e = error{
                    print("Error saving to Firestore: \(e)")
                }
                else {
                    print("Data saved to Firestore!")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            })
        }
    }
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener
        {
            (querySnapshot, error) in
            if let e = error {
                print("Error loading messages: \(e)")
                return
            }
            
            if let snapshotDocuments = querySnapshot?.documents {
                self.messages = []
                for doc in snapshotDocuments {
                    let data = doc.data()
                    if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                        self.messages.append(Message(sender: messageSender, body: messageBody))
                        
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.reloadData()
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.label.text = message.body

        // Is message from current logged in user?
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.MessageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.MessageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        
        
        return cell
    }
    
}
