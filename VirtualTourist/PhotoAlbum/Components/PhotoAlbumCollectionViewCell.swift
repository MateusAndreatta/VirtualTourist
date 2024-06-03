//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 26/05/24.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "landscape-placeholder")
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray
        constraintUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "landscape-placeholder")
    }
    
    // MARK: - Functions
    func configureImage(with photo: Photo) {
        if let data = photo.image {
            DispatchQueue.global(qos: .default).async { [weak self] in
                sleep(1)
                let image = UIImage(data: data)
                DispatchQueue.main.async(execute: { () -> Void in
                    self?.imageView.image = image
                })
            }
        }
    }
    
    private func constraintUI() {
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
