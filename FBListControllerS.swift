//
//  FBListController.swift
//  AimeFire
//
//  Created by clark on 2017/2/28.
//  Copyright © 2017年 Linda. All rights reserved.
//



import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class FBListControllerS: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var facebookTableView: UITableView!
    
    var ref: FIRDatabaseReference!
    
    var uidListArr = [AnyObject]()
    
    var dict : [String : AnyObject]!
    
    var urlArray = [AnyObject]()
    
    var handle : [String : AnyObject]!
    
    var nameData = [AnyObject]()
    
    var urlData = [AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = FIRAuth.auth()?.currentUser
        
        let uid = user?.uid;
        
        //print(uid)
        
        FIRDatabase.database().reference().child("friendList").child(uid!).observe(.value, with: {(snapshot) in
            
            //self.uidList = snapshot.value as? [String : AnyObject]
            
            print(snapshot.value as Any)
            
            if snapshot.value is NSNull {
                
                //self.uidListArr.append("尚未新增好友" as AnyObject)
                
                
                
            }else {
                
                self.uidListArr = (snapshot.value as? [AnyObject])!
                
            }
                        print(self.uidListArr)
            //
            //            print(self.uidListArr.count)
            
            
        }, withCancel: nil)
        
        
        facebookTableView.dataSource = self
        
        facebookDataLoad()
        
        
    }
    
    
    func facebookDataLoad() {
        
        FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil){
                self.dict = result as! [String : AnyObject]
                //print(result!)
                //print(dict["data"]!)
                
                self.urlArray = self.dict["data"] as! Array
                
                //let data = try? JSONSerialization.data(withJSONObject: result as! [String : AnyObject], options: [])
                //
                //
                //let json = try? JSONSerialization.jsonObject(with: data!,options:.allowFragments) as! [String: Any]
                
                //print(json)
                
                //let name = json?["data"]
                //let picture = (json?["picture"] as! [String: Any])["data"]
                //print(name)
                
                //print(picture)
                //print(self.urlArray)
                
                
                for index in self.urlArray {
                    
                    //                    for (key, value) in index as! NSDictionary {
                    //
                    //                        self.handle = (index["picture"] as! [String: AnyObject])["data"] as! [String : AnyObject]!
                    //
                    //                      self.nameData = index["name"] as! [String]
                    //
                    //                       print(data?["url"]! as Any)
                    //
                    //                       print(data?["url"]! as Any)
                    //
                    //                        //print(self.handle)
                    //
                    //                    }
                    
                    let handle = (index["picture"] as! [String : AnyObject])["data"] as! [String :AnyObject]
                    
                    self.urlData += [handle["url"]!]
                    
                    self.nameData += [index["name"]! as AnyObject]
                    
                    //print(self.nameData)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.facebookTableView.reloadData()
            }
            
        })
        
        
    }
    
    
    
    // MARK: - TableView
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.nameData.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = facebookTableView.dequeueReusableCell(withIdentifier: "FBTable", for: indexPath)
        
        cell.textLabel?.text = nameData[indexPath.row] as? String
        
        
        
        
        cell.imageView?.image = UIImage(named:"loading.png")
        
        //print(urlData[indexPath.row])
        
        //把urlData 這個Array的URL字串丟進handle
        let handle = self.urlData[indexPath.row] as? String
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //handle字串轉URL
            let url = NSURL(string:handle!)
            
            //print(url!)
            
            //url 轉NSData 丟到imageData
            let imageData = NSData(contentsOf: url! as URL)
            
            DispatchQueue.main.async {
                
                let cell: UITableViewCell = self.facebookTableView.cellForRow(at: indexPath)!
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
        
        insert["name"] = nameData[buttonRow!]
        insert["picture"] = urlData[buttonRow!]
        insert["type"] = "FB好友" as AnyObject?
        
        let user = FIRAuth.auth()?.currentUser
        
        let uid = user?.uid
        
        //        print(uid!)
        //
        //        print(insert)
        
        self.ref = FIRDatabase.database().reference()
        
        let count : String = "\(self.uidListArr.count)"
        
        //print(count)
        
        self.ref.child("friendList").child(uid!).child(count).updateChildValues(insert)
        
        
    }
    
    
    
}
