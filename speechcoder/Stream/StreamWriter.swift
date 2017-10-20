//
//  StreamWriter.swift
//  machinelearning
//
//  Created by homework on 17/9/17.
//  Copyright © 2017 homework. All rights reserved.
//


import Foundation

public class StreamWriter{
    let encoding:String.Encoding!
    var fileHandle:FileHandle!
    let delimData:Data!
    
    init?(path:String, delimiter:String="\n", encoding:String.Encoding = String.Encoding.utf8){
        self.encoding = encoding
        
        //file handle
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path){
            do { try fileManager.removeItem(atPath: path) }
            catch { }
        }

        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        

        if let fileHandle = FileHandle(forWritingAtPath:path){
            self.fileHandle = fileHandle
        }
        
        //delimiter
        if let delimData = delimiter.data(using: encoding){
            self.delimData = delimData
        }else{
            return nil
        }
    }
    
    deinit{
        self.close()
    }
    
    public func writeln(_ data:String)->Bool{
        if let nsData = data.data(using: encoding){
            fileHandle.write(nsData)
            fileHandle.write(delimData)
            return true
        }
        return false
    }
    
    public func write(_ data:String)->Bool{
        if let nsData = data.data(using: encoding){
            fileHandle.write(nsData)
            return true
        }
        return false
    }
    
    public func close(){
        if fileHandle != nil{
            fileHandle.closeFile()
            fileHandle = nil
        }
    }
}
