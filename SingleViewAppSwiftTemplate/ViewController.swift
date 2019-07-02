//
//  ViewController.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Treehouse on 12/8/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import SafariServices

protocol GameOverProtocol {
    func finalQuizScore() -> String
    func nextGame() -> Void
}

class ViewController: UIViewController, GameOverProtocol {
    @IBOutlet var eventButtons: [UIButton]!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var roundMessageLabel: UILabel!
    @IBOutlet weak var firstEventDownButton: UIButton!
    @IBOutlet weak var secondEventUpButton: UIButton!
    @IBOutlet weak var secondEventDownButton: UIButton!
    @IBOutlet weak var thirdEventUpButton: UIButton!
    @IBOutlet weak var thirdEventDownButton: UIButton!
    @IBOutlet weak var fourthEventUpButton: UIButton!
    @IBOutlet weak var nextRoundButton: UIButton!

    let numberOfRounds = 6
    let numberOfEvents = 4
    let roundLength = 59
    let quizManager: QuizManager
    var roundTimer: Timer!
    let soundManager = SoundManager()

    
    override var preferredStatusBarStyle: UIStatusBarStyle  {
        return .lightContent
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake   {
            completeRound(isTimeUp: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        do  {
            let eventsList = try EventLoader.quizEvents(fromFile: EventGroup.WorldWarIIEvents.rawValue, ofType: "plist")
            
            self.quizManager = WorldWarIIQuizManager.init(numberOfRounds: numberOfRounds, numberOfEvents: numberOfEvents, roundLength: roundLength, events: eventsList)
        } catch let error   {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set wrapping options on buttons
        for eventButton in eventButtons {
            eventButton.titleLabel?.numberOfLines = 0
            eventButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
        startGameRound()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helper Functions
    
    //Function to setup segue for final score - Researched on developer.apple.com
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FinalScoreController {
            destination.delegate = self
        }
    }
    
    //Update labels with events
    func populateLables() -> Void   {
        var index: Int = 0
        for button in eventButtons  {
            button.setTitle(quizManager.eventSet[index].eventDescription, for: .normal)
            index += 1
        }
    }
    
    //Function called to enable or disable gesture recognizers
    func enableUserInteraction(isEnabled: Bool) -> Void {
        for eventButton in eventButtons  {
            eventButton.isUserInteractionEnabled = isEnabled
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
            quizManager.adjustCounter(decreaseBy: 1, isReset: false, roundLength: roundLength)
        } else  {
            stopTimer()
            completeRound(isTimeUp: true)
        }
    }
    
    //Stop the timer
    func stopTimer() -> Void {
        self.roundTimer.invalidate()
    }
    
    //Return quiz score
    func finalQuizScore() -> String   {
        return "\(quizManager.numberOfCorrectRounds)/\(quizManager.numberOfRounds)"
    }
    
    //Called when next game begins
    func nextGame() -> Void {
        quizManager.resetGame()
        startGameRound()
    }
    
    //Display alert if the event has no URL associated with it
    func showAlert(with title: String, message: String, alertStyle: UIAlertController.Style = .alert)    {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: alertStyle
        )
        
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //Function called when either the device is shaked or time runs out indicating the round is over
    func completeRound(isTimeUp: Bool) -> Void  {
        let eventsAreInOrder = quizManager.checkAnswer()
        timerLabel.isHidden = true
        timerLabel.text = "0:59"
        
        //Displays correct button based on success or failure
        if eventsAreInOrder {
            nextRoundButton.setImage(UIImage(named: "next_round_success.png"), for: .normal)
            soundManager.playSelectedSound(soundManager.correctSound)
        } else  {
            nextRoundButton.setImage(UIImage(named: "next_round_fail.png"), for: .normal)
            soundManager.playSelectedSound(soundManager.wrongSound)
        }
        if !isTimeUp  {
            stopTimer()
        }
        //Updates UI elements and enables gestures on the event labels to call up wikipedia pages
        nextRoundButton.isHidden = false
        enableUserInteraction(isEnabled: true)
        roundMessageLabel.text = "Tap events to learn more"
    }
    
    ///Starts a round of the game and checks to see if the game is over before presenting the questions
    func startGameRound() -> Void   {
        //Disable gestures during the round
        enableUserInteraction(isEnabled: false)
        
        //Check to see if the game is complete or the round should be started
        if self.quizManager.isGameComplete()  {
            //Call end of game function
            endOfGame()
        } else  {
            quizManager.adjustCounter(decreaseBy: 0, isReset: true, roundLength: roundLength)
            self.quizManager.getRandomEvents()
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
    
    ///Function called when the game is complete, updates UI to display score and play again button
    func endOfGame() -> Void    {
        let scorePercentage = Double(quizManager.numberOfCorrectRounds)/Double(quizManager.numberOfRounds)
        switch scorePercentage  {
        case 1.0:
            soundManager.playSelectedSound(soundManager.perfectGameSound)
        case 0.75..<100.0:
            soundManager.playSelectedSound(soundManager.perfectGameSound)
        case 0.50..<0.75:
            soundManager.playSelectedSound(soundManager.wompSound)
        case 0.00..<0.50:
            soundManager.playSelectedSound(soundManager.wompSound)
        default:
            break
        }
        //Researched on developer.apple.com
        performSegue(withIdentifier: "finalScore", sender: nil)
    }
    
    ///Calls reoorder function based on UI input and updates UI when complete
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
    
    ///Starts another round of the game
    @IBAction func nextRound(_ sender: UIButton) {
        startGameRound()
    }
    
    ///Checks sender and looks up URL for the event associated with the button
    @IBAction func displayEventInfo(_ sender: UIButton) {
        var eventURL: String = ""
        guard let eventDescription = sender.title(for: .normal) else {
            return
        }
        
        for event in quizManager.eventSet   {
            if eventDescription == event.eventDescription   {
                eventURL = event.eventURL
            }
        }
        guard let url =  URL(string: eventURL) else  {
            showAlert(with: "Error", message: "Sorry, that event does not have a Wikipedia page.")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
}
    ///Updates button UI based on when the button is pressed
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

