//
//  ImageScale.swift
//  SwiftLeaf
//
//  Created by Valentin Kononov on 12/01/2017.
//  Copyright © 2017 Dramikon Studio. All rights reserved.
//

import Cocoa

class ImageScale: NSObject {
    var currentScale : UInt = 0
    let defaultScale : UInt = 0
    let scaleIndent : UInt = 1
    
    var value : UInt {
        get {
            return currentScale
        }
    }
    
    func increase(){
        currentScale += scaleIndent
    }
    
    func decrease() {
        if(currentScale >= scaleIndent) {
            currentScale -= scaleIndent
        }
    }
    
    func makeDefault() {
        currentScale = defaultScale
    }
}
