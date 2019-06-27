//
//  AboutTime.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/17/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation
import GameKit

enum EventGroup: String {
    case WorldWarIIEvents
}



enum EventError: Error  {
    case invalidResource
    case conversionError
}

protocol HistoricalEvent {
    var eventDescription: String { get }
    var eventDate: Date { get }
    var eventURL: String { get }
}

protocol TimelineQuiz   {
    var events: [HistoricalEvent] { get set }
}

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
    func checkAnswer() -> Bool
    func getRandomEvents() -> Void
    func changeEventOrder(firstPosition: Int, secondPostion: Int) -> Void
    
}

struct Event: HistoricalEvent    {
    let eventDescription: String
    let eventDate: Date
    let eventURL: String
}

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

class WorldWarIIQuiz: TimelineQuiz  {
    var events: [HistoricalEvent]
    init(events: [HistoricalEvent]) {
        self.events = events
    }
}

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
    
    func isGameComplete() -> Bool  {
        if self.roundsUsed == self.numberOfRounds  {
            return true
        } else  {
            return false
        }
    }
    
    func resetGame() {
        self.roundsUsed = 0
        self.numberOfCorrectRounds = 0
        self.getRandomEvents()
    }
    
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
    
    func changeEventOrder(firstPosition: Int, secondPostion: Int) {
        self.eventSet.swapAt(firstPosition, secondPostion)
    }
    
}

