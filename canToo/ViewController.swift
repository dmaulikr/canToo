//
//  ViewController.swift
//  canToo
//
//  Checks for touch 
//  Retrieves DB information
//  Parses through JSON
//  Fires local notifications
//  Manages segue and passes information through it
//
//  Created by Maxiel De Jesus on 4/5/17.
//  Copyright © 2017 Maxiel De Jesus. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import Darwin


class ViewController: UIViewController {
    
    // Properties

    @IBOutlet weak var toucanTut: UIImageView!
    @IBOutlet weak var canTooLabel: UILabel!
    
    @IBOutlet weak var settingsGear: UIImageView!
    
    var defaults = UserDefaults.standard
        
    let quoteArray: NSMutableArray = NSMutableArray()
    
    let tapRecon = UITapGestureRecognizer()
    
    var previousQuote : UInt32 = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Recognizes if image was touched
        
        tapRecon.addTarget(self, action: #selector(ViewController.tappedView))
        
        toucanTut.isUserInteractionEnabled = true
        toucanTut.addGestureRecognizer(tapRecon)
        
        //Retrieves data from DB and handles it

        let urlPath: String = "https://web.njit.edu/~mid6/service.php"
        
        if let url = URL(string: urlPath){
            
            if let data = try? Data(contentsOf: url){
                let json = try? JSON(data: data)
                
                //print(json!)
                
                parse(json: json!)
                
            }
        }

    }
    
    //Actions
    
    // When image is tapped direct to appropriate view via segue
    
    @IBAction func tappedView() {
        

        self.performSegue(withIdentifier: "popUpSegue", sender: self)
            

    }
    
    // Parses through json recieved from DB
    
    func parse(json: JSON) {
        
        for(i , object) in json{
            
            let quote = object["quote"].stringValue
            let author = object["author"].stringValue
            
            //print(quote)
            
            let data = IncomingData()
            
            data.quote = quote
            data.author = author
            
            quoteArray.add(data)
           
            //print(data)
        }
        
        // Runs notifications once quotes are recieved
        
        appointmentNotification()

    }
    
    // Segue preparation. Passes array of quotes with segue to the PopUpViewController.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "popUpSegue"
        {
            if let destinationVC = segue.destination as? PopUpViewController {
                destinationVC.newArray = quoteArray
            }
        }
        
    }
    
    
    //Creates local notifications
    
    func appointmentNotification(){
        
        var randomQuote = arc4random_uniform(UInt32(quoteArray.count))
        
        let interval = 60.0
        
        var defaultTime: Double
        
        let time = UserDefaults().double(forKey: "NotificationStepperValue")
            
        switch time{
        case 1,2,3:
            defaultTime = interval * time
            
        default:
            defaultTime = interval
            break;
            
        }
        
     
        while previousQuote == randomQuote{
            randomQuote = arc4random_uniform(UInt32(quoteArray.count))
        }
        previousQuote = randomQuote
        
        let content = UNMutableNotificationContent()
        content.title = "Just when you think you can't..."
        content.body = String(describing: quoteArray[Int(randomQuote)])
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: defaultTime, repeats: false)
        
        let request = UNNotificationRequest.init(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error as Any)
        }
        print ("Should recieve notification")
        
    }
    
    
 
}


