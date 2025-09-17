//
//  SafariWebExtensionHandler.swift
//  regex Extension
//
//  Created by Augustin on 13.09.25.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let request = context.inputItems.first as? NSExtensionItem

        let profile: UUID?
        if #available(iOS 17.0, macOS 14.0, *) {
            profile = request?.userInfo?[SFExtensionProfileKey] as? UUID
        } else {
            profile = request?.userInfo?["profile"] as? UUID
        }

        let message: Any?
        if #available(iOS 15.0, macOS 11.0, *) {
            message = request?.userInfo?[SFExtensionMessageKey]
        } else {
            message = request?.userInfo?["message"]
        }

        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@ (profile: %@)", String(describing: message), profile?.uuidString ?? "none")

        /*
        let response = NSExtensionItem()
        if #available(iOS 15.0, macOS 11.0, *) {
            response.userInfo = [ SFExtensionMessageKey: [ "echo": message, "test": "test" ] ]
        } else {
            response.userInfo = [ "message": [ "echo": message, "test2": "test2" ] ]
        }

        context.completeRequest(returningItems: [ response ], completionHandler: nil)*/
        
        /*
        guard let message = context.inputItems.first as? NSExtensionItem,
              let userInfo = message.userInfo as? [String: Any],
              let action = userInfo["action"] as? String else {
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["eventName": "messageUnpackFailed", "success": false] ]
            context.completeRequest(returningItems: [], completionHandler: nil)
            return
        }*/
        guard let messageDict = message as? [String: Any] else {
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["eventName": "error", "success": false] ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
            return
        }
        guard let action = messageDict["action"] as? String else{
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["eventName": "error", "success": false] ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
            return
        }
        if action == "getPatterns" {
            var patterns: [String] = []
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.augustin.blocker") {
                let fileURL = containerURL.appendingPathComponent("patterns.json")
                if let data = try? Data(contentsOf: fileURL),
                   let decoded = try? JSONSerialization.jsonObject(with: data) as? [String] {
                    patterns = decoded
                }
            }

            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["eventName": "getResponse", "success": true, "patterns": patterns] ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
        }else if action == "savePatterns" {
            var hasExistingPassword = false
            if let defaults = UserDefaults(suiteName: "group.com.augustin.blocker") {
                hasExistingPassword = defaults.bool(forKey: "hasPassword")
            }
            if hasExistingPassword {
                let response = NSExtensionItem()
                response.userInfo = [ SFExtensionMessageKey: ["eventName": "saveResponse", "success": false, "error": "A password is saved. You can only edit the patterns from within the app."] ]
                context.completeRequest(returningItems: [response], completionHandler: nil)
                return
            }
            guard let patterns = messageDict["patterns"] as? [String] else{
                let response = NSExtensionItem()
                response.userInfo = [ SFExtensionMessageKey: ["eventName": "saveResponse", "success": false, "error": "No patterns were sent."] ]
                context.completeRequest(returningItems: [response], completionHandler: nil)
                return
            }
            if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.augustin.blocker") {
                let fileURL = containerURL.appendingPathComponent("patterns.json")
                do {
                    let data = try JSONSerialization.data(withJSONObject: patterns, options: .prettyPrinted)
                    try data.write(to: fileURL, options: .atomic)
                    let response = NSExtensionItem()
                    response.userInfo = [ SFExtensionMessageKey: ["eventName": "saveResponse", "success": true, "patterns": patterns] ]
                    context.completeRequest(returningItems: [response], completionHandler: nil)
                } catch {
                    let response = NSExtensionItem()
                    response.userInfo = [ SFExtensionMessageKey: ["eventName": "saveResponse", "success": false, "error": error.localizedDescription] ]
                    context.completeRequest(returningItems: [response], completionHandler: nil)
                }
            }
        }else if action == "getPasswordSaved" {
            var hasExistingPassword = false
            if let defaults = UserDefaults(suiteName: "group.com.augustin.blocker") {
                hasExistingPassword = defaults.bool(forKey: "hasPassword")
            }
            print("Password flag:", hasExistingPassword)
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["eventName": "passwordResponse", "success": true, "passwordSaved": hasExistingPassword] ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
        }
    }

}
