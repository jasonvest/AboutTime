//
//  FileLoader.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/30/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation

///Helper class that loads the data from the plist
class EventLoader   {
    static func quizEvents(fromDictionary dictionary: [String : AnyObject]) throws -> [HistoricalEvent] {
        var eventsList: [HistoricalEvent] = []
        for (_, value) in dictionary  {
            if let eventDictionary = value as? [String : Any], let eventDescription = eventDictionary["eventDescription"] as? String, let eventDate = eventDictionary["eventDate"] as? Date, let eventURL = eventDictionary["eventURL"] as? String {
                let event = Event(eventDescription: eventDescription, eventDate: eventDate, eventURL: eventURL)
                
                eventsList.append(event)
            }
        }
        return eventsList
    }
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

class Test  {
    static func quizEvents(fromFile name: String, ofType type: String) throws -> Void  {
        guard let path = Bundle.main.path(forResource: name, ofType: type),
            let xml = FileManager.default.contents(atPath: path) else {
            throw EventError.invalidResource
        }
        do {
            let events = try PropertyListDecoder().decode([Event].self, from: xml)
            print(events)
            
        } catch let error {
            print("\(error)")
        }

    }
}
