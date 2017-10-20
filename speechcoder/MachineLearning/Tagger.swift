//
//  Tagger.swift
//  Speech1
//
//  Created by homework on 9/7/17.
//  Copyright © 2017 homework. All rights reserved.
//

import Foundation

class Tagger: NSObject {
    
    typealias TaggedToken = (String, NSLinguisticTag?)
    
    class func tag(text: String, scheme: NSLinguisticTagScheme) -> [TaggedToken]
    {
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
        
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
                                        options: Int(options.rawValue))
        
        tagger.string = text
        
        var tokens: [TaggedToken] = []
        
        // Using NSLinguisticTagger
        tagger.enumerateTags(
            in: NSMakeRange(0, text.characters.count),
            scheme:scheme, options: options)
        { tag, tokenRange, _, _ in
            let token = (text as NSString).substring(with: tokenRange)
            //print ("\(tag) \(token)")
            tokens.append((token, tag))
        }
        return tokens
    }
    
    // Implementation
    
    class func partOfSpeech(text: String) -> [TaggedToken] {
        return tag(text: text, scheme:.lexicalClass)
    }
    
    class func lemmatize(text: String) -> [String] {
        var tokens = tag(text: text, scheme: .lemma)
        
        var results = [String]()
        
        for token in tokens
        {
            var t = token.1?.rawValue ?? ""
            if t == ""
            {
                t = token.0
            }
            results.append(t.lowercased())
            
        }
        return results
    }
    
    class func language(text: String) -> [TaggedToken] {
        return tag(text: text, scheme: NSLinguisticTagScheme.language)
    }
    
    class func namedEntity(text: String) -> [TaggedToken] {
        return tag(text: text, scheme: NSLinguisticTagScheme.nameType)
    }
    
    class func namedEntityOrPartOfSpeech(text: String) -> [TaggedToken] {
        return tag(text: text, scheme: NSLinguisticTagScheme.nameTypeOrLexicalClass)
    }

}
