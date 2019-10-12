//
//  GetCertification.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation


class GetCertification{
    
    static var uxtk = "" , r_unm = "" , main_str = "genie"
    
    init(){
        
    }
    
    func Get(){
        let url = "https://raw.githubusercontent.com/jungh0/Jungmusic-ios/master/info.txt"
        RequestHTTP(url: url,completion: {result in
            //print(result)
            GetCertification.uxtk = result.components(separatedBy: "uxtk!")[1].components(separatedBy: "!")[0]
            GetCertification.r_unm = result.components(separatedBy: "unm=")[1].components(separatedBy: "=")[0]
            GetCertification.main_str = result.components(separatedBy: "m_str@")[1].components(separatedBy: "@")[0]
        })
    }
    
}
