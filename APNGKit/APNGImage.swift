//
//  APNGImage.swift
//  APNGKit
//
//  Created by WANG WEI on 2015/08/27.
//  Copyright © 2015年 OneV's Den. All rights reserved.
//

import Foundation

/// APNG animation should repeat forever.
public let RepeatForever = -1

/// Represents a decoded APNG image. 
/// You can use instance of this class to get image information or display it on screen with `APNGImageView`.
/// `APNGImage` can hold an APNG image or a regular PNG image. If latter, there will be only one frame in the image.
public class APNGImage {
    
    /// Total duration of the animation
    public var duration: NSTimeInterval {
        return frames.reduce(0.0) {
            $0 + $1.duration
        }
    }
    
    /// Size of the image in point. The scale factor is considered.
    public var size: CGSize {
        return CGSizeMake(internalSize.width / scale, internalSize.height / scale)
    }
    
    /// Scale of the image.
    public let scale: CGFloat
    
    /// Repeat count of animation of the APNG image.
    /// It is read from APNG data. However, you can change it to modify the loop behaviors.
    /// Set this to `RepeatForever` will make the animation loops forever.
    public var repeatCount: Int
    
    let firstFrameHidden: Bool
    var frames: [Frame]
    var bitDepth: Int
    
    // Strong refrence to another APNG to hold data if this image object is retrieved from cache
    // The frames data will not be changed once a frame is setup.
    // So we could share the bytes in it between two "same" APNG image objects.
    private let dataOwner: APNGImage?
    private let internalSize: CGSize // size in pixel
    
    static var searchBundle: NSBundle = NSBundle.mainBundle()

    init(frames: [Frame], size: CGSize, scale: CGFloat, bitDepth: Int, repeatCount: Int, firstFrameHidden hidden: Bool) {
        self.frames = frames
        self.internalSize = size
        self.scale = scale
        self.bitDepth = bitDepth
        self.repeatCount = repeatCount
        self.firstFrameHidden = hidden
        dataOwner = nil
    }
    
    init(apng: APNGImage) {
        // The image init from this method will share the same data trunk with the other apng obj
        dataOwner = apng
        
        self.bitDepth = apng.bitDepth
        self.internalSize = apng.internalSize
        self.scale = apng.scale
        self.repeatCount = apng.repeatCount
        self.firstFrameHidden = apng.firstFrameHidden

        self.frames = apng.frames
    }
    
    /**
    Returns the image object associated with the specified filename.
    This method looks in the APNGKit caches for an image object with the specified name and returns a new object with same data if it exists. 
    If a matching image object is not already in the cache, this method locates and loads the image data from disk, and then returns the resulting object. 
    You can not assume that this method is thread safe. If the screen has a scale larger than 1.0, this method first searches for an image file with the 
    same filename with a responding suffix (@2x or @3x) appended to it. For example, if the file’s name is button, it first searches for button@2x. 
    If it finds a 2x, it loads that image and sets the scale property of the returned UIImage object to 2.0. Otherwise, it loads the unmodified filename 
    and sets the scale property to 1.0.

    - note: This method will cache the result image in APNGKit cache system to improve performance. 
            Images in Asset Category is not supported, you can only load files from the app's main bundle.
    
    - parameter imageName: The name of the file. If this is the first time the image is being loaded, 
    the method looks for an image with the specified name in the application’s main bundle.
    
    - returns: The image object for the specified file, or nil if the method could not find the specified image.
    
    */
    public convenience init?(named imageName: String) {
        if let path = imageName.apng_filePathByCheckingNameExistingInBundle(APNGImage.searchBundle) {
            self.init(contentsOfFile:path, saveToCache: true)
        } else {
            return nil
        }
    }
    
    /**
    Creates and returns an image object that uses the specified image data. 
    The scale factor will always be 1.0 if you create the image from data with this method.
    If you need an image at a specified scale, use init methods from disk or -initWithData:scale: instead
    
    - note: This method does not cache the image object.

    - parameter data: The image data of APNG. This can be data from a file or data you get from network.
    
    - returns: A new image object for the specified data, or nil if the method could not initialize the image from the specified data.
    
    */
    public convenience init?(data: NSData) {
        self.init(data: data, scale: 1)
    }
    
