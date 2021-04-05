//
//  ConcentrationThemeChooserViewController.swift
//  Concentration
//
//  Created by Alon Reik on 04/04/2021.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController {

    // An array of strings representing themes for a concentration game.
    // The names of the themes correspond to the titles of the UIButtons (that appear in the storyBoard), and
    // their indices correspond to the indices of the themes array in ConcentrationViewController.swift.
    let themes = ["Halloween", "Animals", "Sports", "Food", "Faces", "Flags"]
    
    // The nearest ancestor in the view controller hierarchy that is a split view controller.
    // (could be nil if there are no splitViews in the hierarchy.
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        // if a splitViewController is found, return the "detail" (viewControllers.last) as a ConcentrationViewController
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    //
    @IBAction func changeTheme(_ sender: Any) {
        
        // Search the hirerachy for a splitView controller that its detail is a ConcentrationViewController:
        if let concentrationVC = splitViewDetailConcentrationViewController {
            // Assuming that sender is a button on the master view (in the splitView), get the
            // title of the button and use it to set\change the gameTheme for Concentration.
            // (without creating a new MVC)
            if let themeName = (sender as? UIButton)?.currentTitle, let themeIndex = themes.firstIndex(of: themeName) {
                print((sender as? UIButton)?.currentTitle)
                concentrationVC.gameTheme = concentrationVC.themes[themeIndex]
            }
        }
         else {
            // if the hirerachy didn't include a splitView controller that its detail is a ConcentrationViewController, create a new MVC:
            print("i am here")
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            // " (sender as? UIButton)? " is the UIbutton that was clicked on.
            if let themeName = (sender as? UIButton)?.currentTitle, let themeIndex = themes.firstIndex(of: themeName) {
                if let concentrationVC = segue.destination as? ConcentrationViewController {
                    // Set the gameTheme of the destination-viewController according to the currently pressed UIButton
                    concentrationVC.gameTheme = concentrationVC.themes[themeIndex]
                }
            }
        }
    }
}
    


