//
//  SetsViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 10.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SetsViewController: UIViewController, SegueHandlerType, TableDisplayCapable {
    private let bag = DisposeBag()
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var myTableView: UITableView!
    
    private var sections = [GenericTableSection]()
    
    var tableView: UITableView {
        get {
            return self.myTableView
        }
    }
    
    var viewModel: SetsViewModelType!
    var dismissableViewController: UIViewController?
    var setToShow: SetLocalDataModel?
    
    enum SegueIdentifier: String {
        case addSet
        case showSet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.sets
        self.infoIcon.image = self.infoIcon.image?.withRenderingMode(.alwaysTemplate)
        self.infoIcon.tintColor = UIColor.darkGray
        self.infoLabel.text = L10n.Action.AddSet.hint
        
        self.setupTable()
        
        self.viewModel.outputs.sections
            .subscribe(onNext: { sections in
                self.sections.removeAll()
                self.sections.append(contentsOf: sections)
                self.tableView.reloadData()
            }).disposed(by: self.bag)
        self.viewModel.outputs.emptyViewVisible
            .map { !$0 }
            .bind(to: self.emptyView.rx.isHidden)
            .disposed(by: self.bag)
        self.viewModel.outputs.tableViewVisible
            .map { !$0 }
            .bind(to: self.tableView.rx.isHidden)
            .disposed(by: self.bag)
        
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = self.segueIdentifierForSegue(segue: segue) else {
            return
        }
        switch identifier {
        case .addSet:
            let navigationController = segue.destination as! UINavigationController
            let targetVC = navigationController.topViewController as! AddSetViewController
            targetVC.delegate = self
            self.dismissableViewController = targetVC
            break
        case .showSet:
            let tabController = segue.destination as! SetTabBarController
            tabController.set = self.setToShow
            break
        }
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
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = item.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SetsViewController: AddSetViewControllerDelegate {
    func didSaveSet(set: SetLocalDataModel) {
        self.dismissableViewController?.dismiss(animated: true, completion: {
            self.viewModel.inputs.didAddSet.onNext(())
            
            //TODO: Instead of opening it directly here, pass the input along to the view model and the view model can then decide whether to open the set or not
            //Open the set we just created
            self.setToShow = set
            self.performSegueWithIdentifier(segueIdentifier: .showSet, sender: self)
        })
    }
}
