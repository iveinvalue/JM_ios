//
//  GetChart.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class GetChart{
    static var refresh = 0
    static var tittle_ = [String]() , artist_ = [String]() , imageurl_ = [String]() , unm_ = [String]()
    
    func Get(){
        let turl = "https://app." + GetCertification.main_str + ".co.kr/Iv3/SongList/j_RealTimeRankSongList.asp?svc=IV&unm=&pg=1&pgSize=100&apvn=30602&ditc=&uxtk=&uip=192.168.1.3&mts=Y"
        
        RequestHTTP(url: turl, completion: { text in
            do {
                //print(text)
                var realtext = text
                realtext = realtext.replacingOccurrences(of: "%28", with: "(")
                realtext = realtext.replacingOccurrences(of: "%29", with: ")")
                realtext = realtext.replacingOccurrences(of: "%2C", with: ",")
                realtext = realtext.replacingOccurrences(of: "%26", with: "&")
                realtext = realtext.replacingOccurrences(of: "%3A", with: ":")
                realtext = realtext.replacingOccurrences(of: "%2F", with: "/")
                
                GetChart.tittle_ = []
                GetChart.artist_ = []
                GetChart.imageurl_ = []
                GetChart.unm_ = []
                //print(text)
                
                for i in 1...100 {
                    GetChart.tittle_.append((realtext.components(separatedBy: "SONG_NAME\":\"")[i].components(separatedBy: "\"")[0]))
                    GetChart.artist_.append((realtext.components(separatedBy: "ARTIST_NAME\":\"")[i].components(separatedBy: "\"")[0]))
                    GetChart.imageurl_.append((realtext.components(separatedBy: "ALBUM_IMG_PATH\":\"")[i].components(separatedBy: "\"")[0]))
                    GetChart.unm_.append((realtext.components(separatedBy: "SONG_ID\":\"")[i].components(separatedBy: "\"")[0]))
                    
                    let sav_name = "/tmp/" + GetChart.tittle_[i-1] + " - " +  GetChart.artist_[i-1] + ".jpg"
                    let destinationFileUrl = Docsurl.docsurl.appendingPathComponent(sav_name)
                    let fileManager = FileManager.default
                    
                    if !fileManager.fileExists(atPath: destinationFileUrl.path) {
                        let fileURL = URL(string: GetChart.imageurl_[i-1])
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url:fileURL!)
                        let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                if ((response as? HTTPURLResponse)?.statusCode) != nil {
                                    //print("Successfully downloaded. Status code: \(statusCode)")
                                }
                                do {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                } catch ( _) {
                                }
                            }
                        }
                        task2.resume()
                    }
                }
                GetChart.refresh = 1
            }
        })
    }
    
    func Search(tmp: String){
        let turl = "https://app." + GetCertification.main_str + ".co.kr/Iv3/Search/f_Search_Song.asp?query=" + tmp + "&pagesize=50"
        
        RequestHTTP(url: turl, completion: { result in
            var realtext = result
            realtext = realtext.replacingOccurrences(of: "%28", with: "(")
            realtext = realtext.replacingOccurrences(of: "%29", with: ")")
            realtext = realtext.replacingOccurrences(of: "%2C", with: ",")
            realtext = realtext.replacingOccurrences(of: "%26", with: "&")
            realtext = realtext.replacingOccurrences(of: "%3A", with: ":")
            realtext = realtext.replacingOccurrences(of: "%2F", with: "/")
            
            GetChart.tittle_ = []
            GetChart.artist_ = []
            GetChart.imageurl_ = []
            GetChart.unm_ = []
            
            if realtext.contains("SONG_NAME\":\""){
                let arr_tmp = (realtext.components(separatedBy: "SONG_NAME\":\""))
                for i in 1...arr_tmp.count - 1 {
                    GetChart.tittle_.append((realtext.components(separatedBy: "SONG_NAME\":\"")[i].components(separatedBy: "\",")[0])
                        .replacingOccurrences(of: "<\\/span>", with: "")
                        .replacingOccurrences(of: "<span class=\\\"t_point\\\">", with: ""))
                    GetChart.artist_.append((realtext.components(separatedBy: "ARTIST_NAME\":\"")[i].components(separatedBy: "\",")[0])
                        .replacingOccurrences(of: "<\\/span>", with: "")
                        .replacingOccurrences(of: "<span class=\\\"t_point\\\">", with: ""))
                    GetChart.imageurl_.append("http://image." + GetCertification.main_str + ".co.kr" + (realtext.components(separatedBy: "\"IMG_PATH\":\"")[i].components(separatedBy: "\"")[0]).replacingOccurrences(of: "\\", with: ""))
                    GetChart.unm_.append((realtext.components(separatedBy: "SONG_ID\":\"")[i].components(separatedBy: "\"")[0]))
                    
                    let sav_name = "/tmp/" + GetChart.tittle_[i-1] + " - " +  GetChart.artist_[i-1] + ".jpg"
                    let destinationFileUrl = Docsurl.docsurl.appendingPathComponent(sav_name)
                    let fileManager = FileManager.default
                    
                    if !fileManager.fileExists(atPath: destinationFileUrl.path) {
                        let fileURL = URL(string: GetChart.imageurl_[i-1])
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url:fileURL!)
                        let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                if ((response as? HTTPURLResponse)?.statusCode) != nil {
                                    //print("Successfully downloaded. Status code: \(statusCode)")
                                }
                                do {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                } catch ( _) {
                                }
                            }
                        }
                        task2.resume()
                    }
                }
            }
            GetChart.refresh = 1
        })
    }
    
    
    init(){

    }
}
