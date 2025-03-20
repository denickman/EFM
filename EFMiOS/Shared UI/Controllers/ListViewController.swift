//
//  ListViewController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 19.03.2025.
//

import UIKit
import EFM

public final class ListViewController: UITableViewController {
    
    // MARK: - Properties
    
    public var onRefresh: (() -> Void)?
    private(set) public var errorView = ErrorView()
    
    // CellController should be Hashable so diffable data source can compare any change to the model,
    // it`s keep track the state for us
    // DifDaSo will try to imply by the estimated row height how many cells it can load ahead of time and load only these cells
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, indexPath, controller in
            let ds = controller.dataSource
            return ds.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        configureErrorView()
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        /// Ячейки таблицы (CellController) могут использовать шрифты, зависящие от Dynamic Type (например, UIFont.preferredFont(forTextStyle:)). Когда пользователь меняет размер текста, высота и содержимое ячеек должны обновиться, чтобы соответствовать новому шрифту.
        /// reloadData() заставляет таблицу перерисовать все видимые ячейки с учетом нового preferredContentSizeCategory.
        ///
        /// reloadData(): Полностью перезагружает таблицу, вызывая dataSource заново для всех ячеек. Это гарантирует, что все ячейки обновятся с учетом нового размера текста.
        ///
        /// apply: Выполняет diffing и обновляет только измененные данные. Но изменение preferredContentSizeCategory не меняет модель данных (CellController), а влияет на рендеринг ячеек (шрифт, высота). Diffing тут бесполезен, так как данные те же, а UI нужно обновить полностью.
        
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    // MARK: - Methods
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        
        if #available(iOS 15.0, *) {
            /// Используется applySnapshotUsingReloadData(snapshot).
            /// Это гарантирует полную перезагрузку таблицы, что может быть важно для сброса состояния или если diffing нежелателен (например, из-за особенностей CellController или логики приложения).
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            /// Используется apply(snapshot).
            /// Это компромисс, так как applySnapshotUsingReloadData недоступен. В этих версиях apply может либо выполнить diffing, либо перезагрузить таблицу целиком (зависит от UIKit).
            ///
            /// Метод apply(_:) в версиях iOS 13 и 14 не всегда строго выполнял diffing (сравнение старого и нового снимка). В некоторых случаях он мог перезагружать таблицу целиком (как reloadData()), особенно если изменения были сложными.
            /// Это поведение было непредсказуемым и зависело от внутренней реализации UIKit.
            dataSource.apply(snapshot)
        }
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate ([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

// MARK: - DataSource

extension ListViewController {
    /// Когда вы вызываете `tableView.reloadData()`, это приводит к повторной загрузке данных в таблице, что включает перерасчет всех видимых ячеек и обновление их на экране. Однако, перед тем как обновить эти ячейки, система вызывает метод делегата `tableView(_:didEndDisplaying:forRowAt:)` для каждой ячейки, которая больше не отображается на экране.
    
    /// When updating the table model and reloading the table, UIKit calls `didEndDisplayingCell` for each removed cell that was previously visible. Since we're canceling requests in this method, we could be sending messages to the new models or potentially crashing in case the new table model has fewer items than the previous one!
    
    /// This is not a big problem at the moment since items cannot be removed from the feed. But we cannot assume the backend will keep this behavior going further.
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = cellController(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
}

// MARK: - PrefetchingDataSource

extension ListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.prefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.prefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
}

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}
