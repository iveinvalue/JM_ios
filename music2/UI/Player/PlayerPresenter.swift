//
//  PlayerPresenter.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import NYAlertViewController
import MediaPlayer

class PlayerPresenter{
    
    var mView: PlayerView?
    private var timer:Timer!
    
    private var lyric = ""
    private var t_title = ""
    private var a_artist = ""
    
    private var is_touching = 0
    private var is_touching_3d = 0
    private var is_moved = 0
    
    init(){
        
    }
    
    func attachView(_ view:PlayerView){
        mView = view
    }

    func detachView() {
        mView = nil
    }
    
    func SetTimer(){
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @objc func timerDidFire(){
        MakeLiveLyric()
        MakeCurrentTime()
        if is_touching == 0{
            let progress = player.currentTime / player.duration * 100
            mView?.SetSlider(progress: Float(progress))
        }
    }
    
    func GetEnd(){
        var end_time_m = ""
        var end_time_s = ""
        if(Int(player.duration) < 60){
            end_time_m = "0"
            end_time_s = Int(player.duration).description
        }else{
            end_time_m = (Int(player.duration) / Int(60)).description
            end_time_s = (Int(player.duration) % Int(60)).description
        }
        if(Int(end_time_s)! < 10){
            end_time_s = "0" + end_time_s
        }
        mView?.SetEnd(str: end_time_m + ":" + end_time_s)
    }
    
    func GetMetaData(){
        let playerItem = AVPlayerItem(url: myurl! as URL)
        
        let songAsset = AVURLAsset(url: myurl! as URL, options: nil)
        if !(songAsset.lyrics == nil){
            lyric =  songAsset.lyrics!
        }
        
        
        let metadataList = playerItem.asset.commonMetadata
        for item in metadataList {
            if item.commonKey!.rawValue == "title" {
                mView?.SetTitle(str: item.stringValue!)
                t_title = item.stringValue!
            }
            if item.commonKey!.rawValue == "artist" {
                mView?.SetArtist(str: item.stringValue!)
                a_artist = item.stringValue!
            }
            if item.commonKey!.rawValue == "albumName" {
                mView?.SetAlbum(str: item.stringValue!)
            }
            if item.commonKey!.rawValue == "artwork" {
                if let audioImage = UIImage(data: (item.value as! NSData) as Data) {
                    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
                    backgroundImage.image = blurImage(image: audioImage)
                    
                    mView?.InsertSubview(backgroundImage: backgroundImage)
                    mView?.AlbumImg(img: audioImage)
                    
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    
                    let image = audioImage
                    let mediaArtwork = MPMediaItemArtwork(boundsSize: image.size) { (size: CGSize) -> UIImage in
                        return image
                    }
                    
                    let nowPlayingInfo2: [String: Any] = [
                        MPMediaItemPropertyArtist: a_artist,
                        MPMediaItemPropertyTitle: t_title,
                        MPMediaItemPropertyArtwork: mediaArtwork,
                        MPNowPlayingInfoPropertyIsLiveStream: false
                    ]
                    
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo2
                    
                    let commandCenter = MPRemoteCommandCenter.shared()
                    commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
                        //Update your button here for the pause command
                        player.pause()
                        return .success
                    }
                    commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
                        //Update your button here for the play command
                        player.play()
                        return .success
                    }
                }
            }
        }
        
        Getlyric().Get(title: t_title,artist: a_artist)
    }
    
    func ShowLyric(){
        let str = lyric
        let alertViewController = NYAlertViewController()
        // Set a title and message
        alertViewController.title = "가사"
        alertViewController.message = "\n" + str + "\n"
        // Customize appearance as desired
        alertViewController.buttonCornerRadius = 20.0
        //alertViewController.view.tintColor = self.view.tintColor
        alertViewController.titleFont = UIFont(name: "AvenirNext-Bold", size: 19.0)
        alertViewController.messageFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.cancelButtonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.cancelButtonTitleFont = UIFont(name: "AvenirNext-Medium", size: 16.0)
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        // Add alert actions
        let cancelAction = NYAlertAction(
            title: "Done",
            style: .cancel,
            handler: { (action: NYAlertAction!) -> Void in
                alertViewController.dismiss(animated: true, completion: nil)
            }
        )
        alertViewController.addAction(cancelAction)
        mView?.AlertView(alertViewController: alertViewController)
    }
    
    private func MakeLiveLyric(){
        let time_change = Int(Float(player.currentTime) * 1000 )
        let arr_time = Getlyric.lyric_time.components(separatedBy: "\",\"")
        if arr_time.count > 5{
            for i in 1...arr_time.count - 1{
                if Int(arr_time[i].components(separatedBy: "\":\"")[0])! >= time_change{
                    let lyric1 = arr_time[i-1].components(separatedBy: "\":\"")[1]
                    let lyric2 = arr_time[i].components(separatedBy: "\":\"")[1]
                    mView?.SetLiveLyric(lyric11: lyric1,lyric22: lyric2)
                    break
                }
            }
        }
    }
    
    private func MakeCurrentTime(){
        let tmp_current = Int(player.currentTime).description
        var start_time_m = ""
        var start_time_s = ""

        if(Int(player.currentTime) < 60){
            start_time_m = "0"
            start_time_s = tmp_current
        }else{
            start_time_m = (Int(tmp_current)! / Int(60)).description
            start_time_s = (Int(tmp_current)! % Int(60)).description
        }
        if(Int(start_time_s)! < 10){
            start_time_s = "0" + start_time_s
        }
        
        mView?.SetCurrentTime(time: start_time_m + ":" + start_time_s)
    }
    
    func GetcircularSlider(value: Float) -> Float{
        if is_touching == 1{
            let tmp = player.duration
            let tmp2 = Float(tmp) * Float(value) * 0.01
            player.currentTime = TimeInterval(tmp2)
        }
        return floorf(value)
    }
    
    func SetTouching(_ tmp: Int){
        is_touching = tmp
    }
    
    func Set3DTouching(_ tmp: Int){
        is_touching_3d = tmp
    }
    
    func Get3DTouching() -> Int{
        return is_touching_3d
    }
    
    func SetMoving(_ tmp: Int){
        is_moved = tmp
    }
    
}
