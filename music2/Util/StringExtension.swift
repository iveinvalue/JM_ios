//
//  StringExtension.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

extension String {
//    var hangul: String {
//        get {
//            let hangle = [
//                ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"],
//                ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"],
//                ["","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ","ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ","ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
//            ]
//
//            return reduce("") { result, char in
//                if case let code = Int(String(char).unicodeScalars.reduce(0){
//
//                    $0.0 + $0.1.value}) - 44032, code > -1 && code < 11172 {
//                    let cho = code / 21 / 28, jung = code % (21 * 28) / 28, jong = code % 28;
//                    return result + hangle[0][cho] + hangle[1][jung] + hangle[2][jong]
//                }
//                return result + String(char)
//            }
//        }
//    }
}
