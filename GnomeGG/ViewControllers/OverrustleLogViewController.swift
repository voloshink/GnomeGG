//
//  OverrustleLogViewController.swift
//  GnomeGG
//
//  Created by Kirill Voloshin on 6/8/19.
//  Copyright © 2019 Kirill Voloshin. All rights reserved.
//

import UIKit

class OverrustleLogViewController: LogViewController {

    var overrustleURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func loadInitialMessages() {
        super.loadInitialMessages()


        dggAPI.getUserLogs(for: overrustleURL!, completionHandler: { messages in
            guard let messages = messages else {
                self.loadFailed()
                return
            }
            
            guard self.controllerIsActive else {
                return
            }

            DispatchQueue.global(qos: .utility).async {
                for message in messages {
                    guard let parsedMessage = DGGParser.parseOverrustleLogLine(line: message) else {
                        print("error parsing message")
                        continue
                    }
                    
                    guard self.controllerIsActive else {
                        return
                    }
                    
                    self.renderedMessages.append(renderMessage(message: parsedMessage, isLog: self.isLog))
                    self.messages.append(parsedMessage)
                    
                    if self.messages.count % 100 == 0 {
                        DispatchQueue.main.async {
                            print("adding more messages")
                            print(String(self.messages.count) + " out of " + String(messages.count))
                            self.doneLoading()
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.doneLoading()
                }
            }
        })
    }

}
