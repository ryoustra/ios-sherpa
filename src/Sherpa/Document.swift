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

import UIKit

internal class Document {
	
	// MARK: Customising appearance
	
	internal var tintColor: UIColor? = UINavigationBar.appearance().tintColor
	
	internal var articleBackgroundColor: UIColor = UIColor.whiteColor()
	
	internal var articleTextColor: UIColor = UIColor.darkTextColor()
	
	internal var articleCellClass = UITableViewCell.self
	
	internal var feedbackCellClass = UITableViewCell.self
	
	// MARK: Feedback points.
	
	internal var feedbackEmail: String? = nil
	
	internal var feedbackTwitter: String? = nil
	
	// MARK: Instance life cycle
	
	internal let fileURL: NSURL?
	
	internal var sections: [Section] = []
	
	internal init(fileAtURL fileURL: NSURL) {
		self.fileURL = fileURL
		self._loadFromFile()
	}
	
	internal init(dictionary: [String: AnyObject]) {
		self.fileURL = nil
		self._load(from: dictionary)
	}
	
	internal init(array: [[String: AnyObject]]) {
		self.fileURL = nil
		self._load(from: array)
	}
	
	// MARK: Retrieving content
	
	internal func section(index: Int) -> Section? {
		if index < 0 || index >= self.sections.count { return nil }
		
		return self.sections[index]
	}
	
	internal func article(key: String) -> Article? {
		return self.sections.flatMap({ $0.articles }).filter({ key == $0.key }).first
	}
	
	// MARK: Utilities

	private func _loadFromFile() {
		do {
			guard let fileURL = self.fileURL, let data = NSData(contentsOfURL: fileURL) else {
				return
			}
			
			let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
			
			if let dictionary = json as? [String:AnyObject] {
				self._load(from: dictionary)
			}
				
			else if let array = json as? [[String:AnyObject]] {
				self._load(from: array)
			}
		}
		catch {
			return
		}
	}
	
	private func _load(from dictionary: [String:AnyObject]) {
		// Feedback email
		let emailRegex = "^\\s*(\"?[^\"]\"?\\s)?<?.+@.+>?\\s*$"
		if let string = dictionary["feedback_email"] as? String where string.rangeOfString(emailRegex, options: .RegularExpressionSearch) != nil {
			feedbackEmail = string
		}
		else {
			feedbackEmail = nil
		}
		
		// Feedback twitter
		let twitterRegex = "^\\s*[@＠]?[a-zA-Z0-9_]{1,20}\\s*$"
		if let string = dictionary["feedback_twitter"] as? String where string.rangeOfString(twitterRegex, options: .RegularExpressionSearch) != nil {
			let characterSet = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
			characterSet.addCharactersInString("@＠")
			feedbackTwitter = string.stringByTrimmingCharactersInSet(characterSet)
		}
		else {
			feedbackTwitter = nil
		}
		
		// Sections
		self._load(from: dictionary["entries"] as? [[String:AnyObject]] ?? [])
	}
	
	private func _load(from array: [[String:AnyObject]]) {
		self.sections = array.flatMap({ Section(dictionary: $0) })
	}
	
}
