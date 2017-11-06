//
//  FirstViewController.swift
//  music2
//
//  Created by User on 2017. 10. 7..
//  Copyright © 2017년 User. All rights reserved.
//

import UIKit
import AVFoundation


class save_cell: UITableViewCell {
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image_: UIImageView!
}

class FirstViewController: UITableViewController {

    //var gearRefreshControl: GearRefreshControl!
    var docsurl : URL! = nil
    var mp3FileNames = [String]()
    @IBOutlet var save_table: UITableView!

    override func viewWillAppear(_ animated: Bool){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(FirstViewController.refresh(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(FirstViewController.playing(_:)))
        
        /*
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        //        gearRefreshControl.gearTintColor = UIColor(red:0.48, green:0.84, blue:0, alpha:1)
        
        gearRefreshControl.addTarget(self, action: #selector(FirstViewController.refresh), for: UIControlEvents.valueChanged)
        self.refreshControl = gearRefreshControl
        //gearRefreshControl.gearTintColor = .white*/
        
        let fileManager2 = FileManager.default
        docsurl = try! fileManager2.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        //let leftButton: UIBarButtonItem = UIBarButtonItem(title: "새로고침", style: UIBarButtonItemStyle.done, target: self, action: #selector(FirstViewController.refresh(_:)))
        //self.navigationItem.leftBarButtonItem = leftButton
        
        //let rightButton: UIBarButtonItem = UIBarButtonItem(title: "재생중", style: UIBarButtonItemStyle.done, target: self, action: #selector(FirstViewController.playing(_:)))
        //self.navigationItem.rightBarButtonItem = rightButton
        
        refresh(nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    func refresh(_ button:UIBarButtonItem!){
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            //print(directoryContents)
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
            //print("mp3 urls:",mp3Files)
            mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            //print("mp3 list:", mp3FileNames)
        } catch {
            print(error.localizedDescription)
        }
        
        mp3FileNames.sort()
        
        self.save_table.reloadData()
        self.save_table.dataSource = self
        self.save_table.delegate = self
        //self.gearRefreshControl.endRefreshing()
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
        return mp3FileNames.count
    }
    //제거 가능 설정
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //제거 눌렀을때
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            //let myurl  = docsurl.appendingPathComponent("/" + mp3FileNames[indexPath.row] + ".mp3") as NSURL
            let fileManager = FileManager.default
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            guard let dirPath = paths.first else {
                return
            }
            let filePath = "\(dirPath)/\(mp3FileNames[indexPath.row]).\("mp3")"
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            refresh(nil)
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = save_table.dequeueReusableCell(withIdentifier: "save_cell", for: indexPath) as! save_cell
        
        cell.title.text  = mp3FileNames[indexPath.row].components(separatedBy: " - ")[0]
        cell.artist.text  = mp3FileNames[indexPath.row].components(separatedBy: " - ")[1]
        cell.image_.image = load(fileName: "tmp/" + mp3FileNames[indexPath.row] + ".jpg")
    
        return cell
    }
    
    private func load(fileName: String) -> UIImage? {
        let fileURL = docsurl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")
        //print("row: \(indexPath.row)")
        //print("id: \(unm_[indexPath.row])")
        let myurl  = docsurl.appendingPathComponent("/" + mp3FileNames[indexPath.row] + ".mp3") as NSURL
       SecondViewController.myurl = myurl
        
        do{
            try SecondViewController.player = AVAudioPlayer(contentsOf: SecondViewController.myurl! as URL)
            //try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //try AVAudioSession.sharedInstance().setActive(true)
            SecondViewController.player.prepareToPlay()
            SecondViewController.player.volume = 1.0
            //SecondViewController.player.delegate = self
            SecondViewController.player.play()
        }
        catch{}
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "main_music") as! main_music
        self.navigationController?.pushViewController(secondViewController, animated: true)
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

