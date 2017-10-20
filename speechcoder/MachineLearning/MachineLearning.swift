//
//  MachineLearning.swift
//  speechcoder
//
//  Created by homework on 18/9/17.
//  Copyright © 2017 homework. All rights reserved.
//

import UIKit
import CoreML

class MachineLearning
{
    var mlbowmodel = mlbow()
    var mllstmmodel = mllstm()
    
    var bowIntentsDictionary = WordDictionary()
    var bowWordsDictionary = WordDictionary()
    var lstmTagsDictionary = WordDictionary()
    var lstmWordsDictionary = WordDictionary()
    
    init()
    {
        var path = Bundle.main.path(forResource: "mlbowintentsdict", ofType: "txt")
        bowIntentsDictionary.readFromFile(path: path!)
        
        path = Bundle.main.path(forResource: "mlbowwordsdict", ofType: "txt")
        bowWordsDictionary.readFromFile(path: path!)
        
        path = Bundle.main.path(forResource: "mllstmtagsdict", ofType: "txt")
        lstmTagsDictionary.readFromFile(path: path!)
   
        path = Bundle.main.path(forResource: "mllstmwordsdict", ofType: "txt")
        lstmWordsDictionary.readFromFile(path: path!)
    }
    
    // Classify a string using the Bag of Words network
    //
    func classifyWithBagOfWords(text: String) -> [Prediction]
    {
        var tokens = Tagger.lemmatize(text: text)
        var features = bowWordsDictionary.getBagOfWordsFeatures(tokens)
        
        var mlInput = try? MLMultiArray(shape: [NSNumber(value: features.count)], dataType: MLMultiArrayDataType.float32)
        
        for i in 0 ..< features.count
        {
            mlInput![i] = NSNumber(floatLiteral: Double(features[i]))
        }
        var mlOutput = try? mlbowmodel.prediction(input1: mlInput!)
        
        var results : [Prediction] = []
        
        for i in 0 ..< Int((mlOutput?.output1.shape[0])!)
        {
            results.append(Prediction(
                value: bowIntentsDictionary.getWord(i),
                score: Float(mlOutput!.output1[i])))
        }
        
        results.sort(by: {
            a, b in
            a.score > b.score
        })
        
        return results
    }
    
    // Tag every word in a sentence with LSTM
    //
    func tagWithLSTM(text: String) -> ([[Prediction]], [String])
    {
        var results : [[Prediction]] = []
        var tokens = Tagger.lemmatize(text: text)
        var features = lstmWordsDictionary.getWordIndexesFeatures(tokens)
        
        var mlInput = try? MLMultiArray(shape: [1], dataType: MLMultiArrayDataType.float32)
        var mlOutput : mllstmOutput?
        
        //print ("----------------------------------------------")
        for i in 0 ..< features.count
        {
            mlInput![0] = NSNumber(floatLiteral: Double(features[i]))
            
            var input : mllstmInput?
            
            if mlOutput == nil
            {
                // new sequence
                input = mllstmInput(input1: mlInput!)
            }
            else
            {
                // previous state
                
                input = mllstmInput(input1: mlInput!,
                                   lstm_1_h_in: mlOutput?.lstm_1_h_out,
                                   lstm_1_c_in: mlOutput?.lstm_1_c_out
                                )
            }
            mlOutput = try? mllstmmodel.prediction(input: input!)
     
            var result = [Prediction]()
            
            //print("\(wordsDictionary.getWord(features[i]))")
            for j in 0 ..< lstmTagsDictionary.count
            {
                var v = (mlOutput?.output1[j])!
                var s = String(format: "%5.3f", v.floatValue)
                //print("  \(tagsDictionary.getWord(j)) \(s) ")
                result.append(Prediction(value: lstmTagsDictionary.getWord(j), score: v.floatValue))
            }
            
            result.sort(by: {
                a, b in
                a.score > b.score
            })
            results.append(result)
        }
        
        return (results, tokens)
    }
    
    // Extracts the intent and values by calling "tag"
    //
    func extractIntentAndValues(text: String) -> (String, Float, [String])
    {
        // hardcode the "<END>" tag with an English word to prevent the
        // tagger from behaving oddly.
        //
        var result = tagWithLSTM(text: text + " unendingly")
        
        var values : [String] = []
        
        var intent = ""
        var currentValue = ""
        var score : Float = 0.0
        for i in 0 ..< result.0.count
        {
            var pred = result.0[i]
            if pred[0].value == "B-VALUE"
            {
                if currentValue != ""
                {
                    values.append(currentValue)
                    currentValue = ""
                }
                currentValue += result.1[i] + " "
            }
            else if pred[0].value == "I-VALUE"
            {
                currentValue += result.1[i] + " "
            }
            else if pred[0].value == "O"
            {
                if currentValue != ""
                {
                    values.append(currentValue)
                    currentValue = ""
                }
            }
            else if pred[0].value.characters.starts(with: "@")
            {
                intent = pred[0].value
                score = pred[0].score
                
                if currentValue != ""
                {
                    values.append(currentValue)
                    break
                }
            }
        }
        
        if score < 0.8 || result.0.count <= 5
        {
            // If the score is too low (happens when the number of words is too little
            // (3 or less), then use BOW to see if it provides a more confident
            // prediction.
            //
            var bowPredictions = classifyWithBagOfWords(text: text)
            
            if bowPredictions[0].score > score
            {
                intent = "@" + bowPredictions[0].value + ":BOW"
                score = bowPredictions[0].score
            }
        }
        
        
        // process the values to trim the space
        //
        for i in 0 ..< values.count
        {
            values[i] = values[i].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return (intent, score, values)
    }
}
