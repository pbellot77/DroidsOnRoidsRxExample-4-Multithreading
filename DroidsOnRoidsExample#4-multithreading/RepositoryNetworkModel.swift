//
//  RepositoryNetworkModel.swift
//  DroidsOnRoidsExample#4-multithreading
//
//  Created by Patrick Bellot on 1/9/17.
//  Copyright © 2017 Bell OS, LLC. All rights reserved.
//

import ObjectMapper
import RxAlamofire
import RxCocoa
import RxSwift

struct RepositoryNetworkModel {
	
	lazy var rx_repositories: Driver<[Repository]> = self.fetchRepositories()
	fileprivate var repositoryName: Observable<String>
	
	init(withNameObservable nameObservable: Observable<String>) {
		self.repositoryName = nameObservable
	}
	
	fileprivate func fetchRepositories() -> Driver<[Repository]> {
		return repositoryName
			.subscribeOn(MainScheduler.instance)
			.do(onNext: { response in
				UIApplication.shared.isNetworkActivityIndicatorVisible = true
			})
			.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.flatMapLatest { text in
				return RxAlamofire
					.requestJSON(.get, "https://api.github.com/users/\(text)/repos")
					.debug()
					.catchError { error in
						return Observable.never()
				}
		}
		.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.map { (response, json) -> [Repository] in
				if let repos = Mapper<Repository>().mapArray(JSONObject: json) {
					return repos
				} else {
					return []
				}
		}
		.observeOn(MainScheduler.instance)
			.do(onNext: { response in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
		})
			.asDriver(onErrorJustReturn: [])
	}
}
