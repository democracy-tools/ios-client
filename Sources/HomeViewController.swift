//
//  HomeViewController.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

class HomeViewController: UIViewController, HomeViewModelDelegate {
    @IBOutlet var background: UIView!
    @IBOutlet var button: UIButton!
    @IBOutlet var counter: UILabel!
    @IBOutlet var container: UIView!

    let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomeViewController", bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        abort()
    }
    
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.layer.borderColor = #colorLiteral(red: 0.3215686275, green: 0.5058823529, blue: 0.9450980392, alpha: 0.4045685017).cgColor
        background.addStandardMotionEffects(x: 20, y: 40)
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.handleAppeared()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.handleDisappeared()
    }

    /// Views
    
    func updateViews() {
        guard isViewLoaded else { return }
    }
    
    /// Actions
    
    @IBAction func didPressAction() {
        viewModel.handleActionPressed()
    }
    
    func viewModelDidUpdateState(_ viewModel: HomeViewModel) {
        updateViews()
    }
}
