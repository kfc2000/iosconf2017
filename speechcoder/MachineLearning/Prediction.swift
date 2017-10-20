//
//  TestPrediction.swift
//  machinelearning
//
//  Created by homework on 18/9/17.
//  Copyright © 2017 homework. All rights reserved.
//

import CoreML


class Prediction
{
    var value : String
    var score : Float

    init (value v: String, score s: Float)
    {
        value = v
        score = s
    }
}
