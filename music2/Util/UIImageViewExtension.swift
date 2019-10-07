//
//  UIImageViewExtension.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func setImageFromURl(stringImageUrl url: String){
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
  
    func imageFromUrl(urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData as Data)
                }
            }
            task.resume()
        }
    }
}
