//
//  BaseViewController.swift
//  test
//
//  Created by Георгий Сабанов on 22/12/2018.
//  Copyright © 2018 Георгий Сабанов. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import MBProgressHUD

class BaseViewController: UIViewController {
    private var progressHUD: MBProgressHUD?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        adjustUI()
        configureConstraints()
        configureNavigationController()
    }
    
    func adjustUI()
    {
        view.backgroundColor = .white
    }
    
    func configureConstraints()
    {
        
    }

    func configureViewModel()
    {
        
    }
    
    func configureNavigationController()
    {
    
    }
    
    func showBasicAlert(withMessage message: String?)
    {
        guard message != nil else { return }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleError(error: Error?)
    {
        self.showBasicAlert(withMessage: error?.localizedDescription)
    }
    
    func showHUD()
    {
        DispatchQueue.main.async {
            self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func hideHUD()
    {
        DispatchQueue.main.async { [weak self] in
            self?.progressHUD?.hide(animated: true)
        }
    }
}
