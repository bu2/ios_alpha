//
//  AppDelegate.swift
//  ios_alpha
//
//  Created by bu2 on 26/07/2020.
//  Copyright © 2020 bu2. All rights reserved.
//

import UIKit
import Turbolinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController = UINavigationController()
    var session = Session()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationController
        startApplication()
    }
    
    func startApplication() {
        session.delegate = self
        
        registerDefaultsFromSettingsBundle()
        
        let ROOT_URL = UserDefaults.standard.string(forKey: "root_url_preference")!
        NSLog("ROOT_URL = \(ROOT_URL)")
        
        visit(URL: URL(string: ROOT_URL)!)
    }
    
    func registerDefaultsFromSettingsBundle()
    {
        let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]

        var defaultsToRegister = Dictionary<String, Any>()

        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                NSLog("Key not found")
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
    
    func visit(URL: URL) {
        let visitableViewController = VisitableViewController(url: URL)
        navigationController.pushViewController(visitableViewController, animated: true)
        session.visit(visitableViewController)
    }
}

extension AppDelegate: SessionDelegate {
    func session(_ session: Session, didProposeVisitToURL URL: URL, withAction action: Action) {
        if URL.relativePath == "/back" {
            navigationController.popViewController(animated: true)
        } else {
            visit(URL: URL)
        }
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        navigationController.present(alert, animated: true, completion: nil)
    }
}
