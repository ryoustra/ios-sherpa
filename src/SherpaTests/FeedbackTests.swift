//
// Copyright © 2017 Daniel Farrelly
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

import XCTest
@testable import Sherpa
import MessageUI
import Social
import SafariServices

class FeedbackTests: XCTestCase {

	let emailLabel = NSLocalizedString("Email", comment: "FEEDBACK_LABEL_EMAIL");
	
	let twitterLabel = NSLocalizedString("Twitter", comment: "FEEDBACK_LABEL_TWITTER");

	func testValidEmail() {
		let feedback = Sherpa.FeedbackEmail(string: "support@jellystyle.com")
		
		XCTAssertNil(feedback?.name, "FeedbackEmail.name should be nil if there is no name value in the provided string.")
		XCTAssertEqual(feedback?.email, "support@jellystyle.com", "FeedbackEmail.email should match the email value in the provided string.")
		XCTAssertEqual(feedback?.label, self.emailLabel, "FeedbackEmail.label should always match the given string.")
		XCTAssertEqual(feedback?.detail, "support@jellystyle.com", "FeedbackEmail.detail should match the email value in the provided string.")
		XCTAssertEqual(feedback?.fullString, "support@jellystyle.com", "FeedbackEmail.fullString should match the full value in the provided string.")
	}
	
	func testValidEmailWithName() {
		let feedback = Sherpa.FeedbackEmail(string: "JellyStyle Support <support@jellystyle.com>")
		
		XCTAssertEqual(feedback?.name, "JellyStyle Support", "FeedbackEmail.name should match the name value in the provided string.")
		XCTAssertEqual(feedback?.email, "support@jellystyle.com", "FeedbackEmail.email should match the email value in the provided string.")
		XCTAssertEqual(feedback?.label, self.emailLabel, "FeedbackEmail.label should always match the given string.")
		XCTAssertEqual(feedback?.detail, "support@jellystyle.com", "FeedbackEmail.detail should match the email value in the provided string.")
		XCTAssertEqual(feedback?.fullString, "JellyStyle Support <support@jellystyle.com>", "FeedbackEmail.fullString should match the full value in the provided string.")
	}
	
	func testEmailAsInvalidString() {
		let feedback = Sherpa.FeedbackEmail(string: "JellyStyle Support")
		
		XCTAssertNil(feedback, "FeedbackEmail should not initialise with an invalid string value.")
	}
	
	func testEmptyEmail() {
		let feedback = Sherpa.FeedbackEmail(string: "")
		
		XCTAssertNil(feedback, "FeedbackEmail should not initialise with an empty string value.")
	}
	
	func testValidTwitter() {
		let feedback = Sherpa.FeedbackTwitter(string: "jellybeansoup")
		
		XCTAssertEqual(feedback?.handle, "jellybeansoup", "FeedbackTwitter.handle should match the value in the provided string.")
		XCTAssertEqual(feedback?.label, self.twitterLabel, "FeedbackTwitter.label should always match the given string.")
		XCTAssertEqual(feedback?.detail, "@jellybeansoup", "FeedbackTwitter.detail should match the value in the provided string, prefixed with an '@'.")
	}
	
	func testValidTwitterWithAt() {
		let feedback = Sherpa.FeedbackTwitter(string: "@jellybeansoup")
		
		XCTAssertEqual(feedback?.handle, "jellybeansoup", "FeedbackTwitter.handle should match the value in the provided string.")
		XCTAssertEqual(feedback?.label, self.twitterLabel, "FeedbackTwitter.label should always match the given string.")
		XCTAssertEqual(feedback?.detail, "@jellybeansoup", "FeedbackTwitter.detail should match the value in the provided string, prefixed with an '@'.")
	}
	
	func testValidTwitterWithAlternateAt() {
		let feedback = Sherpa.FeedbackTwitter(string: "＠jellybeansoup")

		XCTAssertEqual(feedback?.handle, "jellybeansoup", "FeedbackTwitter.handle should match the value in the provided string.")
		XCTAssertEqual(feedback?.label, self.twitterLabel, "FeedbackTwitter.label should always match the given string.")
		XCTAssertEqual(feedback?.detail, "@jellybeansoup", "FeedbackTwitter.detail should match the value in the provided string, prefixed with an '@'.")
	}
	
	func testTwitterAsInvalidString() {
		let feedback = Sherpa.FeedbackTwitter(string: "Daniel Farrelly")
		
		XCTAssertNil(feedback, "FeedbackTwitter should not initialise with an invalid string value.")
	}
	
	func testEmptyTwitter() {
		let feedback = Sherpa.FeedbackTwitter(string: "")
		
		XCTAssertNil(feedback, "FeedbackTwitter should not initialise with an empty string value.")
	}

}
