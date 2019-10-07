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

class ChartPresenter {
    
    var mView : ChartView?
    var docController:UIDocumentInteractionController!
    var timer:Timer!
    
    init(){
        
    }
    
    func attachView(_ view:ChartView){
        mView = view
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
        Docsurl().Do()
        GetCertification().Get()
    }
    
    @objc func refreshData(){
        mView?.refresh_data()
    }
    
    func detachView() {
        mView = nil
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

    func CheckPlaying(){
        if !(myurl == nil){
            mView?.movePlayer()
        }else{
            mView?.MessageUp(str: "재생중인 음악이 없습니다.")
        }
    }
    
    func loadChart(){
        GetChart().Get()
    }
    
    func setCell(cell: ChartCell, index: Int){
        cell.title.text = GetChart.tittle_[index]
        cell.artist.text = GetChart.artist_[index]
        cell.unm.text = GetChart.unm_[index]
        cell.num.text = String(index + 1)
        
        let filename = "tmp/" +
            GetChart.tittle_[index] + " - " +
            GetChart.artist_[index] + ".jpg"
        let get_img = load(fileName: filename)
        
        if get_img == nil{
            cell.image_.imageFromUrl(urlString: GetChart.imageurl_[index])
        }else{
            cell.image_.image = get_img
        }
    }
    
    func tableClick(index: Int){
        if player != nil && player.rate != 0 {
            player.pause()
        }
        
        myGroup.enter()
        temp = GetChart.tittle_[index] + " - " + GetChart.artist_[index] + ".mp3"
        
        let filePath = Docsurl.docsurl.appendingPathComponent(temp).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            myGroup.leave() //print("FILE AVAILABLE")
        }
        else{
            GetInfo().Get(index: index)
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            myurl  = Docsurl.docsurl.appendingPathComponent("/" + temp) as NSURL
            do{
                try player = AVAudioPlayer(contentsOf: myurl! as URL)
                player.prepareToPlay()
                player.volume = 1.0
                player.play()
            }
            catch{}
            self.mView?.movePlayer()
        }
    }
    
}
