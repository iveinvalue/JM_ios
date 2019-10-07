//
//  FirstViewController.swift
//  music2
//
//  Created by User on 2017. 10. 7..
//  Copyright © 2017년 User. All rights reserved.
//

import UIKit
import DTZFloatingActionButton

protocol ListView: NSObjectProtocol {
    
    func movePlayer()
    func tableRefresh()
    func MessageUp(str: String)
    
}

class save_cell: UITableViewCell {
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image_: UIImageView!
    
}

class ListController: UITableViewController {

    var mPresenter = ListPresenter()

    @IBOutlet var save_table: UITableView!

    override func viewWillAppear(_ animated: Bool){
        initDesign()
        refresh(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mPresenter.attachView(self)
    }
    
    func refresh(_ button:UIBarButtonItem!){
        mPresenter.ListRefresh()
    }
    
    @objc func playing(_ button:UIBarButtonItem!){
        if !( myurl == nil){
            movePlayer()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Mp3File.sections[section].length
        
    }
    
    //테이블 섹션 개수
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Mp3File.sections.count
    }
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String{
        return Mp3File.sections[section].title
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Mp3File.sections.map { $0.title };
    }
    
    //제거 가능 설정
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //제거 눌렀을때
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            mPresenter.DelFile(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = save_table.dequeueReusableCell(withIdentifier: "save_cell", for: indexPath) as! save_cell
        mPresenter.setCell(cell: cell,indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        mPresenter.tableClick(indexPath: indexPath)
    }
    
}


extension ListController: ListView {
    
    func movePlayer(){
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerController") as! PlayerController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    func tableRefresh(){
        self.save_table.reloadData()
        self.save_table.dataSource = self
        self.save_table.delegate = self
    }
    
    func initDesign(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.red
        
        DTZFABManage()
    }
    
    func DTZFABManage(){
        DTZFABManager.shared.button().handler = {
            button in
            self.mPresenter.CheckPlaying()
        }
        DTZFABManager.shared.button().paddingX = 28
        DTZFABManager.shared.button().paddingY = -14 + (self.tabBarController?.tabBar.frame.size.height)!
        DTZFABManager.shared.button().buttonImage = UIImage(named: "player_icon")
        DTZFABManager.shared.button().plusColor = UIColor.white
        DTZFABManager.shared.show()
    }
    
    func MessageUp(str: String){
        SwiftMsg(str,.error,0.6)
    }
    
}
