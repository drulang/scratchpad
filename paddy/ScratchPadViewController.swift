//
//  ScratchPadViewController.swift
//  paddy
//
//  Created by Dru Lang on 10/13/18.
//  Copyright © 2018 Dru Lang. All rights reserved.
//

import Cocoa

class ScratchPadViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension ScratchPadViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ScratchPadViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("ScratchPadViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ScratchPadViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
