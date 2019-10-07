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

protocol ChartView: NSObjectProtocol {
    
    
}

class ChartCell: UITableViewCell {
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var unm: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var image_: UIImageView!
    
}

class ChartController: UITableViewController , UIDocumentInteractionControllerDelegate{

    var mPresenter = ChartPresenter()
    
    var docController:UIDocumentInteractionController!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var search: UISearchBar!

    static var url : URL!
    static var myurl : NSURL!
    static var player:AVAudioPlayer!

    var timer:Timer!
    
    override func viewWillAppear(_ animated: Bool){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.red

        DTZFABManager.shared.button().handler = {
            button in
            if !( ChartController.myurl == nil){
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerController") as! PlayerController
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }else{
                var config = SwiftMessages.Config()
                config.duration = .seconds(seconds: 0.6)
                config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
                
                let view = MessageView.viewFromNib(layout: .statusLine)
                view.configureTheme(.error)
                view.configureDropShadow()
                let iconText = [""].randomElement()!
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

    
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        docController = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mPresenter.attachView(self)
        
        mPresenter.checkMediaAccess()

       
        Docsurl().Do()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ChartController.refresh2(_:)))
       
        let textFieldInsideSearchBar = search.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkGray
        
       
        if(timer != nil){timer.invalidate()}
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(ChartController.timerDidFire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
        GetCertification().Get()

        
        refresh_table()
        
        tableview.dataSource = self
        tableview.delegate = self
        search.delegate = self

    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    @objc func timerDidFire(){
        if GetChart.refresh == 1{
            self.tableview.reloadData()
            self.tableview.dataSource = self
            self.tableview.delegate = self
            GetChart.refresh = 0
        }
    }
    
    @objc func refresh2(_ button:UIBarButtonItem!){
        refresh_table()
    }
    
    func refresh_table(){
        GetChart().Get()
    }
    
    @objc func playing(_ button:UIBarButtonItem!){
        if !( ChartController.myurl == nil){
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerController") as! PlayerController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GetChart.tittle_.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath) as! ChartCell
        
        cell.title.text = GetChart.tittle_[indexPath.row]
        cell.artist.text = GetChart.artist_[indexPath.row]
        cell.unm.text = GetChart.unm_[indexPath.row]
        cell.num.text = String(indexPath.row + 1)
        
        let filename = "tmp/" + GetChart.tittle_[indexPath.row] + " - " + GetChart.artist_[indexPath.row] + ".jpg"
        let get_img = mPresenter.load(fileName: filename)
        
        if get_img == nil{
            cell.image_.imageFromUrl(urlString: GetChart.imageurl_[indexPath.row])
        }else{
            cell.image_.image = get_img
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print("section: \(indexPath.section)")//print("row: \(indexPath.row)")
        if ChartController.player != nil && ChartController.player.rate != 0 {
            ChartController.player.pause()
        }
        
        myGroup.enter()
        temp = GetChart.tittle_[indexPath.row] + " - " + GetChart.artist_[indexPath.row] + ".mp3"
        
        let filePath = Docsurl.docsurl.appendingPathComponent(temp).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            //print("FILE AVAILABLE")
            myGroup.leave()
        }
        else{
            GetInfo().Get(index: indexPath.row)
        }
        
        myGroup.notify(queue: DispatchQueue.main) {
            //let fileManager2 = FileManager.default
            ChartController.myurl  = Docsurl.docsurl.appendingPathComponent("/" + temp) as NSURL
            do{
                try ChartController.player = AVAudioPlayer(contentsOf: ChartController.myurl! as URL)

                ChartController.player.prepareToPlay()
                ChartController.player.volume = 1.0

                ChartController.player.play()
               
            }
            catch{}
            let ChartController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerController") as! PlayerController
            self.navigationController?.pushViewController(ChartController, animated: true)
        }

    }
}

extension ChartController: UISearchBarDelegate {
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
        GetChart().Search(tmp: tmp)
        
        self.search.showsCancelButton = false
        self.search.resignFirstResponder()
        self.search.text = ""
    }
}


extension ChartController: ChartView {
    

    
}
