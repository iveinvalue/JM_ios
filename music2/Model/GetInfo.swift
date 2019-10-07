//
//  GetInfo.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class GetInfo{
    
    func Get(index : Int){
        let turl = "https://app." + GetCertification.main_str + ".co.kr/Iv3/Player/j_AppStmInfo_V2.asp?xgnm=" + GetChart.unm_[index] + "&uxtk=" + GetCertification.uxtk + "&unm=" + GetCertification.r_unm + "&bitrate=" + "192&svc=DI"

        RequestHTTP(url: turl, completion: { result in
            
            var get_url2 = (result.components(separatedBy: "STREAMING_MP3_URL\":\"")[1].components(separatedBy: "\"")[0])
            get_url2 = get_url2.replacingOccurrences(of: "%3A", with: ":")
            get_url2 = get_url2.replacingOccurrences(of: "%2F", with: "/")
            get_url2 = get_url2.replacingOccurrences(of: "%26", with: "&")

            let destinationFileUrl = Docsurl.docsurl.appendingPathComponent(temp)
            
            let fileURL = URL(string: get_url2)
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = URLRequest(url:fileURL!)
            
            let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded. Status code: \(statusCode)")
                    }
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    } catch ( _) {
                    }
                    myGroup.leave()
                }
            }
            task2.resume()
        })
        
        
    }
    
    init(){
        
    }
}
