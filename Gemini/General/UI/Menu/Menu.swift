//
//  Menu.swift
//  Gemini
//
//  Created by Dylan Modesitt on 1/8/18.
//  Copyright © 2018 modesitt. All rights reserved.
//

import UIKit
import SWRevealViewController
import BusyNavigationBar


@objc protocol WithMenu {
    func menuClicked()
    var shouldLoadMenu: Bool { get set }
    var doesUsePanGesture: Bool { get set }
}

extension WithMenu where Self:UIViewController, Self: SWRevealViewControllerDelegate {
    // MARK: Methods
    
    /// Initialize menu button that will open reveal the SWRevealController upon click
    ///
    /// - seealso: `SWRevealController`, for a description of the slide menu
    ///
    func initializeMenu() {
        self.revealViewController()?.delegate = self
        let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(menuClicked))
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    /// toggle the side menu
    ///
    /// - seealso: `SWRevealController`, for a description of the slide menu methods
    ///
    func menuWasClicked() {
        // dismiss any popover or modal ViewControllers
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        self.revealViewController().revealToggle(animated: true)
    }
    
    /// check to see if the menu button is currently on the navigation bar
    func doesHaveMenuCurrently() -> Bool {
        return self.navigationItem.leftBarButtonItem?.image == UIImage(named: "menu")
    }
    
    func setStatusBarDark() { UIApplication.shared.statusBarStyle = .default }
    
    func setStatusBarLight() { UIApplication.shared.statusBarStyle = .lightContent }
    
    
    // MARK: View Controller Lifecycle
    
    func initializeMenuWhenViewDidLoad() {
        if shouldLoadMenu {
            initializeMenu()
        }
    }
    
    func initializeMenuWhenViewDidAppear() {
        if shouldLoadMenu {
            if doesUsePanGesture {
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    func initializeMenuWhenViewDidDisappear() {
        if shouldLoadMenu {
            setStatusBarLight()
        }
    }
    
    
}


class UIViewControllerWithMenu: UIViewController, WithMenu, SWRevealViewControllerDelegate {
    
    // MARK: View Controller Lifecycle
    var shouldLoadMenu: Bool = true
    var doesUsePanGesture: Bool = true
    var shouldLoadLightStatusBar: Bool = true
    
    func menuClicked() { menuWasClicked() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuWhenViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeMenuWhenViewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        initializeMenuWhenViewDidDisappear()
    }
    
    /// Side menu is changing position
    ///
    /// - seealso: `SWRevealController`, for a description of the slide menu methods
    ///
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left && shouldLoadLightStatusBar {
            setStatusBarLight()
        } else {
            setStatusBarDark()
        }
    }
    
    /// Side menu has changed position
    ///
    /// - seealso: `SWRevealController`, for a description of the slide menu methods
    ///
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left && shouldLoadLightStatusBar {
            setStatusBarLight()
        } else {
            setStatusBarDark()
        }
    }
    
}

class UITableViewControllerWithMenu: UITableViewController, WithMenu, SWRevealViewControllerDelegate {
    
    // MARK: View Controller Lifecycle
    var isShowing: Bool = true
    
    var shouldLoadMenu: Bool = true
    var doesUsePanGesture: Bool = true
    var shouldLoadLightStatusBar: Bool = true
    
    func menuClicked() { menuWasClicked() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuWhenViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeMenuWhenViewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.isShowing = false
        initializeMenuWhenViewDidDisappear()
    }
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left && shouldLoadLightStatusBar {
            setStatusBarLight()
        } else {
            setStatusBarDark()
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left && shouldLoadLightStatusBar {
            setStatusBarLight()
        } else {
            setStatusBarDark()
        }
    }
    
}

class UIPageViewControllerWithMenu: UIPageViewController, WithMenu, SWRevealViewControllerDelegate {
    
    // MARK: View Controller Lifecycle
    var shouldLoadMenu: Bool = true
    var doesUsePanGesture: Bool = false
    var shouldLoadLightStatusBar: Bool = true
    
    func menuClicked() { menuWasClicked() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuWhenViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeMenuWhenViewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        initializeMenuWhenViewDidDisappear()
    }
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left && shouldLoadLightStatusBar {
            setStatusBarLight()
        } else {
            setStatusBarDark()
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left && shouldLoadLightStatusBar {
            setStatusBarLight()
        } else {
            setStatusBarDark()
        }
    }
    
}


