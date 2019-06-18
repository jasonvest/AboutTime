//
//  AboutTime.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/17/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation

enum EventSelection {
    case event
    case date
}

protocol HistoricalEvent {
    var eventDate: Date { get }
    var eventDescription: String { get }
}

protocol TimelineQuiz   {
    
}


