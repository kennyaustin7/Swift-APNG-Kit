//
//  ViewController.swift
//  APNGKitDemo
//
//  Created by Wei Wang on 15/8/29.
//  Copyright © 2015年 OneV's Den. All rights reserved.
//

import UIKit
import APNGKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var image: APNGImage?
        var imageView: APNGImageView?
        
        for i in 0 ..< 1 {
            for j in 0 ..< 1 {
                if let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("spinfox", ofType: "png")!) {
                    image = APNGImage(data: data)
                    imageView = APNGImageView(image: image)
                    imageView!.center = view.center
                }
            }
        }
        view.addSubview(imageView!)
        imageView?.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

