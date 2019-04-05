//
//  SetViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LearnSetViewController: UIViewController, TableDisplayCapable, AlertDisplayable, SetManageable, SegueHandlerType {
    private let bag = DisposeBag()
    private var sections = [TitleValueTableSection]()
    
    enum SegueIdentifier: String {
        case addVocabulary
    }

    var set: SetLocalDataModel?
    
    var viewModel: LearnSetViewModelType!
    var tableView: UITableView { get { return self.myTableView } }
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = L10n.Action.learn
        self.tabBarController?.title = self.set?.name
        self.setupTable()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        addButton.rx.tap.subscribe(onNext: { self.performSegueWithIdentifier(segueIdentifier: .addVocabulary, sender: self) }).disposed(by: self.bag)
        
        self.infoLabel.text = L10n.Action.AddVocabulary.hint
        
        self.viewModel.outputs.emptyViewVisible
            .map { !$0 }
            .bind(to: self.emptyView.rx.isHidden)
            .disposed(by: self.bag)
        self.viewModel.outputs.tableViewVisible
            .map { !$0 }
            .bind(to: self.tableView.rx.isHidden)
            .disposed(by: self.bag)
        self.viewModel.outputs.sections
            .subscribe(onNext: { sections in
                self.sections.removeAll()
                self.sections.append(contentsOf: sections)
                self.tableView.reloadData()
            }).disposed(by: self.bag)
        
        self.viewModel.inputs.set.onNext(self.set!)
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = self.segueIdentifierForSegue(segue: segue) else {
            return
        }
        switch identifier {
        case .addVocabulary:
            let destination = segue.destination as! AddVocabularyViewController
            destination.set = self.set
            destination.delegate = self
            break
        }
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
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TitleValueTableViewCell
        cell.titleValueContent.title.text = item.title
        cell.titleValueContent.value.text = item.value
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LearnSetViewController: AddVocabularyViewControllerDelegate {
    func didAddVocabulary() {
        self.viewModel.inputs.didAddVocabulary.onNext(())
    }
}
