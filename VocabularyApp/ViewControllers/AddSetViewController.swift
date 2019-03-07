//
//  AddSetViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AddSetViewController: UIViewController, TableDisplayCapable, AlertDisplayable {
    private let bag = DisposeBag()
    private var sections = [TitleValueTableSection]()
    
    var tableView: UITableView { get { return self.myTableView } }
    var viewModel: AddSetViewModelType!
    var delegate: AddSetViewControllerDelegate?
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.addSet
        self.setupTable()
        
        self.saveButton.rx.tap
            .bind(to: self.viewModel.inputs.saveButtonTaps)
            .disposed(by: self.bag)
        self.cancelButton.rx.tap
            .subscribe(onNext: { self.dismiss(animated: true, completion: nil) })
            .disposed(by: self.bag)
        self.viewModel.outputs.sections.subscribe(onNext: { sections in
            self.sections.removeAll()
            self.sections.append(contentsOf: sections)
            self.tableView.reloadData()
        }).disposed(by: self.bag)
        self.viewModel.outputs.saveButtonEnabled
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: self.bag)
        self.viewModel.outputs.editName
            .subscribe(onNext: { name in
                self.showMessageAlertWithTextField(title: L10n.Action.AddSet.name, message: L10n.Alert.AddSet.message, actionTitle: L10n.Action.ok, placeholder: L10n.Alert.AddSet.TextField.placeholder, text: name, confirmAction: { newName in
                    self.viewModel.inputs.setName.onNext(newName)
                })
            }).disposed(by: self.bag)
        self.viewModel.outputs.setSaved
            .subscribe(onNext: { set in
                self.delegate?.didSaveSet(set: set)
            }).disposed(by: self.bag)
        self.viewModel.outputs.error
            .subscribe(onNext: { error in
                self.showMessageAlert(title: error.title, message: error.message)
            }).disposed(by: self.bag)
        
        self.viewModel.inputs.setName.onNext("")
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.sections.count > section else {
            return 0
        }
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TitleValueTableViewCell
        cell.titleValueContent.title.text = item.title
        cell.titleValueContent.value.text = item.value
        cell.accessoryView = cell.customAccessoryView(image: UIImage(named: "Edit"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard self.sections.count > section else {
            return nil
        }
        let section = self.sections[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.inputs.selectItem.onNext(indexPath)
    }
}

protocol AddSetViewControllerDelegate {
    func didSaveSet(set: SetLocalDataModel)
}
