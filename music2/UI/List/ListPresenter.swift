//
//  ListPresenter.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import MediaPlayer

class ListPresenter{
    
    var mView: ListView?
    
    init(){
        
    }
    
    func attachView(_ view:ListView){
        mView = view
    }

    func detachView() {
        mView = nil
    }
    
    func ListRefresh(){
        Mp3File().Refresh()
        mView?.tableRefresh()
    }
    
    func tableClick(indexPath: IndexPath){
        let tmyurl  = Docsurl.docsurl.appendingPathComponent("/" + Mp3File.mp3FileNames[Mp3File.sections[indexPath.section].index + indexPath.row] + ".mp3") as NSURL
         myurl = tmyurl
         do{
            try player = AVAudioPlayer(contentsOf: myurl as URL)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
         }catch{}
        
        mView?.movePlayer()
    }
    
    func setCell(cell: save_cell, indexPath: IndexPath){
        cell.title.text = Mp3File.mp3FileNames[Mp3File.sections[indexPath.section].index + indexPath.row].components(separatedBy: " - ")[0]
        cell.artist.text  = Mp3File.mp3FileNames[Mp3File.sections[indexPath.section].index + indexPath.row].components(separatedBy: " - ")[1]
        cell.image_.image = load(fileName: "tmp/" + Mp3File.mp3FileNames[Mp3File.sections[indexPath.section].index + indexPath.row] + ".jpg")
    }
    
    func CheckPlaying(){
        if !( myurl == nil){
            mView?.movePlayer()
        }else{
            mView?.MessageUp(str: "재생중인 음악이 없습니다.")
        }
    }
    
    func DelFile(indexPath: IndexPath){
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/\(Mp3File.mp3FileNames[Mp3File.sections[indexPath.section].index + indexPath.row]).\("mp3")"
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        ListRefresh()
    }
    
}
