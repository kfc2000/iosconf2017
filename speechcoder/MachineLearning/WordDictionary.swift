
//  BagOfWords.swift
//  Speech1
//
//  Created by homework on 9/7/17.
//  Copyright © 2017 homework. All rights reserved.
//
import Foundation

class WordDictionary {
    
    fileprivate var _count : Int = 0
    fileprivate var _bag : [String: Int] = [:]
    fileprivate var _bagr : [String] = []
    fileprivate var _unknownWordRatio : Float = 0.0001
    
    // hardcode the "<UNK>" tag with an English word to prevent the
    // tagger from behaving oddly.
    //
    init(unknownWordRatio: Float = 0, unknownWord: String = "unwittingly") {
        if (unknownWordRatio > 0)
        {
            _count = 1
            _bag[unknownWord] = 0
            _bagr.append(unknownWord)
        }
        _unknownWordRatio = unknownWordRatio
    }
    
    var count : Int
    {
        get {
            return _count
        }
    }
    
    // Adds an array of tokens into the dictionary.
    // Only words that do not exist will be appended into the dictionary.
    //
    func add(tokens: [String])
    {
        for token in tokens
        {
            if _bag[token] == nil
            {
                
                _bag[token] = _count
                _bagr.append(token)
                _count = _count + 1
                
                print ("added \(_count) \(token)")
            }
            
        }
    }
    
    // Gets the features as a bag of words
    //
    func getBagOfWordsFeatures(_ tokens: [String]) -> [Float]
    {
        var features = [Float](repeating: 0, count: _count)
        
        for token in tokens
        {
            var index = _bag[token]
            if (index != nil && index! > 0)
            {
                features[index!] += 1.0
            }
            else
            {
                if _unknownWordRatio == 0
                {
                    features[0] += 1.0
                }
                else
                {
                    features[0] += _unknownWordRatio
                }
            }
        }
        return features
    }
    
    // Gets the features as an array of integer word indexes.
    //
    func getWordIndexesFeatures(_ tokens: [String]) -> [Int]
    {
        var features : [Int] = []
        
        for token in tokens
        {
            var index = _bag[token]
            if index == nil
            {
                features.append(0)
            }
            else
            {
                features.append(index!)
            }
        }
        return features
    }
    
    // Gets the word given the index in the dictionary
    //
    func getWord(_ index: Int) -> String
    {
        return _bagr[index]
    }
    
    // Writes the entire dictionary to a file
    //
    func writeToFile(path: String)
    {
        let sw = StreamWriter(path: path)
        if sw != nil
        {
            for i in 0 ..< self.count
            {
                sw?.writeln("\(i): \(self.getWord(i))")
            }
            sw?.close()
        }
        
    }
    
    func readFromFile(path: String)
    {
        let sr = StreamReader(path: path)
        if sr != nil
        {
            _count = 0
            _bag.removeAll()
            _bagr.removeAll()
            while let line = sr?.readln()
            {
                var lineSplit = line.components(separatedBy: ":")
                if lineSplit.count >= 2
                {
                    var word = lineSplit[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    self.add(tokens: [word])
                }
            }
            sr?.close()
        }
    }
}

