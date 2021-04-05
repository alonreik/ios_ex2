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
    


