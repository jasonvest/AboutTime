//
//  FileLoader.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/30/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation

///Helper class that loads the data from the plist
class EventLoader  {
    static func quizEvents(fromFile name: String, ofType type: String) throws -> [HistoricalEvent]  {
        var eventsList: [HistoricalEvent] = []
        guard let path = Bundle.main.path(forResource: name, ofType: type),
            let xml = FileManager.default.contents(atPath: path) else {
            throw EventError.invalidResource
        }
        do {
            let events = try PropertyListDecoder().decode([String: Event].self, from: xml)
            for (_, value) in events  {
                eventsList.append(value)
            }
        } catch {
            throw EventError.conversionError
        }
        return eventsList
    }
}
