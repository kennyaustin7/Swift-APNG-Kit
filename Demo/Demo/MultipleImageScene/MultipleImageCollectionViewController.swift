//
//  MultipleImageCollectionViewController.swift
//  Demo
//
//  Created by Wang Wei on 2022/03/11.
//

import UIKit
import APNGKit

class MultipleImageCollectionViewController: UICollectionViewController {
    
    static let availableImages: [APNGImage] = sampleImages.compactMap {
        try? APNGImage(named: $0)
    }
    
    var images: [APNGImage] = MultipleImageCollectionViewController.availableImages
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MultipleImageCollectionViewCell", for: indexPath
        ) as! MultipleImageCollectionViewCell
        cell.setImage(images[indexPath.item])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MultipleImageCollectionViewCell
        try? cell.animatedImageView.reset()
    }
    
    @IBAction func addImage(_ sender: Any) {
        let random = Int.random(in: 0 ..< MultipleImageCollectionViewController.availableImages.count)
        images.append(MultipleImageCollectionViewController.availableImages[random])
        
        let targets: [IndexPath] = [.init(item: images.count - 1, section: 0)]
        collectionView.insertItems(at: targets)
        collectionView.scrollToItem(at: targets[0], at: .bottom, animated: true)
    }
}
