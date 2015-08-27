//
//  Reader.swift
//  APNGKit
//
//  Created by WANG WEI on 2015/08/27.
//  Copyright © 2015年 OneV's Den. All rights reserved.
//

import Foundation

struct Reader {
    
    private let stream: NSInputStream
    private var totalBytesRead = 0
    private let dataLength: Int
    
    private var buffers = [Int: Array<UInt8>]()
    
    let maxBufferCount: Int
    
    init(data: NSData, maxBuffer: Int = 0) {
        stream = NSInputStream(data: data)
        maxBufferCount = maxBuffer
        dataLength = data.length
        
        for i in 0...maxBuffer {
            buffers[i] = Array<UInt8>(count: i, repeatedValue: 0)
        }
    }
    
    func beginReading() {
        stream.open()
    }
    
    func endReading() {
        stream.close()
    }
    
    mutating func read(buffer: UnsafeMutablePointer<UInt8>, bytesCount: Int) -> Int {
        if stream.streamStatus == NSStreamStatus.AtEnd {
            return 0
        }
        
        if stream.streamStatus != NSStreamStatus.Open {
            fatalError("The stream is not in Open status. This may occur when you try to read before calling beginReading() or after endReading(). It could also be caused by you are trying to read from multiple threads. Reader is not support multithreads reading! Current status is: \(stream.streamStatus.rawValue)")
        }
        
        if bytesCount == 0 {
            print("Trying to read 0 byte.")
            return 0
        }
        
        if totalBytesRead < dataLength {
            let dataRead = stream.read(buffer, maxLength: bytesCount)
            totalBytesRead += dataRead
            
            return dataRead
        } else {
            return 0
        }
    }
    
    mutating func read(bytesCount: Int) -> (data: [UInt8], bytesCount: Int) {
        
        if stream.streamStatus == NSStreamStatus.AtEnd {
            return ([], 0)
        }
        
        if stream.streamStatus != NSStreamStatus.Open {
            fatalError("The stream is not in Open status. This may occur when you try to read before calling beginReading() or after endReading(). It could also be caused by you are trying to read from multiple threads. Reader is not support multithreads reading! Current status is: \(stream.streamStatus.rawValue)")
        }
        
        if bytesCount > maxBufferCount {
            fatalError("Can not read byte count: \(bytesCount) since it beyonds the maxBufferCount of the reader, which is \(maxBufferCount). Please try to use a larger buffer.")
        }
        
        if bytesCount == 0 {
            print("Trying to read 0 byte.")
            return ([], 0)
        }
        
        if totalBytesRead < dataLength {
            var buffer = buffers[bytesCount]!
            let dataRead = stream.read(&buffer, maxLength: buffer.count)
            totalBytesRead += dataRead
            
            return (buffer, dataRead)
        } else {
            return ([], 0)
        }
    }
}