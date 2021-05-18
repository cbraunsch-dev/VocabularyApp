//
//  TrainSetViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 08.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TrainSetViewController: UIViewController, TableDisplayCapable, SetManageable, SegueHandlerType {
    private let bag = DisposeBag()
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    
    private var sections = [GenericTableSection]()
    
    var set: SetLocalDataModel?
    var viewModel: TrainSetViewModelType!
    var tableView: UITableView {
        get {
            return self.myTableView
        }
    }
    
    enum SegueIdentifier: String {
        case practiceSet
        case play
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Action.train
        self.setupTable()
        
        self.cancelButton.rx.tap.subscribe(onNext: { self.dismiss(animated: true, completion: nil) }).disposed(by: self.bag)
        
        self.viewModel.outputs.sections
            .subscribe(onNext: { sections in
                self.sections.removeAll()
                self.sections.append(contentsOf: sections)
                self.tableView.reloadData()
            }).disposed(by: self.bag)
        self.viewModel.outputs.practice
            .subscribe(onNext: {
                self.performSegueWithIdentifier(segueIdentifier: .practiceSet, sender: self)
            }).disposed(by: self.bag)
        self.viewModel.outputs.play
            .subscribe(onNext: {
                self.performSegueWithIdentifier(segueIdentifier: .play, sender: self)
            }).disposed(by: self.bag)
        
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = self.segueIdentifierForSegue(segue: segue) else {
            return
        }
        switch identifier {
        case .practiceSet:
            var setManageableVc = segue.destination as! SetManageable
            setManageableVc.set = self.set
            break
        case .play:
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
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = item.title
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.inputs.selectItem.onNext(indexPath)
    }
}
