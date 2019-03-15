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

class AddVocabularyViewController: UIViewController, TableDisplayCapable {
    private let bag = DisposeBag()
    private var sections = [TitleValueTableSection]()
    
    @IBOutlet weak var myTableView: UITableView!
    
    var viewModel: AddVocabularyViewModelType!
    var tableView: UITableView { get { return self.myTableView } }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.addVocabulary
        self.setupTable()
        
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
