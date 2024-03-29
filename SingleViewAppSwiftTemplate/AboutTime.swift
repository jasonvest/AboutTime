//
//  AboutTime.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/17/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation
import GameKit

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
struct Event: HistoricalEvent, Codable   {
    let eventDescription: String
    let eventDate: Date
    let eventURL: String
}

///Quiz class to hold the events
class WorldWarIIQuiz: TimelineQuiz  {
    var events: [HistoricalEvent]
    init(events: [HistoricalEvent]) {
        self.events = events
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

