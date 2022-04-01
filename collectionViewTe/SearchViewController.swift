//
//  SearchViewController.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/31.
//

import UIKit

class SearchViewController: UIViewController ,UITextFieldDelegate{

    @IBOutlet weak var searchTextField: UITextField!
    var recentSearchArr : [String] = []
    @IBOutlet weak var recentSearchTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title=""
        if let userDefaultArr = UserDefaults.standard.array(forKey: "recentSearch") as? [String] {
            self.recentSearchArr = userDefaultArr
        }
        
        self.recentSearchTableView.delegate = self
        self.recentSearchTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.searchTextField.becomeFirstResponder()
        
    }

    @IBAction func tapSearchButton(_ sender: UIBarButtonItem) {
        
        guard let serarchStr = searchTextField.text else { return }
        
        if self.recentSearchArr.count >= 5 {
            self.recentSearchArr.remove(at: 0)
            self.recentSearchArr.append(serarchStr)
        } else {
            self.recentSearchArr.append(serarchStr)
        }
        
        self.searchTextField.resignFirstResponder()
        
        self.recentSearchTableView.reloadData()
    
        print(self.recentSearchArr)
        UserDefaults.standard.set(self.recentSearchArr, forKey: "recentSearch")
    }
    
    
    @objc func deleteBtnAction(_ sender: UIButton){
        let point = sender.convert(CGPoint.zero, to: self.recentSearchTableView)
        guard let indexPath = self.recentSearchTableView.indexPathForRow(at: point) else { return }
        self.recentSearchArr.reverse()
        self.recentSearchArr.remove(at: indexPath.row - 1)
        self.recentSearchArr.reverse()
        UserDefaults.standard.set(self.recentSearchArr, forKey: "recentSearch")
        self.recentSearchTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    
    
    
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchArr.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            
            guard let cell = self.recentSearchTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell") as? RecentSearchTableViewCell else {return UITableViewCell()}
            
            cell.recentSearchLabel.text = "최근검색어"
            cell.recentSearchLabel.textColor = .black
            cell.deleteBtn.setTitle("검색기록 전체삭제", for: .normal)
            cell.deleteBtn.addTarget(self, action: #selector(deleteBtnAction(_:)), for: .touchUpInside)
            
            
            return cell
            
        } else{
            guard let cell = self.recentSearchTableView.dequeueReusableCell(withIdentifier: "RecentSearchTableViewCell") as? RecentSearchTableViewCell else {return UITableViewCell()}
            
            cell.recentSearchLabel.text = recentSearchArr.reversed()[indexPath.row - 1]
            
            cell.recentSearchLabel.textColor = .lightGray
            cell.deleteBtn.setTitle("X", for: .normal)
            cell.deleteBtn.addTarget(self, action: #selector(deleteBtnAction(_:)), for: .touchUpInside)
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}
