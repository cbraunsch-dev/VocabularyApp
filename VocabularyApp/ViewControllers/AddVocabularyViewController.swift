//
//  AddVocabularyViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 14.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddVocabularyViewController: UIViewController {
    private let bag = DisposeBag()
    @IBOutlet weak var importButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.importButton.rx.tap.subscribe(onNext: { self.launchPickerToImportCSV() }).disposed(by: self.bag)
    }
    
    private func launchPickerToImportCSV() {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
}

extension AddVocabularyViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
                let importedCsvText = try String(contentsOfFile: urls.first!.path, encoding: .utf8)
                print("Imported CSV: \(importedCsvText)")
            } catch {
                print("An error occurred picking the CSV file: \(error.localizedDescription)")
            }
            print("Picked CSV")
        }
    }
}
