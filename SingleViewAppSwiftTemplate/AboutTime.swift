//
//  AboutTime.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/17/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation
import GameKit
import AudioToolbox

///Enum setting up a group for the trivia questions, allows for the introduction of other trivia files
enum EventGroup: String {
    case WorldWarIIEvents
}

///Enum containing possible error conditions
enum EventError: Error  {
    case invalidResource
    case conversionError
    case invalidURL
}

///Protocol for the Historical Event struct
protocol HistoricalEvent {
    var eventDescription: String { get }
    var eventDate: Date { get }
    var eventURL: String { get }
}

///Protocol for a timeline quiz
protocol TimelineQuiz   {
    var events: [HistoricalEvent] { get set }
}

///Protocol for the quiz manager
protocol QuizManager    {
    var numberOfRounds: Int { get set }
    var roundsUsed: Int { get set }
    var numberOfEvents: Int { get set }
    var roundLength: Int { get set }
    var numberOfCorrectRounds: Int { get set }
    var quiz: TimelineQuiz { get set }
    var eventSet: [HistoricalEvent] { get set }
    
    init(numberOfRounds: Int, numberOfEvents: Int, roundLength: Int, events: [HistoricalEvent])
    func isGameComplete() -> Bool
    func resetGame() -> Void
    func adjustCounter(decreaseBy: Int, isReset: Bool, roundLength: Int) -> Void
    func checkAnswer() -> Bool
    func getRandomEvents() -> Void
    func changeEventOrder(firstPosition: Int, secondPostion: Int) -> Void
}

///Struct for modeling Historical Event data
struct Event: HistoricalEvent    {
    let eventDescription: String
    let eventDate: Date
    let eventURL: String
}

///Helper class to conver the plist data
class PlistConverter    {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String : AnyObject]    {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw EventError.invalidResource
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : AnyObject] else {
            throw EventError.conversionError
        }
        return dictionary
    }
}

///Helper class that loads the data from the plist
class EventLoader   {
    static func quizEvents(fromDictionary dictionary: [String : AnyObject]) throws -> [HistoricalEvent] {
        var eventsList: [HistoricalEvent] = []
        for (_, value) in dictionary  {
            if let eventDictionary = value as? [String : Any], let eventDescription = eventDictionary["event"] as? String, let eventDate = eventDictionary["date"] as? Date, let eventURL = eventDictionary["url"] as? String {
                let event = Event(eventDescription: eventDescription, eventDate: eventDate, eventURL: eventURL)
                
                eventsList.append(event)
            }
        }
        return eventsList
    }
}

///Quiz class to hold the events
class WorldWarIIQuiz: TimelineQuiz  {
    var events: [HistoricalEvent]
    init(events: [HistoricalEvent]) {
        self.events = events
    }
}

///SoundManager struct
struct SoundManager {
    var wrongSound: SystemSoundID = 0
    var correctSound: SystemSoundID = 0
    var perfectGameSound: SystemSoundID = 0
    var wompSound: SystemSoundID = 0
    
    init() {
        let pathWrongSound = Bundle.main.path(forResource: "WrongSound", ofType: "wav")
        let soundUrlWrongSound = URL(fileURLWithPath: pathWrongSound!)
        AudioServicesCreateSystemSoundID(soundUrlWrongSound as CFURL, &wrongSound)
        
        let pathCorrectSound = Bundle.main.path(forResource: "CorrectSound", ofType: "wav")
        let soundUrlCorrectSound = URL(fileURLWithPath: pathCorrectSound!)
        AudioServicesCreateSystemSoundID(soundUrlCorrectSound as CFURL, &correctSound)
        
        let pathPerfectGameSound = Bundle.main.path(forResource: "PerfectGameSound", ofType: "wav")
        let soundUrlPerfectGameSound = URL(fileURLWithPath: pathPerfectGameSound!)
        AudioServicesCreateSystemSoundID(soundUrlPerfectGameSound as CFURL, &perfectGameSound)
        
        let pathWompSound = Bundle.main.path(forResource: "WompSound", ofType: "wav")
        let soundUrlWompSound = URL(fileURLWithPath: pathWompSound!)
        AudioServicesCreateSystemSoundID(soundUrlWompSound as CFURL, &wompSound)
    }
    //Play the requested sound
    func playSelectedSound(_ sound: SystemSoundID) -> Void {
        AudioServicesPlaySystemSound(sound)
    }
}


///Quiz manager class
class WorldWarIIQuizManager: QuizManager    {
    var numberOfRounds: Int
    var roundsUsed: Int = 0
    var numberOfEvents: Int
    var roundLength: Int
    var numberOfCorrectRounds: Int = 0
    var quiz: TimelineQuiz
    var eventSet: [HistoricalEvent] = []
    
    required init(numberOfRounds: Int, numberOfEvents: Int, roundLength: Int, events: [HistoricalEvent]) {
        self.numberOfRounds = numberOfRounds
        self.numberOfEvents = numberOfEvents
        self.roundLength = roundLength
        self.quiz = WorldWarIIQuiz.init(events: events)
        self.getRandomEvents()
    }
    
    ///Checks to see if game is complete
    func isGameComplete() -> Bool  {
        if self.roundsUsed == self.numberOfRounds  {
            return true
        } else  {
            return false
        }
    }
    
    ///Resets game properties for another game
    func resetGame() {
        self.roundsUsed = 0
        self.numberOfCorrectRounds = 0
        self.getRandomEvents()
    }
    
    ///Decreases or resets round length
    func adjustCounter(decreaseBy: Int, isReset: Bool, roundLength: Int = 59) -> Void  {
        if !isReset {
            self.roundLength -= decreaseBy
        } else  {
            self.roundLength = roundLength
        }
        
    }
    
    ///Checks the order of events to ensure they are in chronological order
    func checkAnswer() -> Bool {
        var eventsInChronOrder: Bool = true
        var eventDate: Date = self.eventSet[0].eventDate
        
        for index in 0..<self.eventSet.count {
            if index > 0 && self.eventSet[index].eventDate < eventDate {
                eventsInChronOrder = false
            }
            eventDate = self.eventSet[index].eventDate
        }
        if eventsInChronOrder   {
            self.numberOfCorrectRounds += 1
        }
        self.roundsUsed += 1
        return eventsInChronOrder
    }
    
    ///Gets random set of 4 events and ensures they are not duplicated within a round
    func getRandomEvents() -> Void  {
        var questionsUsed: [Int] = []
        self.eventSet = []
        repeat  {
            let index = GKRandomSource.sharedRandom().nextInt(upperBound: self.quiz.events.count)
            if !questionsUsed.contains(index)   {
                self.eventSet.append(self.quiz.events[index])
                questionsUsed.append(index)
            }
        } while self.eventSet.count < self.numberOfEvents
    }
    
    ///Swaps event order based on interaction with UI
    func changeEventOrder(firstPosition: Int, secondPostion: Int) {
        self.eventSet.swapAt(firstPosition, secondPostion)
    }
    
}

