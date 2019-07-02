//
//  SoundManager.swift
//  SingleViewAppSwiftTemplate
//
//  Created by Jason Vest on 6/30/19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation
import AudioToolbox

///Protocol for the game sounds
protocol GameSound {
    var wrongSound: SystemSoundID { get set }
    var correctSound: SystemSoundID { get set }
    var perfectGameSound: SystemSoundID { get set }
    var wompSound: SystemSoundID { get set }
    func playSelectedSound(_ sound: SystemSoundID) -> Void
}

///SoundManager struct
struct SoundManager: GameSound {
    var wrongSound: SystemSoundID = 0
    var correctSound: SystemSoundID = 0
    var perfectGameSound: SystemSoundID = 0
    var wompSound: SystemSoundID = 0
    
    init() {
        let pathWrongSound = Bundle.main.path(forResource: "IncorrectBuzz", ofType: "wav")
        let soundUrlWrongSound = URL(fileURLWithPath: pathWrongSound!)
        AudioServicesCreateSystemSoundID(soundUrlWrongSound as CFURL, &wrongSound)
        
        let pathCorrectSound = Bundle.main.path(forResource: "CorrectDing", ofType: "wav")
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
