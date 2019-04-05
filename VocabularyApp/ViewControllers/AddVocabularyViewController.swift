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

class AddVocabularyViewController: UIViewController, TableDisplayCapable, SetManageable, AlertDisplayable {
    private let bag = DisposeBag()
    private var sections = [TitleValueTableSection]()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var spinner: ModalSpinnerView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var set: SetLocalDataModel?
    
    var viewModel: AddVocabularyViewModelType!
    var tableView: UITableView { get { return self.myTableView } }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.addVocabulary
        self.setupTable()
        
        self.saveButton.rx.tap
            .bind(to: self.viewModel.inputs.saveButtonTaps)
            .disposed(by: self.bag)
        self.cancelButton.rx.tap
            .subscribe(onNext: { self.dismiss(animated: true, completion: nil) })
            .disposed(by: self.bag)
        self.viewModel.outputs.sections
            .subscribe(onNext: { sections in
                self.sections.removeAll()
                self.sections.append(contentsOf: sections)
                self.tableView.reloadData()
            }).disposed(by: self.bag)
        self.viewModel.outputs.openFileBrowser
            .subscribe(onNext: {
                self.launchPickerToImportCSV()
            }).disposed(by: self.bag)
        self.viewModel.outputs.spinnerAnimating
            .bind(to: self.spinner.animating)
            .disposed(by: self.bag)
        self.viewModel.outputs.saveButtonEnabled
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: self.bag)
        self.viewModel.outputs.setSaved
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: self.bag)
        self.viewModel.outputs.error
            .subscribe(onNext: { error in
                self.showMessageAlert(title: error.title, message: error.message)
            }).disposed(by: self.bag)
        
        self.viewModel.inputs.set.onNext(self.set!)
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    private func launchPickerToImportCSV() {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.sections.count > 0 else {
            return 0
        }
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.row]
        let itemType = item.type as! AddVocabularyItemType
        switch itemType {
        case AddVocabularyItemType.actionItem:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = item.title
            cell.accessoryView = cell.customAccessoryView(image: UIImage(named: "Edit"))
            return cell
        case AddVocabularyItemType.vocabularyPair:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TitleValueTableViewCell
            cell.titleValueContent.title.text = item.title
            cell.titleValueContent.value.text = item.value
            cell.accessoryType = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.inputs.selectItem.onNext(indexPath)
    }
}

extension AddVocabularyViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            self.viewModel.inputs.importFromFile.onNext(urls.first!.path)
        }
    }
}
