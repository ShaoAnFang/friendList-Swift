//
//  PhoneContactController.swift
//  AimeFire
//
//  Created by clark on 2017/2/28.
//  Copyright © 2017年 Linda. All rights reserved.
//

import UIKit
import Contacts
import Firebase
import FirebaseAuth

@available(iOS 10.0, *)
class PhoneContactControllerS: UIViewController, UITableViewDataSource  {
    
    @IBOutlet weak var contactTableView: UITableView!
    
    var ref: FIRDatabaseReference!
    
    var getInfo = [String : AnyObject]()
    
    var uidListArr = [AnyObject]()
    
    var nameArrayData = [String]()
    
    var phoneArrayData = [String]()
    
    
    var list = [AnyObject]()
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey,] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = FIRAuth.auth()?.currentUser
        
        let uid = user?.uid;
        
        //print(uid)
        
        FIRDatabase.database().reference().child("friendList").child(uid!).observe(.value, with: {(snapshot) in
            
            //self.uidList = snapshot.value as? [String : AnyObject]
            
            if snapshot.value is NSNull {
                
            
            }else {
            
            self.uidListArr = (snapshot.value as? [AnyObject])!
                
            }
            //            print(self.uidListArr)
            //
            //            print(self.uidListArr.count)
            
            
        }, withCancel: nil)
        
        contactTableView.dataSource = self
       

        //print(contacts)
        
        var firstName : String
        var lastName : String
        var fullName : String
        var phone : String
        
        var contactNumbersArray = [Any]()
        
        for contact in self.contacts {
            
            firstName = contact.givenName
            lastName = contact.familyName
            
            if lastName.isEmpty {
                fullName = "\(firstName)"
            }
            else if firstName.isEmpty {
                fullName = "\(lastName)"
            }
            else {
                fullName = "\(firstName) \(lastName)"
            }
            
            for label: CNLabeledValue in contact.phoneNumbers {
                phone = label.value.stringValue
                if phone.characters.count > 0 {
                    contactNumbersArray.append(phone)
                }
                
                getInfo["phone"] = phone as AnyObject?
            }

            getInfo["name"] = fullName as AnyObject?
            
            
            self.nameArrayData.append((getInfo["name"] as? String)!)
            
            self.phoneArrayData.append((getInfo["phone"] as? String)!)
            
        }
        
        //print(getInfo)
        print(nameArrayData)
        print(phoneArrayData)
        //findContacts()
     
        //print(getInfo)
    }
    
    
    func findContacts () -> [CNContact]{
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        var contacts = [CNContact]()
        
        self.list = contacts
        
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .userDefault
        
        //let contactStoreID = CNContactStore().defaultContainerIdentifier()
        //print("\(contactStoreID)")
        
            
        do {
            
            try CNContactStore().enumerateContacts(with: fetchRequest) { ( contact, stop) -> Void in
                
                if contact.phoneNumbers.count > 0 {
                    contacts.append(contact)
                }
                
                //print(contacts)
            }
            
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        DispatchQueue.main.async {
        
            self.contactTableView .reloadData()
            
        }
        
        return contacts
        
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nameArrayData.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "contantTable", for: indexPath)
        

        cell.textLabel?.text = nameArrayData[indexPath.row]
        cell.detailTextLabel?.text = phoneArrayData[indexPath.row]
        
        cell.imageView?.image = UIImage(named:"loading.png")
        
        //print(urlData[indexPath.row])
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //handle字串轉URL
            let url = NSURL(string:"http://i.imgur.com/F3NTeqA.png")
            
            //print(url!)
            
            //url 轉NSData 丟到imageData
            let imageData = NSData(contentsOf: url! as URL)
            
            DispatchQueue.main.async {
                
                let cell: UITableViewCell = self.contactTableView.cellForRow(at: indexPath)!
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2.0
                cell.imageView?.clipsToBounds = true
                
                //imageData 傳給imageView
                cell.imageView?.image =  UIImage(data: imageData as! Data)
            }
            
        }
        
        let buttonRect = CGRect(x: CGFloat(250), y: CGFloat(15), width: CGFloat(65), height: CGFloat(25))
        let button = UIButton(type: .roundedRect)
        button.frame = buttonRect
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.layer.borderColor = self.view.tintColor.cgColor
        button.setTitle("加好友", for: .normal)
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(self.addFriend), for: UIControlEvents.touchUpInside)
        cell.contentView.addSubview(button)

        
        
        return cell
    }
    
    @IBAction func addFriend(_ sender: Any) {
        
        let buttonRow = (sender as AnyObject).tag
        
        //print(buttonRow!)
        
        //var indexStr: String = "\(buttonRow)"
        
        var insert = [String : AnyObject]()
        
        insert["name"] = nameArrayData[buttonRow!] as AnyObject?
        insert["picture"] = "http://i.imgur.com/F3NTeqA.png" as AnyObject?
        insert["type"] = "手機聯絡人好友" as AnyObject?
        
        let user = FIRAuth.auth()?.currentUser
        
        let uid = user?.uid
        
        //        print(uid!)
        //
        //        print(insert)
        
        self.ref = FIRDatabase.database().reference()
        
        let count : String = "\(self.uidListArr.count)"
        
        //print(count)
        
        self.ref.child("friendList").child(uid!).child(count).updateChildValues(insert)
        
        //self.delegate.didFinishUpdateFacebookFriend()
        
        
    }

    
    
}
