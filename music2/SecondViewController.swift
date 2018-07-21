//
//  SecondViewController.swift
//  music2
//
//  Created by User on 2017. 10. 7..
//  Copyright © 2017년 User. All rights reserved.
//

import UIKit
import AudioToolbox
import Foundation
import AVFoundation
import MediaPlayer
import DTZFloatingActionButton
import SwiftMessages

var temp = ""
let myGroup = DispatchGroup()
let myGroup2 = DispatchGroup()


class SecondViewController: UITableViewController , UIDocumentInteractionControllerDelegate{
    
    
    var docController:UIDocumentInteractionController!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var search: UISearchBar!
    //var gearRefreshControl: GearRefreshControl!
    
    static var url : URL!
    static var myurl : NSURL!
    static var player:AVAudioPlayer!
    
    var docsurl : URL! = nil
    var refresh = 0
    var timer:Timer!
    var tittle_ = [String]() , artist_ = [String]() , imageurl_ = [String]() , unm_ = [String]()
    var uxtk = "" , r_unm = "" , main_str = "genie"
    
    override func viewWillAppear(_ animated: Bool){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        //self.navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = UIColor.red
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        
        
        DTZFABManager.shared.button().handler = {
            button in
            if !( SecondViewController.myurl == nil){
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "main_music") as! main_music
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }else{
                var config = SwiftMessages.Config()
                config.duration = .seconds(seconds: 0.6)
                config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
                
                let view = MessageView.viewFromNib(layout: .statusLine)
                view.configureTheme(.error)
                view.configureDropShadow()
                let iconText = [""].sm_random()!
                view.configureContent(title: "", body: "재생중인 음악이 없습니다.", iconText: iconText)
                SwiftMessages.show(config: config, view: view)
            }
            //print("Tapped")
        }
        DTZFABManager.shared.button().paddingY = 14 + (self.tabBarController?.tabBar.frame.size.height)!
        DTZFABManager.shared.button().buttonImage = UIImage(named: "player_icon")
        DTZFABManager.shared.button().plusColor = UIColor.white
        DTZFABManager.shared.show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //DTZFABManager.shared.hide()
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
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        docController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkMediaAccess()

       
        
        let fileManager2 = FileManager.default
        docsurl = try! fileManager2.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        

