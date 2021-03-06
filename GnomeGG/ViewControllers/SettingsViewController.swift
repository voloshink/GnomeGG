//
//  SettingsViewController.swift
//  GnomeGG
//
//  Created by Kirill Voloshin on 6/1/19.
//  Copyright © 2019 Kirill Voloshin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import StoreKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var authWithDggButton: UIButton!
    @IBOutlet weak var loggedInAsLabel: UILabel!
    @IBOutlet weak var resetUsernameButton: UIButton!
    @IBOutlet weak var rateTheAppButton: UIButton!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var gnomeImageView: UIImageView!
    @IBOutlet weak var authWIthDggHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var harshIgnoreSwitch: UISwitch!
    @IBOutlet weak var chatHighlightSwitch: UISwitch!
    @IBOutlet weak var bbdggEmotesSwitch: UISwitch!
    @IBOutlet weak var syncSettingsSwitch: UISwitch!
    @IBOutlet weak var hideNSFW: UISwitch!
    @IBOutlet weak var showWhispers: UISwitch!
    @IBOutlet weak var chatSuggestions: UISwitch!
    @IBOutlet weak var hideFlairs: UISwitch!
    @IBOutlet weak var showTimestamps: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let twitter = "https://twitter.com/tehpolecat"
    let overrustle = "https://overrustlelogs.net/"
    let github = "https://github.com/voloshink/GnomeGG"
    let dggChat = "https://www.destiny.gg/"
    let pPolicy = "https://polecat.me/GnomeGG/privacy_policy"
    
    var heightConstraints: CGFloat?
    
    var justLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let random = Int.random(in: 0 ..< 4)
        gnomeImageView.isHidden = random != 0
        heightConstraints = authWIthDggHeightConstraint.constant
        harshIgnoreSwitch.isOn = settings.harshIgnore
        chatHighlightSwitch.isOn = settings.usernameHighlights
        bbdggEmotesSwitch.isOn = settings.bbdggEmotes
        hideNSFW.isOn = settings.hideNSFW
        showWhispers.isOn = settings.showWhispersInChat
        chatSuggestions.isOn = settings.autoCompletion
        hideFlairs.isOn = settings.hideFlairs
        showTimestamps.isOn = settings.showTime
        syncSettingsSwitch.isOn = settings.syncSettings
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: 950)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if settings.syncSettings {
            dggAPI.saveSettings()
        }
        if justLoggedIn {
            if let presenterTab = presentingViewController as? CustomTabBarController {
                if let presenter = presenterTab.viewControllers?[1] as? ChatViewController {
                    presenter.connectToWebsocket()
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func updateUI() {
        if settings.dggUsername != "" {
            loggedInAsLabel.text = "Logged in as: " + settings.dggUsername
        } else if settings.dggCookie != "" {
            loggedInAsLabel.text = "Logged in"
        }
        
        if settings.dggCookie != "" {
            authWithDggButton.isHidden = true
            loggedInAsLabel.isHidden = false
            authWIthDggHeightConstraint.constant = 0
            resetUsernameButton.isHidden = false
        } else {
            authWithDggButton.isHidden = false
            loggedInAsLabel.isHidden = true
            authWIthDggHeightConstraint.constant = heightConstraints!
            resetUsernameButton.isHidden = true
        }
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "manageIgnores" {
            let destvc = segue.destination as! StringSettingViewController
            destvc.setting = .Ignores
        }
        
        if identifier == "manageHighlights" {
            let destvc = segue.destination as! StringSettingViewController
            destvc.setting = .Highlights
        }
        
        if identifier == "manageNickHighlights" {
            let destvc = segue.destination as! StringSettingViewController
            destvc.setting = .NickHighlights
        }
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func logoutTap(_ sender: Any) {
        settings.reset()
        updateUI()
    }

    @IBAction func rateTheAppTap(_ sender: Any) {
        if #available( iOS 10.3,*){
            SKStoreReviewController.requestReview()
        }
    }
    @IBAction func chatButtonTap(_ sender: Any) {
        UIApplication.shared.open(URL(string: dggChat)!)
    }
    @IBAction func twitterButtonTap(_ sender: Any) {
        UIApplication.shared.open(URL(string: twitter)!)
    }
    @IBAction func githubButtonTap(_ sender: Any) {
        UIApplication.shared.open(URL(string: github)!)
    }
    
    @IBAction func overrustleButtonTap(_ sender: Any) {
        UIApplication.shared.open(URL(string: overrustle)!)
    }
    @IBAction func harshIgnoreSwitch(_ sender: Any) {
        settings.harshIgnore = harshIgnoreSwitch.isOn
    }
    @IBAction func chatHighlightSwitch(_ sender: Any) {
        settings.usernameHighlights = chatHighlightSwitch.isOn
    }
    @IBAction func bbdggEmoteSwitch(_ sender: Any) {
        settings.bbdggEmotes = bbdggEmotesSwitch.isOn
    }
    @IBAction func syncSettings(_ sender: Any) {
        settings.syncSettings = syncSettingsSwitch.isOn
    }
    @IBAction func hideNSFW(_ sender: Any) {
        settings.hideNSFW = hideNSFW.isOn
    }
    @IBAction func showWhispers(_ sender: Any) {
        settings.showWhispersInChat = showWhispers.isOn
    }
    @IBAction func chatSuggestions(_ sender: Any) {
        settings.autoCompletion = chatSuggestions.isOn
    }
    @IBAction func hideFlairs(_ sender: Any) {
        settings.hideFlairs = hideFlairs.isOn
    }
    @IBAction func showTime(_ sender: Any) {
        settings.showTime = showTimestamps.isOn
    }
    @IBAction func privacyPolicyTap(_ sender: Any) {
        UIApplication.shared.open(URL(string: pPolicy)!)
    }
}
