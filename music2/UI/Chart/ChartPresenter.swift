//
//  ChartPresenter.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class ChartPresenter{
    
    var mView : ChartView?
    
    init(){
        
    }
    
    func attachView(_ view:ChartView){
        mView = view
    }
    
    func detachView() {
        mView = nil
    }
    
    func load(fileName: String) -> UIImage? {
        let fileURL = Docsurl.docsurl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            //print("Error loading image : \(error)")
        }
        return nil
    }
    
    func checkMediaAccess() {
        let authorizationStatus = MPMediaLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            // Show the permission prompt.
            MPMediaLibrary.requestAuthorization({[weak self] (newAuthorizationStatus: MPMediaLibraryAuthorizationStatus) in
                // Try again after the prompt is dismissed.
                self?.checkMediaAccess()
            })
        case .denied, .restricted:
            // Do not use MPMediaQuery.
            return
        default:
            // Proceed as usual.
            break
        }
    }

    
}
