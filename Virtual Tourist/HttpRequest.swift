//
//  HttpRequest.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class HttpRequest {
    static func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(downloadError.debugDescription)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        
        task.resume()
    }
    static func downloadURLs(title: String, latitude: Float, longitude: Float, page: Int, completeHandler: @escaping (_ imageUrlsArr: [String]) -> Void){
        FlickrClient.downloadLocationImagesUrls(page: page, latitude: latitude, longitude: longitude) { (imageUrlsArr, error) in
            if error.isEmpty {
                completeHandler(imageUrlsArr)
            }
            else {
                fatalError(error)
            }
        }
    }
}
