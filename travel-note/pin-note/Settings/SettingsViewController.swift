//
//  SettingsView.swift
//  travel-note
//
//  Created by Алексей Савельев on 10.11.2020.
//

import UIKit
import FirebaseAuth


// MARK: Контроллер
class SettingsViewController: UIViewController {
    
    
    private var tableView: UITableView!
    
    private var theme = ThemeManager.currentTheme()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.backgroundColor = theme.tableCellColor
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SettingsTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: "SettingsSectionHeader")
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        tableView.largeContentTitle = "Настройки"
        tableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        configureTableView()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = theme.barStyle
        navigationController?.navigationBar.barTintColor = theme.firstColor
        navigationController?.navigationBar.tintColor = theme.barButtons;
        navigationItem.title = "Настройки"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(dismissSelf))
    }
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

final class SettingsTableViewSectionHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)
    
    private let headerLabel = UILabel()
    
    private let theme = ThemeManager.currentTheme()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.textColor = theme.secondTextColor
        
        contentView.backgroundColor = theme.secondColor
    }
    
    func setHeaderTitle(_ text: String?) {
        self.headerLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Расширение
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return MainSection.allCases.count
        case 2: return DataControlSection.allCases.count
        case 3: return InfoSection.allCases.count
        default:
            return 0
        }
    }
    
    // CЕТАП ЗАГОЛОВКА СЕКЦИИ
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingsSectionHeader") as? SettingsTableViewSectionHeader else {return UIView()}
        headerView.setHeaderTitle(SettingsSection(rawValue: section)?.description)
        
        return headerView
    }
    
    // ВЫСОТА ЗАГОЛОВКА СЕКЦИИ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 35
    }
    
    // ЗАПОЛНЕНИЕ ЯЧЕЕК
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell else {return UITableViewCell()}
        
        //let theme = ThemeManager.currentTheme()
        cell.backgroundColor = self.theme.tableCellColor
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {return UITableViewCell()}
        
        switch section {
        case .Auth:
            let cellText: String = {
                print(FirebaseAuth.Auth.auth().currentUser == nil)
                if FirebaseAuth.Auth.auth().currentUser == nil{
                    return AuthSection.logIn.description
                } else {
                    return AuthSection.logOut.description
                }
            }()
            cell.textLabel?.text = cellText
        case .Main:
            let cellText = MainSection(rawValue: indexPath.row)
            cell.textLabel?.text = cellText?.description
        case .DataControl:
            let cellText = DataControlSection(rawValue: indexPath.row)
            cell.textLabel?.text = cellText?.description
        case .Info:
            let cellText = InfoSection(rawValue: indexPath.row)
            cell.textLabel?.text = cellText?.description
        }
        
        
        return cell
    }
    
    // ОБРАБАТЫВАЕМ ВЫБОР ЯЧЕЙКИ
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // плавно убираем анимацию выделения ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        
        // получаем ячейку
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        // получаем секцию
        guard let section = SettingsSection(rawValue: indexPath.section) else {return}
        
        
        switch section {
        case .Auth:
            print("tapped in auth section")
            let cellText = cell.textLabel?.text
            //Определяем авторизованны мы или нет по заголовку ячейки
            if cellText == AuthSection.logIn.description {
                //dismiss(animated: true, completion: nil)
                let authentificationViewModel = AuthentificationViewModel()
                let authentificationView = AuthenticationPhoneViewController(viewModel: authentificationViewModel)
                if #available(iOS 13, *) {
                    authentificationView.modalTransitionStyle = .coverVertical
                    authentificationView.modalPresentationStyle = .automatic
                    self.present(authentificationView, animated: true)
                } else {
                    navigationController?.pushViewController(authentificationView, animated: true)
                }
                
            } else if cellText == AuthSection.logOut.description {
                do{
                    try FirebaseAuth.Auth.auth().signOut()
                }
                catch{
                    print("Error sign out") //STRINGS:
                }
                print("Signed out")
                cell.textLabel?.text = AuthSection.logIn.description
            }
        case .Main:
            print("tapped in main section")
            let cellText = cell.textLabel?.text
            if cellText == MainSection.firstScreen.description {
                let vc = FirstScreenViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else if cellText == MainSection.theme.description {
                let vc = ThemeViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
        case .DataControl:
            print("tapped in data control section")
        case .Info:
            print("tapped in info section")
            let cellText = cell.textLabel?.text
            if cellText == InfoSection.about.description {
                let vc = AboutViewController()
                navigationController?.pushViewController(vc, animated: true)
            } else if cellText == InfoSection.feedBack.description {
                print("nothing")
            }
        }
        
    }
    
    
}
    
