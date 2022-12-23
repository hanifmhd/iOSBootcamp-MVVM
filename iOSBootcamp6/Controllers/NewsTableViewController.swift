//
//  NewsTableViewController.swift
//  iOSBootcamp6
//
//  Created by Muhammad Hanif on 23/12/22.
//

import UIKit
import RxSwift

class NewsTableViewController: UITableViewController {

    private var articleListViewModel: ArticleListViewModel?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        populateNews()
    }
    
    private func populateNews() {
        let resource = Resource<ArticleResponse>(url: URL(string:
                                                            "https://newsapi.org/v2/top-headlines?country=us&apiKey=376a308e08a44a899a883366b58f5512")!)
        URLRequest.load(resource: resource)
            .subscribe(onNext: { articleResponse in
                let articles = articleResponse.articles
                self.articleListViewModel = ArticleListViewModel(articles)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let articleListViewModel = articleListViewModel else {
            return 0
        }
        
        return articleListViewModel.articlesViewModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as?
                ArticleTableViewCell else {
            fatalError("ArticleTableViewCell is not found")
        }
        
        let cellData = self.articleListViewModel?.articleAt(indexPath.row)
        
        cellData?.title
            .asDriver(onErrorJustReturn: "no title found")
            .drive(onNext: {
                titleText in
                cell.titleLabel.text = titleText
            })
            .disposed(by: disposeBag)
        
        cellData?.description
            .asDriver(onErrorJustReturn: "no description found")
            .drive(onNext: {
                descText in
                cell.descriptionLabel.text = descText
            })
            .disposed(by: disposeBag)
        
        return cell
    }
}
