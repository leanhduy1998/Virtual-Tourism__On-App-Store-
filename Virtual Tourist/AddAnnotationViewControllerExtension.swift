//
//  AddAnnotationViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Duy Le on 7/8/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import CoreData

extension MapViewController {
    
    
    func isLoading(isLoading: Bool){
        searchTF.isEnabled = !isLoading
        view.isUserInteractionEnabled = !isLoading
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTF.resignFirstResponder()
    }

    func deletaAllDataDebug(){
        do {
            try delegate.stack.dropAllData()
        }
        catch {
            fatalError()
        }
    }

    func saveToCoreData(){
        do {
            try delegate.stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
    }
    
    
}
