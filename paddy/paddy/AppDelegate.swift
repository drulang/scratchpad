//
//  AppDelegate.swift
//  paddy
//
//  Created by Dru Lang on 10/13/18.
//  Copyright © 2018 Dru Lang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let contextMenu = NSMenu()
    var eventMonitor: EventMonitor?
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    let scratchPadViewController = ScratchPadViewController.freshController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        constructMenu()

        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
             button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        scratchPadViewController.delegate = self
        popover.contentViewController = scratchPadViewController
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }

    @objc func togglePopover(_ sender: Any?) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp  {
            statusItem.menu = contextMenu
            statusItem.popUpMenu(contextMenu)
            statusItem.menu = nil
            return
        }

        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    @objc func increaseFont() {
        scratchPadViewController.increaseFontSize()
    }

    @objc func decreaseFont() {
        scratchPadViewController.decreaseFontSize()
    }

    @objc func showFontSelector() {
        NSFontManager.shared.orderFrontFontPanel(self)
        NSFontManager.shared.target = self
    }

    @objc func changeFont(_ sender: NSFontManager?)  {
        guard let currentFont = scratchPadViewController.currentFont else { return }
        let newFont = sender?.convert(currentFont)
        scratchPadViewController.currentFont = newFont
    }

    @objc func feedbackButtonTapped() {
        closePopover(sender: nil)
        let vc = AboutViewController.freshController()
        scratchPadViewController.presentAsModalWindow(vc)
    }

    @objc func insertHR() {
        scratchPadViewController.insertHorizontalRule()
    }

    private func constructMenu() {

        contextMenu.addItem(NSMenuItem(title: "Insert HR",
                                       action: #selector(insertHR), keyEquivalent: "h"))

        contextMenu.addItem(NSMenuItem(title: "---------",
                                       action: nil, keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Change Font",
                                       action: #selector(showFontSelector), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Increase",
                                       action: #selector(increaseFont), keyEquivalent: "+"))
        contextMenu.addItem(NSMenuItem(title: "Decrease",
                                       action: #selector(decreaseFont), keyEquivalent: "-"))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Feedback",
                                       action: #selector(feedbackButtonTapped), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
}

extension AppDelegate: ScratchPadViewControllerDelegate {
    func settingsButtonTapped() {
        statusItem.menu = contextMenu
        statusItem.popUpMenu(contextMenu)
        statusItem.menu = nil
    }

    func close() {
        closePopover(sender: nil)
    }
}

extension AppDelegate {

}
