//
//  CellController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 20.03.2025.
//

import UIKit

/// #Option 0
//public protocol CellController {
//    func view(in tableView: UITableView) -> UITableViewCell
//    func preload()
//    func cancelLoad()
//}


// instead of using custom protocol CellController we use typealias because we can get all of the required logic from these table view data source / delegate methods

/// #Option 1
//public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching


/// #Option 2 we can use tuple as well where delegate, prefetching - is not mandatory
//public typealias CellController = (dataSource: UITableViewDataSource, delegate: UITableViewDelegate?, prefetching: UITableViewDataSourcePrefetching?)

/// #Option 3
// prefer a struct better because we can use different inits here
public struct CellController {
    
    // withoud id we cannot confirm to equatable or hasahble, so we need id
    /// AnyHashable — это тип-обертка, позволяющий хранить любые Hashable значения внутри себя. [42, "Hello", UUID()]
    /// Основное предназначение AnyHashable — работа с разными типами, соответствующими Hashable, в одной коллекции.
    
    let id: AnyHashable // когда необходимо работать с hashable но без привязки к конкретному типу
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetching: UITableViewDataSourcePrefetching?
    
    //    public init(
    //        id: AnyHashable,
    //        dataSource: UITableViewDataSource,
    //        delegate: UITableViewDelegate?,
    //        prefetching: UITableViewDataSourcePrefetching?
    //    ) {
    //        self.id = id
    //        self.dataSource = dataSource
    //        self.delegate = delegate
    //        self.prefetching = prefetching
    //    }
    
    public init(
        id: AnyHashable,
        _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching
    ) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.prefetching = dataSource
    }
    
    // second convenience init
    //    public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
    //        self.id = id
    //        self.dataSource = dataSource
    //        self.delegate = nil
    //        self.prefetching = nil
    //    }
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.prefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

/// Если бы вы не реализовали Equatable для CellController, то попытка сравнить два объекта этого типа с использованием оператора == привела бы к ошибке компиляции, потому что Swift не знал бы, как сравнить два объекта CellController.

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // equitable protocol
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
