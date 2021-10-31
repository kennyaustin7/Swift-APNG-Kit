//
//  ViewController.swift
//  Demo-macOS
//
//  Created by Wang Wei on 2021/10/31.
//

import Cocoa
import APNGKit

class SamplesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    static let images: [String] = [
        "elephant_apng@2x",
        "elephant_apng",
        "APNG-4D",
        "spinfox",
        "ball",
        "APNG-cube",
        "pyani",
        "pia",
        "over_none",
        "over_background",
        "over_previous",
        "minimal"
    ]
    
    @IBOutlet weak var imageView: APNGImageView!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("SampleImageTableCell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = Self.images[row]
        
        if let url = Bundle.main.url(forResource: Self.images[row], withExtension: "apng") {
            cell.imageView?.image = NSImage(contentsOf: url)
        } else {
            cell.imageView?.image = NSImage(named: Self.images[row])
        }
        
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Self.images.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow >= 0 else { return }
        let name = Self.images[tableView.selectedRow]
        do {
            let image = try APNGImage(named: name)
            
            imageViewWidthConstraint.constant = image.size.width
            imageViewHeightConstraint.constant = image.size.height
            
            imageView.image = image
        } catch {
            if let i = error.apngError?.normalImage {
                imageView.staticImage = i
            }
        }
    }
}

class SpecTestViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

