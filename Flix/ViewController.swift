//
//  ViewController.swift
//  Flix
//
//  Created by Sam Mahmood on 3/4/22.
//

import UIKit
import AlamofireImage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Network request for data from API.
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { [self] (data, response, error) in
             // This will run when the network request returns.
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    // Store data as an array of dictionaries.
                    self.movies = dataDictionary["results"] as! [[String:Any]]
                    // Reload your table view data.
                    self.tableView.reloadData()
                
             }
        }
        task.resume()
    }
    // Specfiy number of rows in TableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    // Specify cell properties.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let synopsis = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.synopsisLabel.text = synopsis
        
        // Construct custom URL for poster following API documentation.
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterUrl = URL(string: baseUrl + posterPath)
        
        // Access image through AlamofireImage module.
        cell.posterView.af.setImage(withURL: posterUrl!)
        
        return cell
    }
    
    // Function that passes data to the details screens.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Find selected movie.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        // Pass the selected movie to the details view controller.
        let detailsViewController = segue.destination as! MovieDetailsViewController
        detailsViewController.movie = movie
        // Unselects cell after transition.
        tableView.deselectRow(at: indexPath, animated: true)
    }


}

