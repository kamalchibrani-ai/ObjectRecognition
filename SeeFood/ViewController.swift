//
//  ViewController.swift
//  SeeFood
//
//  Created by kamal chibrani on 29/10/18.
//  Copyright © 2018 kamal chibrani. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController  , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    
    
    @IBOutlet weak var cameraImageViewer: UIImageView!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImagePicker = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            cameraImageViewer.image = userImagePicker
            guard let ciImage = CIImage(image: userImagePicker) else {
                fatalError("error while coverting UIImage into CIImage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image : CIImage)  {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("error while loding coreML model")
        }
        
       let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
             guard let results = request.results as? [VNClassificationObservation] else {fatalError("error while making coreml request")}
        if let firstresults = results.first {
            if firstresults.identifier.contains("hotdog"){
               self.navigationItem.title = "its a hotdog"
            }else{
                self.navigationItem.title = results.first?.identifier
            }
        }
       })
        let handler = VNImageRequestHandler(ciImage: image)
    
        do{
            try handler.perform([request])
        }catch{
            print("error while handling the request \(error)")
        }
    }
    
    @IBAction func Camera(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

