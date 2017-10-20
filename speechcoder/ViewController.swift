//
//  ViewController.swift
//  speechcoder
//
//  Created by homework on 18/9/17.
//  Copyright © 2017 homework. All rights reserved.
//

import UIKit
import CoreML
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    static var vc : ViewController?
    
    var ml = MachineLearning()
    var speechSynth = SpeechSynthesizer()
    
    
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var text : UITextField!
    @IBOutlet weak var outputLabel: UILabel!
    
    var sr = SpeechRecognition()
    
    @IBAction func clearClicked(_ sender: Any) {
        text.text = ""
        outputLabel.text = ""
    }
    
    @IBAction func startRecordingClicked(_ sender: Any) {
        if startRecordingButton.titleLabel?.text == "Start Recording"
        {
            startRecordingButton.setTitle("Stop Recording", for: .normal)
            sr.start(onReceivedTranscription: { (transcription) in
                self.text.text = transcription
            }, onStopped: {
                self.recognizeClicked(sender)
            })
            text.text = ""
            outputLabel.text = ""
            outputLabel.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        }
        else
        {
            startRecordingButton.setTitle("Start Recording", for: .normal)
            sr.stop()
            recognizeClicked(sender)
        }
    }
    
    @IBAction func recognizeClicked(_ sender: Any) {
        var input = "\(text.text!) unendingly"
        
        //var results = ml.tag(text: input)
        
        var intentValues = ml.extractIntentAndValues(text: input)
        
        var output = "You said: \(text.text!)\n\n"
        output += "Your intent is: \(intentValues.0) (\(intentValues.1)) \n\n";
        
        var speechText = "Your intent is: \(intentValues.0)"
        speechSynth.speak(text: speechText.replacingOccurrences(of: "@", with: " ").replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ":BOW", with: "").lowercased())
        
        if intentValues.2.count > 0
        {
            output += "The \(intentValues.2.count) entities are:\n"
            
            for v in intentValues.2
            {
                output += "      \(v);\n"
            }
        }
        
        text.text = ""
        outputLabel.text = output
        outputLabel.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
    
    /*
     *  This just does a quick test to ensure that most of the key
     *  sentences are recognized
     */
    func test()
    {
        var testStrings = [
            "add a new table called expenditure",
            "it has a number field called spent amount",
            "create a new table inventory",
            "drop the table inventory",
            "show me everything from inventory",
            "show me everything from store",
            "group the results by",
            "the sum of the scores",
            "order the results by",
            "the name in ascending order",
            "the popularity in descending order",
            "and the date in ascending order",
            "the birth date is earlier than today",
            "the fuel used is greater than 10",
            "the remarks contains massive",
            "add a new inventory",
            "the description is dinner at friends place",
            
            "yup",
            "nope",
            "hold on",
        ]
        
        for testString in testStrings
        {
            print ("------------------")
            var result = ml.extractIntentAndValues(text: testString)
            print (testString)
            
            var output = "\(result.0) \(result.1) : "
            for entity in result.2
            {
                output += entity + "; "
            }
            print (output)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
        outputLabel.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        
        ViewController.vc = self
        sr.setDelegate(delegate: self)
        sr.requestAuthorization(onReturnStatus: {
            (status) in
            
            if status == SFSpeechRecognizerAuthorizationStatus.authorized
            {
                self.startRecordingButton.isHidden = false
            }
            else
            {
                self.startRecordingButton.isHidden = true
            }
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        startRecordingButton.isEnabled = available
    }

}

