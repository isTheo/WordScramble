//
//  ViewController.swift
//  Project5-WordScramble
//
//  Created by Matteo Orru on 22/01/24.



import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the title a little bit lower
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(+8, for: .default)
        
        if let backgroundImage = UIImage(named: "WSbackground.png", in: Bundle.main, compatibleWith: nil) {
            
            let backgroundImageView = UIImageView(image: backgroundImage)
            backgroundImageView.contentMode = .scaleAspectFill
            tableView.backgroundView = backgroundImageView
            
            tableView.backgroundColor = .clear
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        //this block checks for and unwraps the contents of the "start" file, then converts it to an array
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }

    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    @objc func restartGame() {
        startGame()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        //used to store a string range
        let range = NSRange(location: 0, length: word.utf16.count)
        //first parameter is our string, second is our range to scan (whole string), the last is the language we should be checking with
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.count < 3 || word == title {
            return false
        }
        
        return mispelledRange.location == NSNotFound
    }
    
    
    func submit(_ answer: String) {
        showErrorMessage(answer)
    }
    
    //this method needs to check if the player's word can be formed with the given letters, avoiding duplicates, and ensuring that it is a real English word
    func showErrorMessage(_ text: String) {
        
        let lowerAnswer = text.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    //if all checks succeed, adds the word to usedWords and inserts a new row in the table without reloading the entire view
                    usedWords.insert(text.lowercased(), at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                    
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = title?.lowercased() else { return }
            errorTitle = "Word not possibile"
            errorMessage = "You can't spell that word from \(title)"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    
    
    @objc func promptForAnswer() {
        //addTextField() method adds an editable text input field to the UIAlertController, where users will type their text to answer the anagrams as they go
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {

            [weak self, weak ac] action in
            //safely unwraps the array of text fields
            guard let answer = ac?.textFields?[0].text else { return }
            //pulls out the text from the text field and passes it to our submit() method
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    
    
}

