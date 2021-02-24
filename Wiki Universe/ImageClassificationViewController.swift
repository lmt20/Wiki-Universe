//
//  ViewController.swift
//  Wiki Universe
//
//  Created by Trường Lê Mạnh on 23/02/2021.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ImageClassificationViewController: UIViewController {
    //MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var wikiDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Photo actions
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { (action) in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
        
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MobileNet().model)
            let request = VNCoreMLRequest(model: model) { (request, error) in
                self.processClassifications(for: request, error: error)
            }
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Fail to load vision ML model: \(error)")
        }
    }()
    
    
    /// Update UI with the results of classification
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image: \(String(describing: error))")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                print("Nothing recognized")
            } else {
                //                let topClassifications = classifications.prefix(2)
                //                let descriptions = topClassifications.map { classification in
                //                    return String(format: "(%.2f) %@", classification.confidence, classification.identifier)
                //                }
                //                print(descriptions.joined(separator: "\n"))
                let classification = classifications.first
                guard let categories = classification?.identifier else {
                    print("Cannot identify this object")
                    return
                }
                self.processRequest(with: categories)
                
            }
            
        }
    }
    
    /// - Tag: PerformRequests
    func updateClassification(image: UIImage) {
        guard let ciimage = CIImage(image: image) else {
            print("Cannot convert to ciimage")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciimage)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Fail to perform classification.\n \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Hanlde request to WIKI
    
    func processRequest(with categories: String) {
        
        let index = categories.firstIndex(of: ",") ?? categories.endIndex
        let firstCategory = String(categories[..<index])
        
        
        let parameters: [String: String] = ["format": "json", "action": "query", "prop": "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : firstCategory, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
        
        let endpoint = "https://en.wikipedia.org/w/api.php"
        
        AF.request(endpoint, method: .get, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let resultJSON = JSON(value)
                if let pageId = resultJSON["query"]["pageids"][0].string {
                    let info = resultJSON["query"]["pages"][pageId]
                    let title = info["title"].string
                    let description = info["extract"].string
                    let imageSource = info["thumbnail"]["source"].string
                    self.displayInfoWiki(title, description, imageSource)
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func displayInfoWiki(_ title: String?, _ description: String?, _ imageSource: String?) {
        navigationItem.title = title
        if let text = description {
            processTranslate(text: text)
            
        }
        
        if imageSource != nil {
            imageView.sd_setImage(with: URL(string: imageSource!), completed: nil)
        }
    }
    
    func processTranslate(text: String){
        var transParams: [String: String] = ["client": "gtx", "sl": "auto", "tl": "vi", "dt": "t"]
        transParams["q"] = text
        var result = ""
        
        let url = "https://translate.googleapis.com/translate_a/single"
        DispatchQueue.main.async {
            AF.request(url, method: .get, parameters: transParams).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    
                    let resultJSON = JSON(value)
                    if let listSentences = resultJSON[0].array {
                        for sentence in listSentences {
                            if let transText = sentence[0].string {
                                result += transText
                            }
                        }
                    }
                    self.wikiDescription.text = result
                    
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
}

extension ImageClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - Handle image picker selection
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        updateClassification(image: image)
    }
    
}

