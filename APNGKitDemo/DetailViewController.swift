//
//  DetailViewController.swift
//  APNGKit
//
//  Created by Wei Wang on 15/8/30.
//  Copyright © 2015年 OneV's Den. All rights reserved.
//

import UIKit
import APNGKit

class DetailViewController: UIViewController {

    var image: Image?
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: APNGImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let path = image?.path,
               data = NSData(contentsOfFile: path){
            let apngImage = APNGImage(data: data)

            imageView.image = apngImage
            imageView.startAnimating()
                
            textLabel.text = image!.description
                
            title = (path as NSString).lastPathComponent
        }
        
        performSelector("miao", withObject: self, afterDelay: 2.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
