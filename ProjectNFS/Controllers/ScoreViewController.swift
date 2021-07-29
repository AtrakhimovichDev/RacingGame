//
//  ScoreViewController.swift
//  ProjectNFS
//
//  Created by Andrei Atrakhimovich on 4.05.21.
//

import UIKit

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var scoreTableView: UITableView!
    
    private let userDefaults = UserDefaults.standard
    private var userScoresArray: [UserScore] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readUserScores()
        scoreTableView.dataSource = self
        scoreTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func clearScoreAction(_ sender: Any) {
        userDefaults.removeObject(forKey: UserDefaultsKeys.userScore.rawValue)
    }
    
    private func readUserScores() {
        if let userScoreData = userDefaults.value(forKey: .userScore) as? Data {
            do {
                self.userScoresArray = try JSONDecoder().decode([UserScore].self, from: userScoreData)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

extension ScoreViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userScoresArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row + 1) | \(userScoresArray[indexPath.row].userName) |  \(userScoresArray[indexPath.row].date) |  \(userScoresArray[indexPath.row].score)"
        return cell
    }
    
}

extension ScoreViewController: UITableViewDelegate {
     
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
