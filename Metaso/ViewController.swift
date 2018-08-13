import UIKit

// MARK: - Private types

private enum Constant {
    
    static var reuseIdentifier: String {
        return "UITableViewCell_ReuseIdentifier"
    }
    
    static var rowHeight: CGFloat {
        return 80
    }
    
    static var numberOfRowsInSection: Int {
        return 50
    }
    
}

class ViewController: UIViewController {
    
    // MARK: - Internal types
    
    final class Section {
        
        // MARK: - Internal types
        
        struct Row {
            
            let backgroundColor: UIColor
            
            
            static var `default`: Row {
                return Row(backgroundColor: .white)
            }
            
            static var random: Row {
                return Row(backgroundColor: .random)
            }
            
        }
        
        final class SectionBuilder {
            
            private let numberOfRows: Int
            
            init(numberOfRows: Int = Constant.numberOfRowsInSection) {
                self.numberOfRows = numberOfRows
            }
            
            func build() -> Section {
                let rows: [Section.Row] = (0..<numberOfRows).map { _ in return .default }
                return Section(rows: rows)
            }
            
        }
        
        // MARK: - Static properties
        
        static var `default`: Section {
            return SectionBuilder().build()
        }
        
        // MARK: - Internal properties
        
        private var rows: [Row]
        
        // MARK: - Init
        
        init(rows: [Row]) {
            self.rows = rows
        }
        
        // MARK: Internal methods
        
        var count: Int {
            return rows.count
        }
        
        func getRow(at index: Int) -> Row {
            guard index < count else {
                // TODO: Add logs
                assertionFailure("Try to retrieve non-existent row \(index)")
                return .default
            }
            
            return rows[index]
        }
        
        func setRow(row: Row, at index: Int) {
            guard index < count else {
                // TODO: Add logs
                assertionFailure("Try to retrieve non-existent row \(index)")
                return
            }
            
            rows[index] = row
        }
        
    }
    
    // MARK: - Internal properties
    
    var sections: [Section] = [.default] {
        didSet {
            guard isViewLoaded else {
                // TODO: add logs
                return
            }
            
            tableView.reloadData()
        }
    }
    
    // MARK: - Private properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(Cell.self, forCellReuseIdentifier: Constant.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    // MARK: - Private methods
    
    private func configureTableView() {
        view.addSubview(tableView)
        view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
    }
    
}

// MARK: - UITableViewDataSource implementation

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sections.count else {
            assertionFailure("Try to retrieve non-existent section")
            return 0
        }
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reuseIdentifier) as? Cell else {
            // TODO: add logs
            assertionFailure("Table view cell expected to be dequeue")
            return UITableViewCell(frame: .zero)
        }
        
        let row = getRow(for: indexPath)
        cell.configure(with: row)
        
        return cell
    }
    
    // MARK: - Private methods
    
    private func getRow(for indexPath: IndexPath) -> Section.Row {
        guard indexPath.section < sections.count else {
            // TODO: Add logs
            assertionFailure("Try to retrieve non-existent section: \(indexPath.section)")
            return .default
        }
        
        let section = sections[indexPath.section]
        
        return section.getRow(at: indexPath.row)
    }
    
    private func setRow(_ row: Section.Row, for indexPath: IndexPath) {
        guard indexPath.section < sections.count else {
            // TODO: Add logs
            assertionFailure("Try to update non-existent section: \(indexPath.section)")
            return
        }
        
        let section = sections[indexPath.section]
        
        section.setRow(row: row, at: indexPath.row)
    }
    
}

// MARK: - UITableViewDelegate implementation

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setRow(.random, for: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

private extension UIColor {
    
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: .random)
    }
    
}

private extension CGFloat {
    
    static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
}

private extension Float {
    
    static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
}

private final class Cell: UITableViewCell {
    
    // MARK: - Internal type
    
    typealias Row = ViewController.Section.Row
    
    // MARK: - Private properties
    
    private lazy var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        return container
    }()
    
    private var row: Row = .default
    
    // MARK: - Life cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with row: Row) {
        self.row = row
        container.backgroundColor = row.backgroundColor
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        contentView.addSubview(container)
        contentView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: Constant.rowHeight).isActive = true
        
        selectionStyle = .none
        
        configure(with: row)
    }
    
}
