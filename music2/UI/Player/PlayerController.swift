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

import CircularSlider
import SwiftMessages
import AudioToolbox
import DTZFloatingActionButton
import NYAlertViewController



protocol PlayerView: NSObjectProtocol {
    
    func AlertView(alertViewController: NYAlertViewController)
    func SetLiveLyric(lyric11:String, lyric22: String)
    func SetCurrentTime(time: String)
    func InsertSubview(backgroundImage: UIImageView)
    func SetTitle(str: String)
    func SetArtist(str: String)
    func AlbumImg(img: UIImage)
    func SetAlbum(str: String)
    func SetEnd(str: String)
    func SetSlider(progress: Float)
    
}

class PlayerController: UIViewController , UIDocumentInteractionControllerDelegate{

    var mPresenter = PlayerPresenter()
    var docController:UIDocumentInteractionController!
    
    @IBOutlet weak var slider_c: CircularSlider!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    @IBOutlet weak var lyric1: UILabel!
    @IBOutlet weak var lyric2: UILabel!
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        docController = nil
    }
    
    @IBAction func share(_ sender: Any) {
        let fileManager2 = FileManager.default
        let docsurl = try! fileManager2.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let destinationFileUrl = docsurl.appendingPathComponent(tittle.text! + " - " + artist.text! + ".mp3")

        if fileManager2.fileExists(atPath: destinationFileUrl.path){
            docController = UIDocumentInteractionController(url: destinationFileUrl)
            docController.name = NSURL(fileURLWithPath: destinationFileUrl.path).lastPathComponent
            docController.delegate = self
            docController.presentPreview(animated: true)
            docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        }
        else {
            print("document was not found")
        }
    }
    
    @IBAction func lyric(_ sender: Any) {
        mPresenter.ShowLyric()
    }

    override func viewWillAppear(_ animated: Bool){
        initDesign()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mPresenter.attachView(self)
        mPresenter.GetMetaData()
        mPresenter.GetEnd()
        mPresenter.SetTimer()
        slider_c.delegate = self
    }

}

extension PlayerController: CircularSliderDelegate {
    
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        return mPresenter.GetcircularSlider(value: value)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mPresenter.SetTouching(1)
        mPresenter.Set3DTouching(0)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                    if touch.force >= touch.maximumPossibleForce && mPresenter.Get3DTouching() == 0{
                        mPresenter.Set3DTouching(1)
                        AudioServicesPlaySystemSound(1520)

                        if player.isPlaying{
                            SwiftMessages.hideAll()
                            SwiftMsg("일시정지",.warning,0.1)
                            player.pause()
                            
                            let pausedTime : CFTimeInterval = (self.artwork?.layer.convertTime(CACurrentMediaTime(), from: nil))!
                            self.artwork?.layer.speed = 0.0
                            self.artwork?.layer.timeOffset = pausedTime
                        }
                        else{
                            SwiftMessages.hideAll()
                            SwiftMsg("재생",.success,0.1)
                            player.play()
                            
                            self.artwork?.layer.speed = 1.0
                            self.artwork?.layer.timeOffset = 0.0
                        }
                    }
                }
            }
        }
    }
    
    func is3dTouchAvailable(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.forceTouchCapability == UIForceTouchCapability.available
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        mPresenter.SetTouching(0)
        mPresenter.SetMoving(0)
    }
    
}

extension PlayerController: PlayerView {
    
    func AlertView(alertViewController: NYAlertViewController){
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func initDesign(){
        self.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = UIColor.red
        
        DTZFABManager.shared.hide()

        artwork.layer.borderWidth = 1
        artwork.layer.masksToBounds = false
        artwork.layer.borderColor = UIColor.clear.cgColor
        artwork.layer.cornerRadius = artwork.frame.height/2
        artwork.clipsToBounds = true
        rotateView(view: self.artwork)
    }
    
    func SetLiveLyric(lyric11:String, lyric22: String){
        lyric1.text = lyric11
        lyric2.text = lyric22
    }
    
    func SetCurrentTime(time: String){
        start.text = time
    }
    
    func InsertSubview(backgroundImage: UIImageView){
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func SetTitle(str: String){
        tittle.text = str
    }
    
    func SetArtist(str: String){
        artist.text = str
    }
    
    func SetAlbum(str: String){
        album.text = str
    }
    
    func AlbumImg(img: UIImage){
        artwork.image = img
    }
    
    func SetEnd(str: String){
        end.text = str
    }
    
    func SetSlider(progress: Float){
        slider_c.setValue(progress, animated: true)
    }
}
