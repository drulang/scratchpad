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
        contextMenu.addItem(NSMenuItem(title: "Small",
                                       action: #selector(smallFont), keyEquivalent: "s"))
        contextMenu.addItem(NSMenuItem(title: "Medium",
                                       action: #selector(medFont), keyEquivalent: "m"))
        contextMenu.addItem(NSMenuItem(title: "Large",
                                       action: #selector(largeFont), keyEquivalent: "l"))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Feedback",
                                       action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem.separator())
        contextMenu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

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

    @objc func smallFont() {
        scratchPadViewController.setFont(size: .small)
    }

    @objc func medFont() {
        scratchPadViewController.setFont(size: .medium)
    }

    @objc func largeFont() {
        scratchPadViewController.setFont(size: .large)
    }
}

extension AppDelegate: ScratchPadViewControllerDelegate {
    func settingsButtonTapped() {
        statusItem.menu = contextMenu
        statusItem.popUpMenu(contextMenu)
        statusItem.menu = nil
    }
}
