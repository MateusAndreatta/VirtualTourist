//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 25/05/24.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    let viewModel: PhotoAlbumViewModel
    
    private lazy var mapView: PhotoAlbumMapView = {
        let mapView = PhotoAlbumMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private lazy var containerView: UIStackView = {
        let containerView = UIStackView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 1
        let size = (UIScreen.main.bounds.size.width / 3) - 2 * spacing
        layout.itemSize = CGSize(width: size, height: size)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing * 2
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoAlbumCollectionViewCell.self, forCellWithReuseIdentifier: "photoAlbumCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        return collectionView
    }()
    
    private lazy var noImagesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Images"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
         let indicator = UIActivityIndicatorView()
         indicator.translatesAutoresizingMaskIntoConstraints = false
         return indicator
     }()
    
    private lazy var newCollectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New Collection", for: .normal)
        button.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        button.addTarget(self, action: #selector(newCollectionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: PhotoAlbumViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        constraintUI()
        view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setup(for: viewModel.coordinate)
        viewModel.load()
        if viewModel.photos.isEmpty {
            requestPhotos()
        } else {
            collectionView.reloadData()
            shouldShowImages(true)
        }
    }
    
    func constraintUI() {
        view.addSubview(mapView)
        view.addSubview(containerView)
        view.addSubview(newCollectionButton)
        containerView.addArrangedSubview(collectionView)
        containerView.addArrangedSubview(noImagesLabel)
        containerView.addArrangedSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 120),
            
            containerView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            newCollectionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newCollectionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newCollectionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newCollectionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
     private func requestPhotos() {
         showLoading()
         viewModel.getPhotos { [weak self] success in
             guard let self else { return }
             if !success {
                 return
             }
             self.shouldShowImages(!self.viewModel.photos.isEmpty)
             self.collectionView.reloadData()
         }
    }
    
    private func shouldShowImages(_ show: Bool) {
        collectionView.isHidden = !show
        noImagesLabel.isHidden = show
        activityIndicator.isHidden = true
        newCollectionButton.isEnabled = true
    }
    
    private func showLoading() {
        activityIndicator.isHidden = false
        newCollectionButton.isEnabled = false
        collectionView.isHidden = true
        noImagesLabel.isHidden = true
    }
    
    @objc func newCollectionButtonTapped() {
        requestPhotos()
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.deletePhoto(at: indexPath)
        collectionView.deleteItems(at: [indexPath])
        shouldShowImages(!viewModel.photos.isEmpty)
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCell", for: indexPath) as? PhotoAlbumCollectionViewCell
        else { return UICollectionViewCell() }
        
        let photo = self.viewModel.photos[indexPath.row]
        cell.configureImage(with: photo)
        
        return cell
    }
    
}
