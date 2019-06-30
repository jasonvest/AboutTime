//
//  FinalScoreController.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/29/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import UIKit

class FinalScoreController: UIViewController    {
    @IBOutlet weak var finalScoreLabel: UILabel!
    var delegate: GameOverProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle  {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let finalScore = delegate?.finalQuizScore()  {
            finalScoreLabel.text = finalScore
        } else {
            finalScoreLabel.text = "0/0"
        }
        finalScoreLabel.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func playAgain(_ sender: Any) {
        delegate?.nextGame()
        dismiss(animated: true, completion: nil)
    }
}
