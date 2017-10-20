//
//  SpeechSynthesizer.swift
//  Speech1
//
//  Created by homework on 2/7/17.
//  Copyright © 2017 homework. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechSynthesizer: NSObject {

    let synth = AVSpeechSynthesizer()
    
    func speak(text: String)
    {
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            print ("\(voice.identifier) \(voice.name) \(voice.language) ")
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
            
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = 0.4
        myUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_compact")
        
        synth.speak(myUtterance)
        
        
    }
    
    func stop()
    {
        synth.stopSpeaking(at: .word)
    }
}
