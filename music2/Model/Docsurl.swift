//
//  Docsurl.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class Docsurl{
    static var docsurl : URL! = nil
    static let fileManager2 = FileManager.default
    
    init(){
        
    }
    
    func Do(){
        Docsurl.docsurl = try! Docsurl.fileManager2.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        //폴더 생성
        let dataPath = Docsurl.docsurl.appendingPathComponent("tmp")
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
}

//UIDocumentInteractionControllerDelegate
//var docController:UIDocumentInteractionController!
//func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//    return self
//}
//func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
//    docController = nil
//}
