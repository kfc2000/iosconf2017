//
//  SpeechRecognition.swift
//  Speech1
//
//  Created by homework on 2/7/17.
//  Copyright © 2017 homework. All rights reserved.
//

import UIKit
import Speech

class SpeechRecognition: NSObject {

    private var speechRecognizer : SFSpeechRecognizer! = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var started = false
    
    func setDelegate(delegate: SFSpeechRecognizerDelegate)
    {
        speechRecognizer.delegate = delegate
    }
    

    func start(
        onReceivedTranscription: @escaping (String) -> Void,
        onStopped: @escaping () -> Void)
    {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        }
        catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        print (SFSpeechRecognizer.supportedLocales().count)
        for l in SFSpeechRecognizer.supportedLocales()
        {
            
            print ("\(l.identifier) \(l.languageCode) ")
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                if self.started
                {
                    onReceivedTranscription((result?.bestTranscription.formattedString)!)
                }
                //self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                //print ("Stopping due to error")
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
                
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //onStopped()
                //self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            
            started = true
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    
    func stop()
    {
        started = false
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    
    var isRunning : Bool
    {
        get
        {
            return audioEngine.isRunning
        }
    }
    
    
    func requestAuthorization(
        onReturnStatus: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void)
    {
        SFSpeechRecognizer.requestAuthorization(onReturnStatus)
    }
    
}