        /*
        
        */
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(SecondViewController.refresh2(_:)))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(SecondViewController.playing(_:)))
       
        let textFieldInsideSearchBar = search.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkGray
        
        //let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        //textFieldInsideSearchBarLabel?.textColor = UIColor.white
       
        /*
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        //        gearRefreshControl.gearTintColor = UIColor(red:0.48, green:0.84, blue:0, alpha:1)
        
        gearRefreshControl.addTarget(self, action: #selector(SecondViewController.refresh_table), for: UIControlEvents.valueChanged)
        self.refreshControl = gearRefreshControl
        //gearRefreshControl.gearTintColor = .white*/
        
       
        
        //let leftButton: UIBarButtonItem = UIBarButtonItem(title: "재생중", style: UIBarButtonItemStyle.done, target: self, action: #selector(SecondViewController.playing(_:)))
       // self.navigationItem.rightBarButtonItem = leftButton
        
        //let rightButton: UIBarButtonItem = UIBarButtonItem(title: "새로고침", style: UIBarButtonItemStyle.done, target: self, action: #selector(SecondViewController.refresh2(_:)))
        //self.navigationItem.leftBarButtonItem = rightButton
        
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(SecondViewController.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)

        let url2 = URL(string: "https://raw.githubusercontent.com/iveinvalue/JM_ios/master/info.txt")
        let taskk = URLSession.shared.dataTask(with: url2! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            print(text)
            self.uxtk = text.components(separatedBy: "uxtk!")[1].components(separatedBy: "!")[0]
            self.r_unm = text.components(separatedBy: "unm=")[1].components(separatedBy: "=")[0]
            self.main_str = text.components(separatedBy: "m_str@")[1].components(separatedBy: "@")[0]
        }
        taskk.resume()

        /*
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }*/
        
        let dataPath = docsurl.appendingPathComponent("tmp")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
        refresh_table()
        
        tableview.dataSource = self
        tableview.delegate = self
        search.delegate = self

    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    @objc func timerDidFire(){
        if refresh == 1{
            self.tableview.reloadData()
            self.tableview.dataSource = self
            self.tableview.delegate = self
            refresh = 0
        }
    }
    
    @objc func refresh2(_ button:UIBarButtonItem!){
        refresh_table()
    }
    
    func refresh_table(){
        
        
        let url = URL(string: "https://app." + main_str + ".co.kr/Iv3/SongList/j_RealTimeRankSongList.asp?svc=IV&unm=&pg=1&pgSize=100&apvn=30602&ditc=&uxtk=&uip=192.168.1.3&mts=Y")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            //PKHUD.sharedHUD.hide()

            do {
                var realtext = text
                realtext = realtext.replacingOccurrences(of: "%28", with: "(")
                realtext = realtext.replacingOccurrences(of: "%29", with: ")")
                realtext = realtext.replacingOccurrences(of: "%2C", with: ",")
                realtext = realtext.replacingOccurrences(of: "%26", with: "&")
                realtext = realtext.replacingOccurrences(of: "%3A", with: ":")
                realtext = realtext.replacingOccurrences(of: "%2F", with: "/")
                
                self.tittle_ = []
                self.artist_ = []
                self.imageurl_ = []
                self.unm_ = []
                
                for i in 1...100 {
                    self.tittle_.append((realtext.components(separatedBy: "SONG_NAME\":\"")[i].components(separatedBy: "\"")[0]))
                    self.artist_.append((realtext.components(separatedBy: "ARTIST_NAME\":\"")[i].components(separatedBy: "\"")[0]))
                    self.imageurl_.append((realtext.components(separatedBy: "ALBUM_IMG_PATH\":\"")[i].components(separatedBy: "\"")[0]))
                    self.unm_.append((realtext.components(separatedBy: "SONG_ID\":\"")[i].components(separatedBy: "\"")[0]))
                    
                    let sav_name = "/tmp/" + self.tittle_[i-1] + " - " +  self.artist_[i-1] + ".jpg"
                    let destinationFileUrl = self.docsurl.appendingPathComponent(sav_name)
                    let fileManager = FileManager.default
                    
                    if !fileManager.fileExists(atPath: destinationFileUrl.path) {
                        let fileURL = URL(string: self.imageurl_[i-1])
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url:fileURL!)
                        let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                if ((response as? HTTPURLResponse)?.statusCode) != nil {
                                    //print("Successfully downloaded. Status code: \(statusCode)")
                                }
                                do {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                } catch ( _) {
                                }
                            }
                        }
                        task2.resume()
                    }
                }
                self.refresh = 1
                //self.gearRefreshControl.endRefreshing()
                
            }
            
        }
        task.resume()
    }
    
    @objc func playing(_ button:UIBarButtonItem!){
        if !( SecondViewController.myurl == nil){
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "main_music") as! main_music
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tittle_.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "FirstCustomCell", for: indexPath) as! FirstCustomCell
        
        cell.title.text = tittle_[indexPath.row]
        cell.artist.text = artist_[indexPath.row]
        cell.unm.text = unm_[indexPath.row]
        cell.num.text = String(indexPath.row + 1)
        
        let get_img = load(fileName: "tmp/" + tittle_[indexPath.row] + " - " + artist_[indexPath.row] + ".jpg")
        if get_img == nil{
            let imgURL = imageurl_[indexPath.row]
            cell.image_.imageFromUrl(urlString: imgURL)
        }else{
            //print("good")
            cell.image_.image = get_img
        }
        
        return cell
    }
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = docsurl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            //print("Error loading image : \(error)")
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print("section: \(indexPath.section)")//print("row: \(indexPath.row)")
        if SecondViewController.player != nil && SecondViewController.player.rate != 0 {
            SecondViewController.player.pause()
        }
        
        myGroup.enter()
        temp = tittle_[indexPath.row] + " - " + artist_[indexPath.row] + ".mp3"
        
        let filePath = docsurl.appendingPathComponent(temp).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            //print("FILE AVAILABLE")
            myGroup.leave()
        }
        else{
            let url = URL(string: "https://app." + main_str + ".co.kr/Iv3/Player/j_AppStmInfo_V2.asp?xgnm=" + unm_[indexPath.row] + "&uxtk=" + uxtk + "&unm=" + r_unm + "&bitrate=" + "192&svc=DI")
            let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
                guard let data = data, error == nil else { return }
                let get_url = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                //print(get_url)
                var get_url2 = (get_url?.components(separatedBy: "STREAMING_MP3_URL\":\"")[1].components(separatedBy: "\"")[0])
                get_url2 = get_url2?.replacingOccurrences(of: "%3A", with: ":")
                get_url2 = get_url2?.replacingOccurrences(of: "%2F", with: "/")
                get_url2 = get_url2?.replacingOccurrences(of: "%26", with: "&")

                let destinationFileUrl = self.docsurl.appendingPathComponent(temp)
                
                let fileURL = URL(string: get_url2!)
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                let request = URLRequest(url:fileURL!)
                
                let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        }
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        } catch ( _) {
                        }
                        myGroup.leave()
                    }
                }
                task2.resume()
            }
            task.resume()
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            //let fileManager2 = FileManager.default
            SecondViewController.myurl  = self.docsurl.appendingPathComponent("/" + temp) as NSURL
            do{
                try SecondViewController.player = AVAudioPlayer(contentsOf: SecondViewController.myurl! as URL)

                //try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                //try AVAudioSession.sharedInstance().setActive(true)
            
                SecondViewController.player.prepareToPlay()
                SecondViewController.player.volume = 1.0
                //SecondViewController.player.delegate = self
                /*
                let session = AVAudioSession.sharedInstance()
                do{
                    try session.setCategory(AVAudioSessionCategoryPlayback)
                }
                catch{
                }*/
                SecondViewController.player.play()
                
               
            }
            catch{}
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "main_music") as! main_music
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        //let storyboard: UIStoryboard = self.storyboard!
        //let nextView = storyboard.instantiateViewController(withIdentifier: "main_music")
        //present(nextView, animated: true, completion: nil)
    }
}

