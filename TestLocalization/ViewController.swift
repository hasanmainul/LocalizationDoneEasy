//
//  ViewController.swift
//  TestLocalization
//
//  Created by mainul on 8/21/17.
//  Copyright © 2017 mainul. All rights reserved.
//

//
//   Help reference:
//   1. https://medium.com/if-let-swift-programming/working-with-localization-in-swift-4a87f0d393a4
//   2. https://github.com/marmelroy/Localize-Swift
//
//

import UIKit

class ViewController: UIViewController, LanguageChangable {
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var likeThisLabel: UILabel!
    @IBOutlet weak var changeLanguageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helloLabel.text = "Hello, Everyone".localized()
        likeThisLabel.text = "Please like this app".localized()
        changeLanguageButton.setTitle("Change Language".localized(), for: .normal)
        
        LanguageSwitcher.delegate = self

    }

    func languageDidChange() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = self.storyboard?.instantiateInitialViewController()
    }
    
    @IBAction func changeLanguageButtonPressed(_ sender: Any) {
        var actionSheet: UIAlertController!
        actionSheet = UIAlertController(title: nil, message: "Change Language".localized(), preferredStyle: UIAlertControllerStyle.actionSheet)
        for language in LanguageSwitcher.availableLanguages() {
            let displayName = LanguageSwitcher.displayNameForLanguage(language)
            let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                LanguageSwitcher.setLanguage(language: language)
            })
            actionSheet.addAction(languageAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }

}


extension String {
    
    func localized() -> String {
        var bundle = Bundle()
        
        if let path = Bundle.main.path(forResource: LanguageSwitcher.currentLanguage(), ofType: "lproj") {
            bundle = Bundle(path: path)!
        } else {
            let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            bundle = Bundle(path: _path)!
        }
        
        return bundle.localizedString(forKey: self, value: nil, table: nil)
    }
    
}


let APPLE_LANGUAGE_KEY = "AppleLanguages"

class LanguageSwitcher {
    
    static var delegate: LanguageChangable?
    
    class func currentLanguage() -> String {
        let languageArray = UserDefaults.standard.stringArray(forKey: APPLE_LANGUAGE_KEY)!
        return languageArray.first!
    }
    
    class func setLanguage(language: String) {
        let arr = [language, currentLanguage()]
        UserDefaults.standard.set(arr, forKey: APPLE_LANGUAGE_KEY)
        UserDefaults.standard.synchronize()
        delegate?.languageDidChange()
    }
    
    class func availableLanguages(_ excludeBase: Bool = true) -> [String] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.index(of: "Base") , excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    
    /**
     Get the current language's display name for a language.
     - Parameter language: Desired language.
     - Returns: The localized string.
     */
    open class func displayNameForLanguage(_ language: String) -> String {
        let locale : NSLocale = NSLocale(localeIdentifier: currentLanguage())
        if let displayName = locale.displayName(forKey: NSLocale.Key.identifier, value: language) {
            return displayName
        }
        return String()
    }
}

protocol LanguageChangable {
    func languageDidChange()
}
