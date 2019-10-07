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

protocol ChartView: NSObjectProtocol {
    
    func MessageUp(str: String)
    func movePlayer()
    func refresh_data()
    
}

class ChartCell: UITableViewCell {
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var unm: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var image_: UIImageView!
    
}

class ChartController: UITableViewController {

    var mPresenter = ChartPresenter()

    static var url : URL!
    static var myurl : NSURL!
    static var player:AVAudioPlayer!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var search: UISearchBar!

    override func viewWillAppear(_ animated: Bool){
        initDesign()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ChartController.refreshChart(_:)))
        
        mPresenter.attachView(self)
        mPresenter.checkMediaAccess()
        mPresenter.loadChart()
        
        tableview.dataSource = self
        tableview.delegate = self
        search.delegate = self
    }
    
    @objc func refreshChart(_ button:UIBarButtonItem!){
        mPresenter.loadChart()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GetChart.tittle_.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath) as! ChartCell
        mPresenter.setCell(cell: cell,index: indexPath.row)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        mPresenter.tableClick(index: indexPath.row)
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
    
    func refresh_data(){
        if GetChart.refresh == 1{
            self.tableview.reloadData()
            self.tableview.dataSource = self
            self.tableview.delegate = self
            GetChart.refresh = 0
        }
    }
    
    func initDesign(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.red
        
        let textFieldInsideSearchBar = search.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkGray
        
        DTZFABManage()
    }
    
    func movePlayer(){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerController") as! PlayerController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    func MessageUp(str: String){
        var config = SwiftMessages.Config()
        config.duration = .seconds(seconds: 0.6)
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.error)
        view.configureDropShadow()
        let iconText = [""].randomElement()!
        view.configureContent(title: "", body: str, iconText: iconText)
        SwiftMessages.show(config: config, view: view)
    }
    
    func DTZFABManage(){
        DTZFABManager.shared.button().handler = {
            button in
            self.mPresenter.CheckPlaying()
        }
        DTZFABManager.shared.button().paddingY =
            14 + (self.tabBarController?.tabBar.frame.size.height)!
        DTZFABManager.shared.button().buttonImage = UIImage(named: "player_icon")
        DTZFABManager.shared.button().plusColor = UIColor.white
        DTZFABManager.shared.show()
    }
}