extension SecondViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.search.showsCancelButton = false
        self.search.resignFirstResponder()
        self.search.text = ""
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.search.showsCancelButton = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let str  = self.search.text?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let tmp = (str?.replacingOccurrences(of: " ", with: "%20"))!
        
        let url = URL(string: "https://app." + main_str + ".co.kr/Iv3/Search/f_Search_Song.asp?query=" + tmp + "&pagesize=50")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
           print(text)
            var realtext = text
            realtext = realtext.replacingOccurrences(of: "%28", with: "(")
            realtext = realtext.replacingOccurrences(of: "%29", with: ")")
            realtext = realtext.replacingOccurrences(of: "%2C", with: ",")
            realtext = realtext.replacingOccurrences(of: "%26", with: "&")
            realtext = realtext.replacingOccurrences(of: "%3A", with: ":")
            realtext = realtext.replacingOccurrences(of: "%2F", with: "/")
            
            self.tittle_ = []
            self.artist_ = []
            self.imageurl_ = []
            self.unm_ = []
            
            if realtext.contains("SONG_NAME\":\""){
                let arr_tmp = (realtext.components(separatedBy: "SONG_NAME\":\""))
                for i in 1...arr_tmp.count - 1 {
                    self.tittle_.append((realtext.components(separatedBy: "SONG_NAME\":\"")[i].components(separatedBy: "\",")[0])
                        .replacingOccurrences(of: "<\\/span>", with: "")
                        .replacingOccurrences(of: "<span class=\\\"t_point\\\">", with: ""))
                    self.artist_.append((realtext.components(separatedBy: "ARTIST_NAME\":\"")[i].components(separatedBy: "\",")[0])
                        .replacingOccurrences(of: "<\\/span>", with: "")
                        .replacingOccurrences(of: "<span class=\\\"t_point\\\">", with: ""))
                    self.imageurl_.append("http://image." + self.main_str + ".co.kr" + (realtext.components(separatedBy: "\"IMG_PATH\":\"")[i].components(separatedBy: "\"")[0]).replacingOccurrences(of: "\\", with: ""))
                    self.unm_.append((realtext.components(separatedBy: "SONG_ID\":\"")[i].components(separatedBy: "\"")[0]))
                    
                    let sav_name = "/tmp/" + self.tittle_[i-1] + " - " +  self.artist_[i-1] + ".jpg"
                    let destinationFileUrl = self.docsurl.appendingPathComponent(sav_name)
                    let fileManager = FileManager.default
                    
                    if !fileManager.fileExists(atPath: destinationFileUrl.path) {
                        let fileURL = URL(string: self.imageurl_[i-1])
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig)
                        let request = URLRequest(url:fileURL!)
                        let task2 = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                            if let tempLocalUrl = tempLocalUrl, error == nil {
                                if ((response as? HTTPURLResponse)?.statusCode) != nil {
                                    //print("Successfully downloaded. Status code: \(statusCode)")
                                }
                                do {
                                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                                } catch ( _) {
                                }
                            }
                        }
                        task2.resume()
                    }
                }
            }
            self.refresh = 1
        }
        task.resume()
        
        self.search.showsCancelButton = false
        self.search.resignFirstResponder()
        self.search.text = ""
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
            /*
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: .main, completionHandler: { (response, data, error) in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData as Data)
                }
            })*/
        }
    }
    
}

