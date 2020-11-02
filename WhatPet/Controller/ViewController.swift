//
//  ViewController.swift
//  WhatPet
//
//  Created by Eliu Efraín Díaz Bravo on 01/11/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    lazy var petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupImagePicker()
    }
    
    func setupNavigationBar() {
        title = "What pet?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraTapped))
    }
    
    func setupViews() {
        view.addSubview(petImageView)
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            petImageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            petImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            petImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            petImageView.bottomAnchor.constraint(equalTo: safeArea.centerYAnchor),
        ])
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
    
    @objc private func cameraTapped() {
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            
            guard let ciPickedImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert image to ciimage")
            }
            
            petImageView.image = userPickedImage
            detect(ciimage: ciPickedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func detect(ciimage: CIImage) {
        guard let model = try? VNCoreMLModel(for: PetImageClassifier(configuration: .init()).model) else {
            fatalError("Could not setup CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstItem = classification.first {
                self.title = firstItem.identifier
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciimage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
}
