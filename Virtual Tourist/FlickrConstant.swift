//
//  FlickrConstant.swift
//  Virtual Tourist
//
//  Created by Duy Le on 6/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class FlickrConstant {
    static let APIBaseUrl = "https://api.flickr.com/services/rest/?"
    struct API {
        static let key = "bf4c23ee659157055dfdbf4f5bb322f8"
    }
    struct Method {
        static let SearchImage = "flickr.photos.search"
    }
    struct RequestParameter {
        static let Method = "method"
        static let BBox = "bbox"
        static let Radius = "radius"
        static let ApiKey = "api_key"
        static let Format = "format"
        static let Extra = "extras"
        static let NoJSONCallback = "nojsoncallback"
        static let perPage = "per_page"
        static let Page = "page"
    }
    struct RespondParameter {
        static let REST = "rest"
        static let Format = "json"
        static let Extra = "url_m"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
    }
}
