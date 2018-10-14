//
//  ScratchPadViewController.swift
//  paddy
//
//  Created by Dru Lang on 10/13/18.
//  Copyright © 2018 Dru Lang. All rights reserved.
//

import Cocoa

protocol ScratchPadViewControllerDelegate: class {
    func settingsButtonTapped() 
}

class ScratchPadViewController: NSViewController {
    @IBOutlet private var textView: NSTextView!

    weak var delegate: ScratchPadViewControllerDelegate?

    @IBAction func settingsButtonTapped(_ sender: Any) {
        delegate?.settingsButtonTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.font = NSFont(name: "helvetica", size: 17)

        textView.string = UserDefaults.standard.value(forKey: "padData") as? String ?? ""

        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification,
                                               object: nil, queue: nil) { [weak self] (_) in
                                                print("terminate")
                                                guard let self = self else { return }
                                                UserDefaults.standard.set(self.textView.textStorage?.string, forKey: "padData")
                                                UserDefaults.standard.synchronize()
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        textView.window?.makeFirstResponder(textView)
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
