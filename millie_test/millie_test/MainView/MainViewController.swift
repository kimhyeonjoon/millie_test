//
//  ViewController.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import UIKit

import ReactorKit
import RxSwift

var isForceUpdate: Bool = false

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
        refresh.tintColor = .lightGray
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.reactor = MainViewReactor()
        self.reactor?.action.onNext(.initialize)
        
        collectionView.refreshControl = refresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionViewForceUpdate()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionViewForceUpdate()
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
        
        // cell select
        collectionView.rx.itemSelected
            .map { .itemSelected($0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    func bindState(reactor: MainViewReactor) {
        
        // load data
        reactor.pulse(\.$apiModel)
            .skip(1)
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
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { onwer, error in
                onwer.applySnapShot(apiModel: nil)
            })
            .disposed(by: disposeBag)
        
        // item select
        reactor.state.map { $0.selectedItem }
            .observe(on: MainScheduler.instance)
            .filter({ $0 != nil })
            .subscribe(with: self, onNext: { onwer, model in
                onwer.moveWebViewController(model: model)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ViewController Method
extension MainViewController {
    
    func collectionViewForceUpdate() {
        isForceUpdate = true
        applySnapShot(apiModel: nil)
    }
    
    func moveWebViewController(model: ArticleModel?) {
        
        guard let model else {
            return
        }
        
        print("select = \(model)")
        
        if let webVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            webVC.model = model
            navigationController?.pushViewController(webVC, animated: true)
            collectionViewForceUpdate()
        }
    }
}

// MARK: - Collection View
extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private func makeDataSource() -> DataSource {
        
        let dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, article in
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionCell.identifier, for: indexPath) as? MainCollectionCell {
                
                cell.articleModel = article
                cell.titleLabel.textColor = self?.reactor?.selectedIndex.contains(indexPath.item) ?? false ? .red : .black
                
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
            CoreDataManager.shared.saveData(articles: arts)
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
            self.dataSource.apply(snapShot) {
                isForceUpdate = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.orientation.isLandscape {
            // 40: cell 간 간격(10x2), 32:양 쪽 여백(16x2)
            return CGSize(width: (collectionView.bounds.width - 40 - 32) / 3, height: 250)
        } else {
            return CGSize(width: collectionView.bounds.width - 32, height: 350)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionCell {
            cell.cancelImage()
        }
    }
}
