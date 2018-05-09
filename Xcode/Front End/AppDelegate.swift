// Created by Julian Dunskus

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}
	
	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
		/*
		let panel = NSOpenPanel()
		panel.begin { (response) in
			guard response == .OK, let url = panel.url else { return }
			// TODO
		}
		*/
		return false
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}
