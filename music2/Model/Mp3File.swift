//
//  mp3File.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class Mp3File{
    
    static var mp3FileNames = [String]()
    static var sections : [(index: Int, length :Int, title: String)] = Array()
    
    init(){
        
    }
    
    func Refresh(){
        Mp3File.mp3FileNames = []
        Mp3File.sections = []
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            //print("mp3 urls:",mp3Files)
            Mp3File.mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            //print("mp3 list:", mp3FileNames)
        } catch {
            print(error.localizedDescription)
        }
        
        Mp3File.mp3FileNames.sort()
        
        var index = 0;
        if Mp3File.mp3FileNames.count > 0 {
            for i in 0...Mp3File.mp3FileNames.count - 1{
                print("test " + Mp3File.mp3FileNames[i])
                let commonprefix_ = Mp3File.mp3FileNames[i].commonPrefix(with: Mp3File.mp3FileNames[index], options: .caseInsensitive)
                if (commonprefix_.count == 0 ) {
                    let string = Mp3File.mp3FileNames[index];
                    let firstCharacter = string[string.startIndex]
                    //print(mp3FileNames)
                    let title = "\(firstCharacter)"
                    let newSection = (index: index, length: i - index, title: title)
                    //if !(sections.contains {$2.contains(title)})
                    Mp3File.sections.append(newSection)
                    //print(Mp3Filesections)
                    index = i;
                }
                print("------------")
            }
            let string = Mp3File.mp3FileNames[index];
            let firstCharacter = string[string.startIndex]
            //print(mp3FileNames)
            let title = "\(firstCharacter)"
            let newSection = (index: index, length: Mp3File.mp3FileNames.count - index, title: title)
            //if !(sections.contains {$2.contains(title)})
            Mp3File.sections.append(newSection)

        }
    }
    
}
