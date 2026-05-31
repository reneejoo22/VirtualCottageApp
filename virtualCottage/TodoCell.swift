//
//  TodoCell.swift
//  virtualCottage
//
//  Created by 주희연 on 5/20/26.
//

import UIKit

class TodoCell: UITableViewCell {
    
    let checkButton = UIButton()
    let todoLabel = UILabel()
    let deleteButton = UIButton()
    let timeLabel = UILabel()  // 여기로!
    
    var isChecked = false
    var onDelete: (() -> Void)?
    var onCheck: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        
        checkButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkButton.tintColor = UIColor(red: 91/255, green: 138/255, blue: 111/255, alpha: 1)
        checkButton.addTarget(self, action: #selector(checkTapped), for: .touchUpInside)
        
        todoLabel.font = UIFont.systemFont(ofSize: 15)
        todoLabel.textColor = .darkText
        
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.textColor = .gray
        
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .lightGray
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        [checkButton, todoLabel, timeLabel, deleteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            checkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            checkButton.widthAnchor.constraint(equalToConstant: 28),
            
            todoLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            todoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            todoLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            timeLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            timeLabel.topAnchor.constraint(equalTo: todoLabel.bottomAnchor, constant: 2),
            timeLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    @objc func checkTapped() {
        isChecked.toggle()
        checkButton.isSelected = isChecked
        todoLabel.attributedText = isChecked
            ? NSAttributedString(string: todoLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                             .foregroundColor: UIColor.lightGray])
            : NSAttributedString(string: todoLabel.text ?? "",
                attributes: [.foregroundColor: UIColor.darkText])
        onCheck?()
    }
    
    @objc func deleteTapped() {
        onDelete?()
    }
}
