//
//  ViewController.swift
//  BalinasoftTest
//
//  Created by admin on 24.09.2023.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let picker = UIImagePickerController()
    private var listModels: [Content] = []
    private var page = 0
    private var id = 0
    
    private var dowloadButton: UIButton! = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Load more", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Balinasoft"
        activityIndicator.startAnimating()
        setupTableView()
        fetchItems()
        
        picker.sourceType = .camera
        picker.delegate = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListTableViewCell.nib(), forCellReuseIdentifier: ListTableViewCell.identifier)
        tableView.tableFooterView = dowloadButton
        dowloadButton.addTarget(self, action: #selector(downloadNextPage), for: .touchUpInside)
    }
    
    private func fetchItems() {
        NetworkManager.shared.getRequest() { result in
            switch result {
            case .success(let models):
                self.listModels = models.content
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func downloadNextPage() {
        page += 1
        let oldCount = listModels.count
        NetworkManager.shared.getRequest(by: page) { result in
            switch result {
            case .success(let models):
                guard self.page < models.totalPages else {
                    self.tableView.tableFooterView?.isHidden = true
                    return }
                self.listModels += models.content
                self.reloadRows(newIndex: self.listModels.count, oldIndex: oldCount)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func reloadRows(newIndex: Int, oldIndex: Int) {
        let section = 0
        let indexPath = (oldIndex..<newIndex).map({IndexPath(row: $0, section: section)})
        tableView.insertRows(at: indexPath, with: .top)
        tableView.reloadRows(at: indexPath, with: .top)
    }
    
    private func alert(id: String) {
        let alert = UIAlertController(title: "successfully", message: "Successfully uploaded with ID: \(id)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController?.present(alert, animated: true)
    }
    
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as! ListTableViewCell
        let cellModel = listModels[indexPath.row]
        cell.setupCell(with: cellModel)
        return cell
    }
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        present(picker, animated: true)
        id = indexPath.row
        print(indexPath.row)
    }
}


extension ListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let contentModel = ContentDTO(id: id, name: "Воробей Александр Сергеевич", image: imageData)
        NetworkManager.shared.postRequest(with: contentModel) { result in
            switch result {
            case .success(let id):
                self.alert(id: id)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
