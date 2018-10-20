//
//  ViewController.swift
//  Miscord
//
//  Created by Bjornskjald on 20.10.2018.
//  Copyright © 2018 Miscord. All rights reserved.
//

import Cocoa

func shell(launchPath: String) -> Pipe {
    let task = Process()
    task.launchPath = launchPath
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    
    return pipe
}

func getContaineredPath(path: String) -> String {
    return FileManager.default.homeDirectoryForCurrentUser.path + path
}

class ViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "miscord-mac", ofType: "bin")
        if (path == nil) {
            textView.string = "Binary not found."
            return
        }
        let output = shell(launchPath: path!)
        let outHandle = output.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var progressObserver : NSObjectProtocol!
        progressObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSFileHandleDataAvailable,
            object: outHandle, queue: nil)
        {
            notification -> Void in
            let data = outHandle.availableData
            
            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    self.textView.string += str
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                // That means we've reached the end of the input.
                NotificationCenter.default.removeObserver(progressObserver)
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func openConfigLocationClicked(_ sender: Any) {
        NSWorkspace.shared.openFile(getContaineredPath(path: "/Library/Application Support/Miscord/"))
    }
}

