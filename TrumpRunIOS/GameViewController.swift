//
//  GameViewController.swift
//  TrumpRunIOS
//
//  Created by Luis F. Perrone on 2/3/18.
//  Copyright © 2018 TrumpRun. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: BaseViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var helpView: UIView!
    
    
    @IBAction func buttonAction(_ sender: Any) {
        switch ((sender as! UIButton).tag) {
        case 0:
             let trumpRunViewController = UIStoryboard.viewControllerMain(identifier: "trumpRunViewController") as! TrumpRunViewController
            self.navigationController?.present(trumpRunViewController, animated: false, completion: nil)
            break
        case 1:
            let helpViewControlller = UIStoryboard.viewControllerMain(identifier: "helpViewController") as! HelpViewController
            self.navigationController?.present(helpViewControlller, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        prepare()
    }
    
    func prepare() {
        playButton.layer.cornerRadius = 6
        helpView.layer.cornerRadius = helpView.frame.width/2
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
