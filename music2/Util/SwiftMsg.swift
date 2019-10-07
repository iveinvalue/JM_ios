//
//  SwiftMessages.swift
//  music2
//
//  Created by USER on 07/10/2019.
//  Copyright © 2019 User. All rights reserved.
//

import Foundation
import SwiftMessages

func SwiftMsg(str:String){
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
