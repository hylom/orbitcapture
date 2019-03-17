//
//  AppDelegate.swift
//  OrbitCapture
//
//  Created by Hiromichi Matsushima on 2019/03/01.
//  Copyright © 2019年 Hiromichi Matsushima. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.mainWindowController = MainWindowController()
        self.mainWindowController?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

