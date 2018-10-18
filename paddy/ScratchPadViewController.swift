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
    func close()
}

class ScratchPadViewController: NSViewController {
    let standardFont: NSFont = NSFont(name: "helvetica", size: 17)!
    enum FontSize: Int {
        case small = 15
        case medium = 18
        case large = 21
    }

    var currentFont: NSFont? {
        get {
            return textView.font
        }
        set {
            textView.font = newValue
            saveFont(newValue ?? standardFont)
        }
    }

    private var fontSize: Int {
        return UserDefaults.standard.value(forKey: "padFontSize") as? Int ?? FontSize.medium.rawValue
    }

    @IBOutlet private var textView: NSTextView!
    weak var delegate: ScratchPadViewControllerDelegate?

    @IBAction private func settingsButtonTapped(_ sender: Any) {
        delegate?.settingsButtonTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        textView.textContainerInset = NSSize(width: 4, height: 6)

        if let savedFontName = UserDefaults.standard.value(forKey: "padFontName") as? String {
            let font = NSFont(name: savedFontName, size: CGFloat(fontSize))
            textView.font = font
        } else {
           textView.font = NSFont(name: "helvetica", size: CGFloat(fontSize))
        }

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
        setFont(size: size.rawValue)
    }

    func setFont(size: Int) {
        textView.font = NSFont(name: currentFont?.fontName ?? "helvetica", size: CGFloat(size))
        saveFontSize(size)
    }

    @objc func insertHorizontalRule() {
        textView.insertText("\n———————————————————————\n")
    }
    private func saveFontSize(_ size: Int) {
        UserDefaults.standard.set(size, forKey: "padFontSize")
        UserDefaults.standard.synchronize()
    }

    private func saveFont(_ font: NSFont){
        let size = Int(font.pointSize)
        let name = font.displayName

        saveFontSize(size)
        UserDefaults.standard.set(name, forKey: "padFontName")
        UserDefaults.standard.synchronize()
    }

    @objc func increaseFontSize() {
        setFont(size: fontSize + 1)
    }
    @objc func decreaseFontSize() {
        setFont(size: fontSize - 1)
    }

    override func keyDown(with event: NSEvent) {
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "h",
             [.command, .shift] where event.characters == "h":
            insertHorizontalRule()
        case [.command] where event.characters == "=":
            increaseFontSize()
        case [.command] where event.characters == "-":
            decreaseFontSize()
        case [.command] where event.characters == "s":
            setFont(size: .small)
        case [.command] where event.characters == "m":
            setFont(size: .medium)
        case [.command] where event.characters == "l":
            setFont(size: .large)
        default:
            break
        }

        if event.characters == "\u{1B}" {
            delegate?.close()
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
