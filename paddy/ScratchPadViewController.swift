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
    enum FontSize: Int {
        case small = 15
        case medium = 18
        case large = 21
    }

    @IBOutlet private var textView: NSTextView!

    weak var delegate: ScratchPadViewControllerDelegate?

    @IBAction private func settingsButtonTapped(_ sender: Any) {
        delegate?.settingsButtonTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        textView.font = NSFont(name: "helvetica", size: 17)
        textView.string = UserDefaults.standard.value(forKey: "padData") as? String ?? ""

        if let fontSizeRaw = UserDefaults.standard.value(forKey: "padFontSize") as? Int,
            let fontSize = FontSize(rawValue: fontSizeRaw) {
            setFont(size: fontSize)
        } else {
            setFont(size: .medium)
        }

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

    private func setup() {
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }

    func setFont(size: FontSize) {
        textView.font = NSFont(name: "helvetica", size: CGFloat(size.rawValue))
        saveFontSize(size)
    }

    @objc func insertHorizontalRule() {
        textView.insertText("\n———————————————————————\n")
    }
    private func saveFontSize(_ size: FontSize) {
        UserDefaults.standard.set(size.rawValue, forKey: "padFontSize")
        UserDefaults.standard.synchronize()
    }
    

    override func keyDown(with event: NSEvent) {
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "h",
             [.command, .shift] where event.characters == "h":
            insertHorizontalRule()
        default:
            break
        }
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
