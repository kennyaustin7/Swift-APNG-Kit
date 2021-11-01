//
//  APNGKitError.swift
//  
//
//  Created by Wang Wei on 2021/10/05.
//

import Foundation
import ImageIO

public enum APNGKitError: Error {
    case decoderError(DecoderError)
    case imageError(ImageError)
    
    case internalError(Error)
}

extension APNGKitError {
    public enum DecoderError {
        case fileHandleCreatingFailed(URL, Error)
        case fileHandleOperationFailed(FileHandle, Error)
        case wrongChunkData(name: String, data: Data)
        case fileFormatError
        case corruptedData(atOffset: UInt64?)
        case chunkNameNotMatched(expected: [Character], actual: [Character])
        case invalidNumberOfFrames(value: Int)
        case invalidChecksum
        case lackOfChunk([Character])
        case wrongSequenceNumber(expected: Int, got: Int)
        case imageDataNotFound
        case frameDataNotFound(expectedSequence: Int)
        case invalidFrameImageData(data: Data, frameIndex: Int)
        case frameImageCreatingFailed(source: CGImageSource, frameIndex: Int)
        case outputImageCreatingFailed(frameIndex: Int)
        case canvasCreatingFailed
        case multipleAnimationControlChunk
    }
    
    public enum ImageError {
        case resourceNotFound(name: String, bundle: Bundle)
        case normalImageDataLoaded(data: Data, scale: CGFloat)
    }
}

extension APNGKitError {
    public var normalImageData: (Data, CGFloat)? {
        guard case .imageError(.normalImageDataLoaded(let data, let scale)) = self else {
            return nil
        }
        return (data, scale)
    }
}

extension Error {
    public var apngError: APNGKitError? { self as? APNGKitError }
}

extension APNGKitError {
    var shouldRevertToNormalImage: Bool {
        switch self {
        case .decoderError(let reason):
            switch reason {
            case .chunkNameNotMatched(let expected, let actual):
                let isCgBI = expected == IHDR.name && actual == ["C", "g", "B", "I"]
                if isCgBI {
                    printLog("`CgBI` chunk found. It seems that the input image is compressed by Xcode and not supported by APNGKit. Consider to rename it to `apng` to prevent compressing.")
                }
                return isCgBI
            case .lackOfChunk(let name):
                return name == acTL.name
            default:
                return false
            }
        case .imageError:
            return false
        case .internalError:
            return false
        }
    }
}
