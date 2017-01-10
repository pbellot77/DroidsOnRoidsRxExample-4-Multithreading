//
//  RepositoriesViewController.swift
//  DroidsOnRoidsExample#4-multithreading
//
//  Created by Patrick Bellot on 1/9/17.
//  Copyright © 2017 Bell OS, LLC. All rights reserved.
//

import UIKit
import RxAlamofire
import RxCocoa
import RxSwift
import ObjectMapper

class RepositoriesViewController: UIViewController {
	
	// MARK: Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
	
	// MARK: ivars
	private let disposeBag = DisposeBag()
	var repositoryNetworkModel: RepositoryNetworkModel!
	
	var rx_searchBarText: Observable<String> {
		return searchBar.rx.text
			.filter { $0 != nil }
			.map { $0! }
			.filter { $0.characters.count > 0 }
			.debounce(0.5, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setupRx()
	}
	
	func setupRx() {
		repositoryNetworkModel = RepositoryNetworkModel(withNameObservable: rx_searchBarText)
		
		repositoryNetworkModel
			.rx_repositories
			.drive(tableView.rx.items) { (tv, i, repository) in
				let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: i, section: 0))
				cell.textLabel?.text = repository.name
				
				return cell
		}
		.addDisposableTo(disposeBag)
		
		repositoryNetworkModel
			.rx_repositories
			.drive(onNext: { repositories in
				if repositories.count == 0 {
					let alert = UIAlertController(title: ":(", message: "No repositories for this user.", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
					if self.navigationController?.visibleViewController is UIAlertController != true {
						self.present(alert, animated: true, completion: nil)
					}
				}
		})
		.addDisposableTo(disposeBag)
	}
	
	func setupUI() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped(_:)))
		tableView.addGestureRecognizer(tap)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow(_:)),
			name: NSNotification.Name.UIKeyboardWillShow,
			object: nil)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide(_:)),
			name: NSNotification.Name.UIKeyboardWillHide,
			object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func keyboardWillShow(_ notification: Notification) {
		guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		tableViewBottomConstraint.constant = keyboardFrame.height
		UIView.animate(withDuration: 0.3, animations: {
			self.view.updateConstraints()
		})
	}
	
	func keyboardWillHide(_ notification: Notification) {
		tableViewBottomConstraint.constant = 0.0
		UIView.animate(withDuration: 0.3, animations: {
			self.view.updateConstraints()
		})
	}
	
	func tableTapped(_ recognizer: UITapGestureRecognizer) {
		let location = recognizer.location(in: tableView)
		let path = tableView.indexPathForRow(at: location)
		if searchBar.isFirstResponder {
			searchBar.resignFirstResponder()
		} else if let path = path {
			tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
		}
	}
} // end of class
