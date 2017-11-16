//
//  main_music.swift
//  music2
//
//  Created by User on 2017. 10. 8..
//  Copyright © 2017년 User. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import CircularSlider
import SwiftMessages
import NYAlertViewController
import AudioToolbox

var is_touching = 0
var is_touching_3d = 0
var is_moved = 0

class main_music: UIViewController {

    var lyric_time = ""
    var lyric = ""
    var timer:Timer!
    let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
    @IBOutlet weak var slider_c: CircularSlider!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    @IBOutlet weak var lyric1: UILabel!
    @IBOutlet weak var lyric2: UILabel!
    
    @IBAction func lyric(_ sender: Any) {
        let alertViewController = NYAlertViewController()
        // Set a title and message
        alertViewController.title = "가사"
        alertViewController.message = "\n" + lyric + "\n"
        // Customize appearance as desired
        alertViewController.buttonCornerRadius = 20.0
        alertViewController.view.tintColor = self.view.tintColor
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
                self.dismiss(animated: true, completion: nil)

            }
        )
        alertViewController.addAction(cancelAction)
        // Present the alert view controller
        self.present(alertViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = UIColor.red
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
//http://dn.genie.co.kr/app/purchase/get_msl.asp?path=a&songid=87463771&callback=jQuery19106672317580988207_1509165099060&_=1509165099061"
       
        
        slider_c.delegate = self
        self.title = ""
        
        func rotateView(view: UIView, duration: Double = 10) {
            if view.layer.animation(forKey: kRotationAnimationKey) == nil {
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
                
                rotationAnimation.fromValue = 0.0
                rotationAnimation.toValue = Float(M_PI * 2.0)
                rotationAnimation.duration = duration
                rotationAnimation.repeatCount = Float.infinity
                
                view.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
            }
        }
        
        rotateView(view: self.artwork)
        
        artwork.layer.borderWidth = 1
        artwork.layer.masksToBounds = false
        artwork.layer.borderColor = UIColor.clear.cgColor
        artwork.layer.cornerRadius = artwork.frame.height/2
        artwork.clipsToBounds = true

        let playerItem = AVPlayerItem(url: SecondViewController.myurl! as URL )
        
        let songAsset = AVURLAsset(url: SecondViewController.myurl! as URL, options: nil)
        if !(songAsset.lyrics == nil){
            lyric =  songAsset.lyrics!
        }
        
        //print(lyricsText)
        
        var t_title = ""
        var a_artist = ""
        let metadataList = playerItem.asset.commonMetadata
        for item in metadataList {
            if item.commonKey == "title" {
                tittle.text = item.stringValue!
                t_title = item.stringValue!
            }
            if item.commonKey == "artist" {
                artist.text = item.stringValue!
                a_artist = item.stringValue!
            }
            if item.commonKey == "albumName" {
                album.text = item.stringValue!
            }
            if item.commonKey == "artwork" {
                if let audioImage = UIImage(data: (item.value as! NSData) as Data) {
                    //let audioArtwork = MPMediaItemArtwork(image: audioImage)
                    //println(audioImage.description)
                    artwork.image = audioImage
                    
                    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
                    backgroundImage.image = blurImage(image: audioImage)
                    self.view.insertSubview(backgroundImage, at: 0)
                    
                   
                    //lyric1.textColor = blurImage(image: audioImage)?.averageColor()
                }
            }
            //print(item.commonKey)
        }
        
       
        
        
        let str = (t_title + " " + a_artist).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let tmp = (str?.replacingOccurrences(of: " ", with: "%20"))
        let url2 = URL(string: "https://app." + "genie" + ".co.kr/Iv3/Search/f_Search_Song.asp?query=" + tmp! + "&pagesize=1")
        let taskk = URLSession.shared.dataTask(with: url2! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            if (text.contains("SONG_ID")){
                let s_code = (text.components(separatedBy: "SONG_ID\":\"")[1].components(separatedBy: "\"")[0])
                
                let url21 = URL(string: "http://dn.genie.co.kr/app/purchase/get_msl.asp?path=a&songid=" + s_code)
                let taskk2 = URLSession.shared.dataTask(with: url21! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                    let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                    //print(text)
                    self.lyric_time = text
                }
                taskk2.resume()
            }
        }
        taskk.resume()
        
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(main_music.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)

        var end_time_m = ""
        var end_time_s = ""
        if(Int(SecondViewController.player.duration) < 60){
            end_time_m = "0"
            end_time_s = Int(SecondViewController.player.duration).description
        }else{
            end_time_m = (Int(SecondViewController.player.duration) / Int(60)).description
            end_time_s = (Int(SecondViewController.player.duration) % Int(60)).description
        }
        if(Int(end_time_s)! < 10){
            end_time_s = "0" + end_time_s
        }
        end.text = end_time_m + ":" + end_time_s
    }
    
    
    @objc func timerDidFire(){
        let time_change = Int(Float(SecondViewController.player.currentTime) * 1000 )
        var arr_time = lyric_time.components(separatedBy: "\",\"")
        if arr_time.count > 5{
            for i in 1...arr_time.count - 1{
                if Int(arr_time[i].components(separatedBy: "\":\"")[0])! >= time_change{
                    lyric1.text = arr_time[i-1].components(separatedBy: "\":\"")[1]
                    lyric2.text = arr_time[i].components(separatedBy: "\":\"")[1]
                    break
                }
            }
        }
        
        //print(SecondViewController.player.currentTime)
        let tmp_current = Int(SecondViewController.player.currentTime).description
        var start_time_m = ""
        var start_time_s = ""

        if(Int(SecondViewController.player.currentTime) < 60){
            start_time_m = "0"
            start_time_s = tmp_current
        }else{
            start_time_m = (Int(tmp_current)! / Int(60)).description
            start_time_s = (Int(tmp_current)! % Int(60)).description
        }
        if(Int(start_time_s)! < 10){
            start_time_s = "0" + start_time_s
        }
        
        start.text = start_time_m + ":" + start_time_s
        
         if is_touching == 0{
            let progress = SecondViewController.player.currentTime / SecondViewController.player.duration * 100
            slider_c.setValue(Float(progress), animated: true)
        }
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func blurImage(image:UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(100.0, forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage
        
        var cgImage:CGImage?
        
        if let asd = outputImage{
            cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
        }
        if let cgImageA = cgImage{
            return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
        }
        return nil
    }
}

extension main_music: CircularSliderDelegate {
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        if is_touching == 1{
            let tmp = SecondViewController.player.duration
            let tmp2 = Float(tmp) * Float(value) * 0.01
            SecondViewController.player.currentTime = TimeInterval(tmp2)
        }
        return floorf(value)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        is_touching = 1
        is_touching_3d = 0
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                    if touch.force >= touch.maximumPossibleForce && is_touching_3d == 0{
                        is_touching_3d = 1
                        //AudioServicesPlaySystemSound(1519)
                        AudioServicesPlaySystemSound(1520)
                        //AudioServicesPlaySystemSound(1521)
                        if SecondViewController.player.isPlaying{
                            SwiftMessages.hideAll()
                            var config = SwiftMessages.Config()
                            config.duration = .seconds(seconds: 0.1)
                            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
                            
                            let view = MessageView.viewFromNib(layout: .statusLine)
                            view.configureTheme(.warning)
                            view.configureDropShadow()
                            let iconText = [""].sm_random()!
                            view.configureContent(title: "", body: "일시정지", iconText: iconText)
                            SwiftMessages.show(config: config, view: view)
                            
                            SecondViewController.player.pause()
                            
                            let pausedTime : CFTimeInterval = (self.artwork?.layer.convertTime(CACurrentMediaTime(), from: nil))!
                            self.artwork?.layer.speed = 0.0
                            self.artwork?.layer.timeOffset = pausedTime
                        }else{
                            SwiftMessages.hideAll()
                            var config = SwiftMessages.Config()
                            config.duration = .seconds(seconds: 0.1)
                            config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
                            
                            let view = MessageView.viewFromNib(layout: .statusLine)
                            view.configureTheme(.success)
                            view.configureDropShadow()
                            let iconText = [""].sm_random()!
                            view.configureContent(title: "", body: "재생", iconText: iconText)
                            SwiftMessages.show(config: config, view: view)
                            
                            SecondViewController.player.play()
                            
                            self.artwork?.layer.speed = 1.0
                            self.artwork?.layer.timeOffset = 0.0
                        }
                    } else {
                        
                    }
                }
            }else{
                //is_moved = is_moved + 1
            }
        }
    }
    func is3dTouchAvailable(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.forceTouchCapability == UIForceTouchCapability.available
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if is_touching_3d == 1{
            
        }
        is_touching = 0
        is_moved = 0
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
