//
// Copyright © 2016 Daniel Farrelly
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// *	Redistributions of source code must retain the above copyright notice, this list
//		of conditions and the following disclaimer.
// *	Redistributions in binary form must reproduce the above copyright notice, this
//		list of conditions and the following disclaimer in the documentation and/or
//		other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

internal struct Article {
    
    let key: String?
    
    let title: String
    
    let body: String
    
    let buildMin: Int
    
    let buildMax: Int
    
    let relatedKeys: [String]
    
    internal init?(dictionary: [String: AnyObject]) {
        self.key = dictionary["key"] as? String
        self.title = dictionary["title"] as? String ?? ""
        self.body = dictionary["body"] as? String ?? ""
        self.relatedKeys = dictionary["related_articles"] as? [String] ?? []
        
        // Parse the minimum build
        if let int = dictionary["build_min"] as? Int {
            self.buildMin = int
        }
        else if let string = dictionary["build_min"] as? String, let int = Int(string) {
            self.buildMin = int
        }
        else {
            self.buildMin = 0
        }

        // Parse the maximum build
        if let int = dictionary["build_max"] as? Int {
            self.buildMax = int
        }
        else if let string = dictionary["build_max"] as? String, let int = Int(string) {
            self.buildMax = int
        }
        else {
            self.buildMax = Int.max
        }

        // Require both a title and a body
        if title.isEmpty || body.isEmpty {
            return nil
        }
        
        // Compare to the build number
        if let build = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String where Int(build) < buildMin && Int(build) > buildMax {
            return nil
        }
    }
    
    internal func matches(query: String) -> Bool {
        if query.isEmpty {
            return true
        }
        
        let lowercaseQuery = query.lowercaseString
        
        if self.title.lowercaseString.rangeOfString(lowercaseQuery) != nil {
            return true
        }
            
        else if self.body.lowercaseString.rangeOfString(lowercaseQuery) != nil {
            return true
        }
        
        return false
    }
    
}
