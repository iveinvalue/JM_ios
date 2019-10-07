//
//  Getlyric.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class Getlyric{
    
    static var lyric_time = ""
    
    init(){
        
    }
    
    func Get(title: String, artist: String){
        let str = (title + " " + artist).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let tmp = (str?.replacingOccurrences(of: " ", with: "%20"))
        let url = "https://app." + "genie" + ".co.kr/Iv3/Search/f_Search_Song.asp?query=" + tmp! + "&pagesize=1"
        
        RequestHTTP(url: url, completion: {text in
            if (text.contains("SONG_ID")){
                let s_code = (text.components(separatedBy: "SONG_ID\":\"")[1].components(separatedBy: "\"")[0])
                let url21 = URL(string: "http://dn.genie.co.kr/app/purchase/get_msl.asp?path=a&songid=" + s_code)
                let taskk2 = URLSession.shared.dataTask(with: url21! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                    let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                    //print(text)
                    Getlyric.lyric_time = text
                }
                taskk2.resume()
            }
        })

    }
}
