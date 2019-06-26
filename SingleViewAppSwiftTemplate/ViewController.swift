//
//  ViewController.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Treehouse on 12/8/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    @IBOutlet weak var firstEventLabel: UILabel!
    @IBOutlet weak var secondEventLabel: UILabel!
    @IBOutlet weak var thirdEventLabel: UILabel!
    @IBOutlet weak var fourthEventLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var roundMessageLabel: UILabel!
    @IBOutlet weak var firstEventDownButton: UIButton!
    @IBOutlet weak var secondEventUpButton: UIButton!
    @IBOutlet weak var secondEventDownButton: UIButton!
    @IBOutlet weak var thirdEventUpButton: UIButton!
    @IBOutlet weak var thirdEventDownButton: UIButton!
    @IBOutlet weak var fourthEventUpButton: UIButton!
    @IBOutlet weak var nextRoundButton: UIButton!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    
    
    let numberOfRounds = 6
    let numberOfEvents = 4
    let roundLength = 59
    var quizManager: QuizManager
    var roundTimer: Timer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle  {
        return .lightContent
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake   {
            completeRound(timeUp: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        do  {
            let dictionary = try PlistConverter.dictionary(fromFile: EventGroup.WorldWarIIEvents.rawValue, ofType: "plist")
            
            let eventsList = try EventLoader.quizEvents(fromDictionary: dictionary)
            
            self.quizManager = WorldWarIIQuizManager.init(numberOfRounds: numberOfRounds, numberOfEvents: numberOfEvents, roundLength: roundLength, events: eventsList)
        } catch let error   {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Researched on Stack Overflow
        let touch = UITapGestureRecognizer(target: self, action: #selector(touchFunction))
        let labels = labelArray()
        for label in labels {
            label.addGestureRecognizer(touch)
        }
        //Start first round of game
        startGameRound()
    }
    
    @objc func touchFunction(sender: UITapGestureRecognizer, infoURL: String)    {
        guard let url =  URL(string: infoURL) else  {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func labelArray() -> [UILabel]  {
        let labelSet: [UILabel] = [firstEventLabel,
                                   secondEventLabel,
                                   thirdEventLabel,
                                   fourthEventLabel]
        return labelSet
    }
    
    func buttonArray() -> [UIButton]  {
        let buttonSet: [UIButton] = [firstEventDownButton,
                                     secondEventUpButton,
                                     secondEventDownButton,
                                     thirdEventUpButton,
                                     thirdEventDownButton,
                                     fourthEventUpButton]
        return buttonSet
    }
    func populateLables() -> Void   {
        let labelSet = labelArray()
        for index in 0..<labelSet.count   {
            labelSet[index].text = quizManager.eventSet[index].eventDescription
        }
    }
    
    //Format time into the number of seconds
    func formatTimeDisplay(_ totalSeconds: Int) -> String    {
        let seconds: Int = totalSeconds % 60
        let results = String(format: "0:%02d", seconds)
        return results
    }
    
    //Update the countdown time displayed and the progress indicator
    @objc func updateTimerDisplay() -> Void   {
        timerLabel.text = "\(formatTimeDisplay(self.quizManager.roundLength))"
        if self.quizManager.roundLength != 0  {
            self.quizManager.roundLength -= 1
        } else  {
            stopTimer()
            completeRound(timeUp: true)
        }
    }
    
    //Stop the timer
    func stopTimer() -> Void {
        self.roundTimer.invalidate()
    }
    
    func completeRound(timeUp: Bool) -> Void  {
        let eventsAreInOrder = quizManager.checkAnswer()
        timerLabel.isHidden = true
        timerLabel.text = "0:59"
        
        if eventsAreInOrder {
            nextRoundButton.setImage(UIImage(named: "next_round_success.png"), for: .normal)
        } else  {
            nextRoundButton.setImage(UIImage(named: "next_round_fail.png"), for: .normal)
        }
        if !timeUp  {
            stopTimer()
        }
        self.quizManager.roundLength = roundLength
        self.quizManager.getRandomEvents()
        nextRoundButton.isHidden = false
        
        roundMessageLabel.text = "Tap events to learn more"
    }
    
    
    func startGameRound() -> Void   {
        let labels = labelArray()
        let buttons = buttonArray()
        
        for label in labels  {
            label.isHidden = false
        }
        for button in buttons   {
            button.isHidden = false
        }
        finalScoreLabel.isHidden = true
        playAgainButton.isHidden = true
        
        if self.quizManager.isGameComplete()  {
            //Call end of game function
            endOfGame()
        } else  {
            populateLables()
            roundTimer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(updateTimerDisplay),
                                              userInfo: nil,
                                              repeats: true)
            roundMessageLabel.text = "Shake to complete"
            roundMessageLabel.isHidden = false
            nextRoundButton.isHidden = true
            timerLabel.isHidden = false
        }
    }
    
    func endOfGame() -> Void    {
        let labels = labelArray()
        let buttons = buttonArray()
        
        for label in labels  {
            label.isHidden = true
        }
        for button in buttons   {
            button.isHidden = true
        }
        timerLabel.isHidden = true
        nextRoundButton.isHidden = true
        roundMessageLabel.isHidden = true
        
        finalScoreLabel.text = "\(quizManager.numberOfCorrectRounds)/\(quizManager.numberOfRounds)"
        finalScoreLabel.isHidden = false
        playAgainButton.isHidden = false
    }
    
    @IBAction func reorderEvents(_ sender: UIButton) {
        var firstPosition: Int = 0
        var secondPosition: Int = 0
        if sender === firstEventDownButton  {
            firstPosition = 0
            secondPosition = 1
        } else if sender === secondEventUpButton    {
            firstPosition = 1
            secondPosition = 0
        } else if sender === secondEventDownButton  {
            firstPosition = 1
            secondPosition = 2
        } else if sender === thirdEventUpButton {
            firstPosition = 2
            secondPosition = 1
        } else if sender === thirdEventDownButton   {
            firstPosition = 2
            secondPosition = 3
        } else if sender === fourthEventUpButton    {
            firstPosition = 3
            secondPosition = 2
        }
        if firstPosition != secondPosition  {
            self.quizManager.changeEventOrder(firstPosition: firstPosition, secondPostion: secondPosition)
            populateLables()
        }
    }
    
    @IBAction func nextRound(_ sender: UIButton) {
        startGameRound()
    }
    
    @IBAction func playAgain(_ sender: UIButton) {
        quizManager.resetGame()
        startGameRound()
    }
    
    
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if sender === firstEventDownButton  {
            sender.setImage(UIImage(named: "down_full_selected.png"), for: .highlighted)
        } else if sender === secondEventUpButton || sender === thirdEventUpButton    {
            sender.setImage(UIImage(named: "up_half_selected.png"), for: .highlighted)
        } else if sender === secondEventDownButton || sender === thirdEventDownButton   {
            sender.setImage(UIImage(named: "down_half_selected.png"), for: .highlighted)
        } else if sender === fourthEventUpButton    {
            sender.setImage(UIImage(named: "up_full_selected.png"), for: .highlighted)
        }
    }
}

