//
//  ViewController.swift
//  Wave-Sample-macOS
//
//  Copyright (c) 2022 Janum Trivedi.
//

import Cocoa
import Wave

class ViewController: NSViewController {

    var rounded: Bool = false
    
    let pipViewController = PictureInPictureViewController()
    let gridViewController = GridViewController()

    @IBOutlet weak var tabView: NSTabView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.tabViewItem(at: 0).view = pipViewController.view
    }
}
