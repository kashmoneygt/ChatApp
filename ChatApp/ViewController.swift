//
//  ViewController.swift
//  ChatApp
//
//  Created by Kashyap Patel on 2/28/17.
//  Copyright © 2017 Kashyap Patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var root:FIRDatabaseReference!
    
    var messages:[Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        root = FIRDatabase.database().reference()
        
        observeMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeMessages() {
        let messagesRef = root.child("messages")
        
        messagesRef.observe(.childAdded, with: { snapshot in
            if let value = snapshot.value as? [String: Any],
                let text = value["text"] as? String,
                let timeInterval = value["date"] as? TimeInterval{
                
                let text = value["text"] as! String
                
                let timeInterval = value["date"] as! TimeInterval
                let date = Date(timeIntervalSince1970: timeInterval)
                
                let m = Message(text: text, date: date)
                
                self.messages.append(m)
                
                self.tableView.reloadData()
                
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        })
    }
    

    @IBAction func sendMessage(_ sender: UIButton) {
        let messagesRef = root.child("messages").childByAutoId()
        
        let data:[String : Any] = [
            "text": textField.text ?? "john sucks",
            "date": Date().timeIntervalSince1970
        ]
        
        messagesRef.setValue(data)
        
        textField.text = ""
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = message.date.description
        
        return cell
    }

    
}


struct Message {
    
    var text:String
    var date:Date = Date()
    
}
