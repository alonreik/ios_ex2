//
//  ConcentrationThemeChooserViewController.swift
//  Concentration
//
//  Created by Alon Reik on 04/04/2021.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    /* -------
     Constants
     -------- */
    
    // An array of strings representing themes for a concentration game.
    // The names of the themes correspond to the titles of the UIButtons (that appear in the storyBoard), and
    // their indices correspond to the indices of the themes array in ConcentrationViewController.swift.
    let themes = ["Halloween", "Animals", "Sports", "Food", "Faces", "Flags"]
    
    /* ----------
      Properties
     -----------*/
    
    // The nearest ancestor in this view controller's hierarchy that is a split view controller, specifically
    // a split view controller where the detail is a ConcentrationViewController.
    // (could be nil if there are no such splitViews in the hierarchy).
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    // A reference to the last ConcentrationViewController the app segued to (initiated to nil).
    private var lastSeguedToConcentartionViewController: ConcentrationViewController?

    /* -------------------
     Functions for Buttons
     ---------------------*/
    
    // Every button on the ConcentrationThemeChooserViewController in the story board is linked to this function, and  has a title (string).
    // Whenever a button is pressed, its title is used to either segue to a new ConcentrationViewController,
    // or to set the gameTheme of an existing ConcentrationViewController.
    @IBAction func changeTheme(_ sender: Any) {
        
        // if we use splitViews, the following will find the relevant viewController and will set its theme according to the pressed button.
        if let concentrationVC = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let themeIndex = themes.firstIndex(of: themeName) {
                concentrationVC.gameTheme = concentrationVC.themes[themeIndex]
            }
        // if we use navigationBarView, the following will find the relevant viewController and will set its theme according to the pressed button.
        // (When used on iphones, splitViewsControllers are "translated" to navigationControllers).
        } else if let concentrationVC = lastSeguedToConcentartionViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let themeIndex = themes.firstIndex(of: themeName) {
                concentrationVC.gameTheme = concentrationVC.themes[themeIndex]
            }
            navigationController?.pushViewController(concentrationVC, animated: true)
            
        // The following will create a new ConcentrationViewController (segues always create new MVCs) using the button's
        // title (to set the theme). (this case will happen once after initiation).
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    /* ---------------
     Overriden Methods
     ---------------- */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            // " (sender as? UIButton)? " is the UIbutton that was clicked on.
            if let themeName = (sender as? UIButton)?.currentTitle, let themeIndex = themes.firstIndex(of: themeName) {
                if let concentrationVC = segue.destination as? ConcentrationViewController {
                    // Set the gameTheme of the destination-viewController according to the currently pressed UIButton
                    concentrationVC.gameTheme = concentrationVC.themes[themeIndex]
                    lastSeguedToConcentartionViewController = concentrationVC
                }
            }
        }
    }
    
    /* -------
      Methods
     -------- */
    
    override func viewDidLayoutSubviews() {
        print("here")
    }
    
    
    
    // This function is called after self has been loaded from an Interface Builder (the story board).
    // In this case, we set the delegate of the splitViewController that includes self to be self. This way, the downCasting
    // preformed in splitViewController (next function) will work correctly.
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    // This function allows to display the "themeChooserView" (the master view in the splitView) before
    // the ConcentrationView (the detail view in the splitView) when the app loads in a device that doesn't support splitViews.
    // (This way, on iphones, the app loads straight to the "menu" and not to a default theme of the game).
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let concentrationVC = secondaryViewController as? ConcentrationViewController {
            if concentrationVC.gameTheme == nil {
                return true
            }
        }
        return false
    }
}
