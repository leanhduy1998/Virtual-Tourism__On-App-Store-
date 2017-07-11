//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static func downloadLocationImagesUrls(page: Int, latitude: Float, longitude: Float, completeHandler: @escaping (_ result: [String],_ error: String) -> Void) {
        
        var imageUrlArr = [String]()
        
        let request = NSMutableURLRequest(url: FlickrClient.searchImage(page: page, latitude: latitude, longitude: longitude))
        let session = URLSession.shared

        let task = session.dataTask(with: (request as? URLRequest)!, completionHandler: { (data, respond, error) in
            if error == nil {
                var parsedData: [String:AnyObject] = [:]
                do {
                    try parsedData = (JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject])!
                }
                catch {
                    print("parse data err")
                    completeHandler([String()],error.localizedDescription)
                }
                guard let photos = parsedData["photos"] as? [String:AnyObject] else {
                    completeHandler([String()],"photos err")
                    return
                }
                guard let photoArr = photos["photo"] as? [[String:AnyObject]] else {
                    completeHandler([String()],"photoArr err")
                    return
                }
                
                for photo in photoArr {
                    guard let url = photo["url_m"] as? String else {
                        completeHandler([String()],"url err")
                        return
                    }
                    imageUrlArr.append(url)
                }
                completeHandler(imageUrlArr, "")
                
 //               self.collectionView?.reloadData()
            }
            else {
                completeHandler([String](), "task err")
            }
        })
        task.resume()
    }
    
    private static func searchImage(page: Int, latitude: Float, longitude: Float) -> URL {
        var parameter = [String:String]()
        parameter[FlickrConstant.RequestParameter.Method] = FlickrConstant.Method.SearchImage
        return buildUrl(parameter: parameter, latitude: latitude, longitude: longitude, page: page)
    }
    
    private static func buildUrl(parameter: [String:String],latitude: Float, longitude: Float, page: Int) ->  URL {
        var urlDictionary = parameter
        
        let movedLatitude = latitude + 1
        let movedLongitude = longitude + 1
        
        let bbox = "\(longitude),\(latitude),\(movedLongitude),\(movedLatitude)"
        
        urlDictionary[FlickrConstant.RequestParameter.ApiKey] = FlickrConstant.API.key
        urlDictionary[FlickrConstant.RequestParameter.Format] = FlickrConstant.RespondParameter.REST
        urlDictionary[FlickrConstant.RequestParameter.BBox] = "\(bbox)"
        urlDictionary[FlickrConstant.RequestParameter.Extra] = FlickrConstant.RespondParameter.Extra
        urlDictionary[FlickrConstant.RequestParameter.Format] = FlickrConstant.RespondParameter.Format
        urlDictionary[FlickrConstant.RequestParameter.NoJSONCallback] = FlickrConstant.RespondParameter.DisableJSONCallback
        urlDictionary[FlickrConstant.RequestParameter.perPage] = "\(String(format: "%d ", 30))"
        urlDictionary[FlickrConstant.RequestParameter.Page] = "\(String(format: "%d ", page))"

        
        let urlString = "\(FlickrConstant.APIBaseUrl)\(escapedParameter(parameter: urlDictionary))"
        let url = URL(string: urlString)
        return url!
    }
    
    private static func escapedParameter(parameter: [String:String]) -> String{
        if parameter.isEmpty {
            return ""
        }
        var parameterArr = [String]()
        for (key,value) in parameter {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            parameterArr.append(key + "=" + "\(escapedValue!)")
        }
        return parameterArr.joined(separator: "&")
    }
}