    /**
    Creates and returns an image object that uses the specified image data and scale factor.
    
    - note: This method does not cache the image object.

    - parameter data:  The image data of APNG. This can be data from a file or data you get from network.
    - parameter scale: The scale factor to use when interpreting the image data. Specifying a scale factor of 1.0 results in 
                       an image whose size matches the pixel-based dimensions of the image. Applying a different scale factor 
                       changes the size of the image as reported by the size property.
    
    - returns: A new image object for the specified data, or nil if the method could not initialize the image from the specified data.
    */
    public convenience init?(data: NSData, scale: CGFloat) {
        var disassembler = Disassembler(data: data)
        do {
            let (frames, size, repeatCount, bitDepth, firstFrameHidden) = try disassembler.decodeToElements(scale)
            self.init(frames: frames, size: size, scale: scale, bitDepth: bitDepth, repeatCount: repeatCount, firstFrameHidden: firstFrameHidden)
        } catch _ {
            return nil
        }
    }
    
    /**
    Creates and returns an image object by loading the image data from the file at the specified path.
    
    - note: This method does not cache the image object by default. 
            But it is recommended to enable the cache to improve performance, 
            especially if you have multiple same APNG image to show at the same time.
    
    - parameter path:        The path to the file.
    - parameter saveToCache: Should the result image saved to APNGKit caches. Default is false.
    
    - returns: A new image object for the specified file, or nil if the method could not initialize the image from the specified file.
    */
    public convenience init?(contentsOfFile path: String, saveToCache: Bool = false) {
        
        if let apng = APNGCache.defaultCache.imageForKey(path) { // Found in the cache
            self.init(apng: apng)
        } else {
            if let data = NSData(contentsOfFile: path) {
                let fileName = (path as NSString).stringByDeletingPathExtension
                
                var scale: CGFloat = 1
                if fileName.hasSuffix("@2x") {
                    scale = 2
                }
                if fileName.hasSuffix("@3x") {
                    scale = 3
                }
                
                self.init(data: data, scale: scale)
                
                if saveToCache {
                    APNGCache.defaultCache.setImage(self, forKey: path)
                }
            } else {
                return nil
            }
        }
    }
    
    deinit {
        if dataOwner == nil { // Only clean when self owns the data
            for f in frames {
                f.clean()
            }
        }
    }
}

extension APNGImage: CustomStringConvertible {
    public var description: String {
        var s = "<APNGImage: \(unsafeAddressOf(self))> size: \(size), frameCount: \(frames.count), repeatCount: \(repeatCount)\n"
        s += "["
        for f in frames {
            s += "\(f)\n"
        }
        s += "]"
        return s
    }
}

extension String {
    func apng_filePathByCheckingNameExistingInBundle(bundle: NSBundle) -> String? {
        let name = self as NSString
        let fileExtension = name.pathExtension
        let fileName = name.stringByDeletingPathExtension
        
        // If the name is suffixed by 2x or 3x, we think users want to the specified version
        if fileName.hasSuffix("@2x") || fileName.hasSuffix("@3x") {
            var path: String?
            path = bundle.pathForResource(fileName, ofType: fileExtension)
            if path == nil { // If not found. Add png extension and try again
                path = bundle.pathForResource(fileName, ofType: "png")
            }
            return path
        }
        
        // Else, user is passing a common name. We will try to find the version match current scale first
        var path: String?
        let scale = Int(UIScreen.mainScreen().scale)
        
        path = bundle.pathForResource("\(fileName)@\(scale)x", ofType: fileExtension) ??
               bundle.pathForResource("\(fileName)@\(scale)x", ofType: "png") ??
               bundle.pathForResource(fileName, ofType: fileExtension) ?? // Matched scaled version not found, use the 1x version
               bundle.pathForResource(fileName, ofType: "png")
        
        return path
    }
}

