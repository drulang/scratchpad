//
//  AboutViewController.swift
//  paddy
//
//  Created by dru2 on 10/15/18.
//  Copyright © 2018 Dru Lang. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
    }
    
}

extension AboutViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> AboutViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("AboutViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? AboutViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
