//
//  ViewController.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Treehouse on 12/8/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var firstEventLabel: UILabel!
    @IBOutlet weak var secondEventLabel: UILabel!
    @IBOutlet weak var thirdEventLabel: UILabel!
    @IBOutlet weak var fourthEventLabel: UILabel!
    @IBOutlet weak var firstEventDownButton: UIButton!
    @IBOutlet weak var secondEventUpButton: UIButton!
    @IBOutlet weak var secondEventDownButton: UIButton!
    @IBOutlet weak var thirdEventUpButton: UIButton!
    @IBOutlet weak var thirdEventDownButton: UIButton!
    @IBOutlet weak var fourthEventUpButton: UIButton!
    
    
    let numberOfRounds = 6
    let numberOfEvents = 4
    let roundLength = 60
    let quizManager: QuizManager
    
    override var preferredStatusBarStyle: UIStatusBarStyle  {
        return .lightContent
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
        
        //Populate labels with initial set of events
        populateLables()
        
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
            quizManager.changeEventOrder(firstPosition: firstPosition, secondPostion: secondPosition)
            populateLables()
        }
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

