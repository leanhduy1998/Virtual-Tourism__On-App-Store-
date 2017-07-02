//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class FlickrClient {
    static func searchImage(latitude: Float, longitude: Float) -> URL {
        var parameter = [String:String]()
        parameter[FlickrConstant.RequestParameter.Method] = FlickrConstant.Method.SearchImage
        return buildUrl(parameter: parameter, latitude: latitude, longitude: longitude)
    }
    private static func buildUrl(parameter: [String:String],latitude: Float, longitude: Float) ->  URL {
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
