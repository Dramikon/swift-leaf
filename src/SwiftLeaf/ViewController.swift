//
//  ViewController.swift
//  SwiftLeaf
//
//  Created by Valentin Kononov on 02/01/2017.
//  Copyright © 2017 Dramikon Studio. All rights reserved.
//

import Cocoa
import Foundation
import Quartz


class ViewController: NSViewController {

    @IBOutlet weak var lblStatus: NSTextField!
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnPrev: NSButton!
    @IBOutlet weak var btnPlus: NSButton!
    @IBOutlet weak var btnMinus: NSButton!
    @IBOutlet weak var btnDefaultZoom: NSButton!
    @IBOutlet weak var btnFitToScreen: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnCopy: NSButton!
    
    @IBOutlet weak var imagePane: IKImageView!
    //@IBOutlet weak var imagePane: NSImageView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var currentFolder : URL?
    var currentFile : URL?
    var currentURLs : [URL]
    let imageTypes = NSImage.imageFileTypes()//  imageTypes()
    
    var scale : ImageScale = ImageScale()
    
    
    required init?(coder: NSCoder) {
        currentURLs = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .fileOpenNotification, object: nil, queue: nil, using: {
            let filename = $0.object as! String
            let fileUrl = URL(fileURLWithPath: filename)
            self.openFileFromFolder(file: fileUrl, fileFolder: fileUrl.deletingLastPathComponent())
            })
        
        //imagePane.currentToolMode
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /*
    @IBAction func click(_ sender: NSClickGestureRecognizer) {
        listImages(forward: true)
    }
    */
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(self)
    }
    
    func deleteFile() {
        if(FileManager.default.isDeletableFile(atPath: currentFile!.path)) {
            do {
                //try FileManager.default.removeItem(at: currentFile!)
                try FileManager.default.trashItem(at: currentFile!, resultingItemURL: nil)
                let nextFile = getNextFile(forward: true)
                
                let toRemove = currentURLs.index(of: currentFile!)
                currentURLs.remove(at: toRemove!)
                
                loadImageFromFile(url: nextFile!)
            }
            catch let error as NSError {
                showError(text: error.localizedDescription)
            }
        }

    }
    
    @IBAction func showCustomAbout(_ sender: NSMenuItem) {
        let c = NSAlert()
        c.messageText = NSLocalizedString("LB_APP_NAME_DESC", comment: "Swift Leaf Image Viewer")
        c.informativeText = NSLocalizedString("LB_COPYRIGHT", comment: "Copyright © 2017 Dramikon Studio. All rights reserved." )
        
        c.alertStyle = .informational
        c.addButton(withTitle: NSLocalizedString("LB_OK", comment: "OK"))
        //c.icon =
        c.runModal()
    }
    
    func loadImageFromFile(url: URL){
        
        imagePane.setImageWith(url)
        currentFile = url
        let size = imagePane.imageSize()
        //let props = imagePane.imageProperties()
        
        //let mbSize = ByteCountFormatter.string(fromByteCount: Int64(data!.count), countStyle: .binary)
        lblStatus.stringValue = url.lastPathComponent +
        "   \(Int(size.width))px x \(Int(size.height))px"
        
        
        /*
        let data = FileManager.default.contents(atPath: url.path)
        if data != nil {
            //let image = NSImage(data: data!)
            //imagePane.image = image
            
            let mbSize = ByteCountFormatter.string(fromByteCount: Int64(data!.count), countStyle: .binary)
            lblStatus.stringValue = url.lastPathComponent +
                "   \(Int(image!.size.width))px x \(Int(image!.size.height))px   \(mbSize)"
        }
        */
    }
    
    //open file handler to open image
    @IBAction func openFile(_ sender: NSMenuItem) {
        let myFileDlg = NSOpenPanel()
        //myFileDlg.title = ""
        myFileDlg.allowsMultipleSelection = false
        
        myFileDlg.allowedFileTypes = imageTypes
        
        if myFileDlg.runModal() != NSModalResponseOK {
            return
        }
        
        openFileFromFolder(file: myFileDlg.url!, fileFolder: myFileDlg.directoryURL!.absoluteURL)
    }
    
    func openFileFromFolder(file: URL, fileFolder: URL) {
        currentFile = file
        scale.makeDefault()
        
        if currentFile != nil {
            currentFolder = fileFolder
            
            do {
                let files = try FileManager.default.contentsOfDirectory(at: currentFolder!, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    .sorted(by: { $0.lastPathComponent < $1.lastPathComponent  })
                
                currentURLs = []
                for file in files {
                    if imageTypes.contains(file.pathExtension) {
                        currentURLs.append(file)
                    }
                    
                }
            }
            catch let error as NSError {
                showError(text: error.localizedDescription)
            }
            
            loadImageFromFile(url: currentFile!)
            buttons(enable: true)
        }
    }
    
    func buttons(enable: Bool) {
        btnNext.isEnabled = enable
        btnPrev.isEnabled = enable
        btnPlus.isEnabled = enable
        btnMinus.isEnabled = enable
        btnDefaultZoom.isEnabled = enable
        btnDelete.isEnabled = enable
        btnCopy.isEnabled = enable
        btnFitToScreen.isEnabled = enable
    }
    
    @IBAction func maximizeImage(_ sender: NSButton) {
        maximizeImage()
    }
    
    @IBAction func deleteFile(_ sender: NSButton) {
        deleteFile()
    }
    
    func maximizeImage() {
        imagePane.zoomFactor += 0.1
    }
    
    @IBAction func defaultZoom(_ sender: NSButton) {
        imagePane.zoomFactor = 1.0
    }

    @IBAction func minimizeImage(_ sender: NSButton) {
        minimizeImage()
    }
    
    func minimizeImage() {
        imagePane.zoomFactor -= 0.1
    }
    
    @IBAction func nextImage(_ sender: NSButton) {
        listImages(forward: true)
    }
    
    
    @IBAction func prevImage(_ sender: NSButton) {
        listImages(forward: false)
    }
    
    /*
    @IBAction func imagePaneClicked(_ sender: NSImageView) {
        listImages(forward: true)
    }
    */
    
    
    func listImages(forward: Bool) {
        if let file = getNextFile(forward: forward) {
            loadImageFromFile(url: file)
        }
    }
    
    func getNextFile(forward: Bool) -> URL? {
        if currentFolder != nil {
            if let i = currentURLs.index(of: currentFile!) {
                if forward {
                    if i == currentURLs.count - 1 {
                        return currentURLs[0]
                    }
                    else {
                        return currentURLs[i+1]
                    }
                }
                else {
                    if i == 0 {
                       return currentURLs[currentURLs.count - 1]
                    }
                    else {
                        return currentURLs[i-1]
                    }
                }
            }
        }
        return nil
    }
    
    func showError(text: String) {
        let c = NSAlert()
        c.messageText = text
        c.alertStyle = .warning
        c.runModal()
    }
    
    func showInfo(text: String) {
        let c = NSAlert()
        c.messageText = text
        c.alertStyle = .informational
        c.runModal()
    }
}

