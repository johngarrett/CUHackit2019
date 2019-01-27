//
//  AppDelegate.swift
//  CUHackit2019
//
//  Created by John Garrett on 1/26/19.
//  Copyright © 2019 John Garrett. All rights reserved.
//

import UIKit
import Firebase
import AWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		
		let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:db991d66-92e9-4e44-adf0-71d8eada9226")
		let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
		AWSServiceManager.default().defaultServiceConfiguration = configuration

		return true
	}
}
