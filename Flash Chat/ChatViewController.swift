//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import UserNotifications


class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource , UITextFieldDelegate{
    
    
    
    // Declare instance variables here
    var messageArray  : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hide back button from navigation Item
        self.navigationItem.setHidesBackButton(true, animated:true);

        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:

        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        
        configureTableView()

        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
    }
    
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        
        // colors
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as! String {
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }else{
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
    
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.delegate = self
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    
    func configureTableView(){
        
        //messageTextfield.delegate = self
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120
       
        
        
      
    }
    
  
    //MARK: - getKayboardHeight
    // observer
    func addovserverkeybordTocalc()  {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    // calculate keyboard hight
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        // do whatever you want with this keyboard height

        
        // create userdefult
        
        UserDefaults.standard.set(Double(keyboardHeight), forKey: "key")
        
    }

    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
    }
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        // animation
        addovserverkeybordTocalc()
        UIView.animate(withDuration: 0.4) {
          
            // get device model to calc space between keyboard and message text field according to mobile device
            let modelName = UIDevice.modelName
            if (modelName != ("iPhone XR" )) && (modelName != ("iPhone X" )){
                self.heightConstraint.constant = CGFloat(UserDefaults.standard.double(forKey: "key") + 45)//360
            }else{
                self.heightConstraint.constant = CGFloat(UserDefaults.standard.double(forKey: "key") + 10)//360
            }
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    
    //TODO: Declare textFieldDidEndEditing here:
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // animation
        UIView.animate(withDuration: 0.29) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
            
        }
    }
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.delegate = nil
        //TODO: Send the message to Firebase and save it in our database

        // end editing
        //messageTextfield.endEditing(true)
        //messageTextfield.isEnabled = false
        sendButton.isEnabled = false

        // create chiled DB
        let messagesDB = Database.database().reference().child("Messages")

        let messageDictionary = ["Sender":Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error,reference) in

            if error != nil {

                print(error!)
            }else{
                print("Message saved successfully!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
//
//
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { (Snapshot) in
            
            let snapshotValue = Snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            var objMessage = Message()
            
            objMessage.sender = sender
            objMessage.messageBody = text
            
            self.messageArray.append(objMessage)
            self.configureTableView()
            self.messageTableView.reloadData()
           
            let indexPath = NSIndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            
        }
        
        
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
                print("error , there was a problem signing out")
        }
        
        
        
    }
    


}
