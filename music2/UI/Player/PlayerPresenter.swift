//
//  PlayerPresenter.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation

class PlayerPresenter{
    
    var mView: PlayerView?
    
    init(){
        
    }
    
    func attachView(_ view:PlayerView){
        mView = view
    }

    func detachView() {
        mView = nil
    }
    
}
