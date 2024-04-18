//
//  ViewController.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import UIKit

import ReactorKit
import RxSwift

class MainViewController: UIViewController, StoryboardView {
    
    typealias Reactor = MainViewReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    enum Section: Int {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ArticleModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ArticleModel>
    private typealias CellProvider = DataSource.CellProvider
    
    private lazy var dataSource = makeDataSource()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .red
        
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.reactor = MainViewReactor()
        self.reactor?.action.onNext(.initialize)
        
        collectionView.refreshControl = refresh
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.reloadData()
    }
    
    func bind(reactor: MainViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: MainViewReactor) {
        
        // refresh
        refresh.rx.controlEvent(.valueChanged)
            .map({ _ in .initialize })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: MainViewReactor) {
        
        // load data
        reactor.pulse(\.$apiModel)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { onwer, model in
                onwer.applySnapShot(apiModel: model)
            })
            .disposed(by: disposeBag)
        
        // loading
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: refresh.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // error
        reactor.pulse(\.$error)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { onwer, error in
                onwer.applySnapShot(apiModel: nil)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Collection View
extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private func makeDataSource() -> DataSource {
        
        let dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, car in
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionCell.identifier, for: indexPath) as? MainCollectionCell {
                
                return cell
            }
            
            return UICollectionViewCell()
        }
        
        return dataSource
    }
    
    private func applySnapShot(apiModel: ApiModel?) {
        
        var articles: [ArticleModel] = []
        if let arts = apiModel?.articles {
            // 데이터가 있는 경우 저장
            CoreDataManager.shared.setData(articles: arts)
            articles = arts
        } else {
            // 데이터가 없는 경우 로컬데이터 사용
            articles = CoreDataManager.shared.getData()
        }
        
        var snapShot = Snapshot()
        snapShot.appendSections([.main])
        snapShot.appendItems(articles, toSection: .main)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dataSource.apply(snapShot)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.orientation.isLandscape {
            return CGSize(width: (collectionView.bounds.width - 20) / 3, height: 250)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 350)
        }
    }
}
