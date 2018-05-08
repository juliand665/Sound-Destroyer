// Created by Julian Dunskus

import Cocoa
import AVFoundation

class ViewController: NSViewController {
	@IBAction func revert(_ sender: Any) {
		document!.revert()
	}
	
	@IBAction func fuckShitUp(_ sender: Any) {
		document!.transmogrify()
	}
	
	@IBAction func play(_ sender: Any) {
		let data = document!.data()
		player?.stop()
		player = try! AVAudioPlayer(data: data)
		player!.play()
	}
	
	@IBAction func stop(_ sender: Any) {
		player?.stop()
	}
	
	var player: AVAudioPlayer?
	
	var document: Document? {
		return view.window?.windowController?.document as? Document
	}
}
