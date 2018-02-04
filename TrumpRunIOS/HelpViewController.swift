//
//  HelpViewController.swift
//  TrumpRunIOS
//
//  Created by Marcial Cabrera on 2/3/18.
//  Copyright © 2018 TrumpRun. All rights reserved.
//

import UIKit

class HelpViewController: BaseViewController {

    @IBOutlet weak var gifView: UIImageView!
    
    @IBOutlet weak var helpbackButton: UIButton!
   
    @IBOutlet weak var helpbackButton_2: UIButton!
    
    @IBAction func buttonAction(_ sender: Any) {
        
        switch ((sender as! UIButton).tag) {
        case 0:
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
            break
            
        case 1:
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            break
            
        default:
            break
            
            
    }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.loadGif(name: "trump_running")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
