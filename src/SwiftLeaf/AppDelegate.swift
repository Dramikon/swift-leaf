//
//  AppDelegate.swift
//  SwiftLeaf
//
//  Created by Valentin Kononov on 02/01/2017.
//  Copyright © 2017 Dramikon Studio. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        NotificationCenter.default.post(name: .fileOpenNotification, object: filename)
        return true
    }
    
}

