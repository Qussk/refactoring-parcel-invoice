//
//  ParcelInvoiceMaker - ParcelOrderView.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

protocol ParcelOrderViewDelegate {
    func parcelOrderMade(_ parcelInformation: ParcelInformation)
}

protocol DiscountStrategy {
    func applyDiscount(deliveryCost: Int) -> Int
}


enum layoutViewTitle {
    static let name: String = "이름"
    static let mobail: String = "전화"
    static let address: String = "주소"
    static let cost: String = "요금"
    static let discount: String = "할인"
    static let notice: String = "알림"
}

class NoDiscount: DiscountStrategy {
    func applyDiscount(deliveryCost: Int) -> Int {
        return 0
    }
}

class VIPDiscount: DiscountStrategy {
    func applyDiscount(deliveryCost: Int) -> Int {
        return deliveryCost / 5 * 4
    }
}

class CouponDiscount: DiscountStrategy {
    func applyDiscount(deliveryCost: Int) -> Int {
        return deliveryCost / 2
    }
}



class ParcelOrderView: UIView {
    
    private var delegate: ParcelOrderViewDelegate!
    
    private let receiverNameField: UITextField = {
        let field: UITextField = .init()
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let receiverMobileField: UITextField = {
        let field: UITextField = .init()
        field.borderStyle = .roundedRect
        field.keyboardType = .phonePad
        return field
    }()
    
    private let addressField: UITextField = {
        let field: UITextField = .init()
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let costField: UITextField = {
        let field: UITextField = .init()
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        return field
    }()
    
    enum segmentOption {
        static let not = "없음"
        static let vip = "VIP"
        static let coupone = "쿠폰"
    }
    
    private let discountSegmented: UISegmentedControl = {
        let control: UISegmentedControl = .init()
        control.insertSegment(withTitle: segmentOption.not, at: 0, animated: false)
        control.insertSegment(withTitle: segmentOption.vip, at: 1, animated: false)
        control.insertSegment(withTitle: segmentOption.coupone, at: 2, animated: false)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    init(delegate: ParcelOrderViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        
        backgroundColor = .systemBrown
        layoutView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func touchUpOrderButton(_ sender: UIButton) {
        guard let name: String = receiverNameField.text,
              let mobile: String = receiverMobileField.text,
              let address: String = addressField.text,
              let costString: String = costField.text,
              name.isEmpty == false,
              mobile.isEmpty == false,
              address.isEmpty == false,
              costString.isEmpty == false,
              let cost: Int = Int(costString),
              let discount: Discount = Discount(rawValue: discountSegmented.selectedSegmentIndex)
        else {
            return
        }
        
        
        self.discount(discount: discount, cost: cost)
            
        
        let parcelInformation: ParcelInformation = .init(address: address,
                                                         receiverName: name,
                                                         receiverMobile: mobile,
                                                         deliveryCost: cost,
                                                         discount: discount)
        delegate.parcelOrderMade(parcelInformation)
    }
    
    private func discount(discount: Discount, cost: Int) {
        let discount = discount.strategy.applyDiscount(deliveryCost: cost)
        
        print("디스카운트 결과: \(discount)")
        
    }
    
    private func layoutView() {
        
        let logoImageView: UIImageView = UIImageView(image: UIImage(named: "post_office_logo"))
        logoImageView.contentMode = .scaleAspectFit
        
        let nameLabel: UILabel = UILabel()
        nameLabel.text = layoutViewTitle.name
        
        let mobileLabel: UILabel = UILabel()
        mobileLabel.text = layoutViewTitle.mobail
        
        let addressLabel: UILabel = UILabel()
        addressLabel.text = layoutViewTitle.address
        
        let costLabel: UILabel = UILabel()
        costLabel.text = layoutViewTitle.cost
        
        let discountLabel: UILabel = UILabel()
        discountLabel.text = layoutViewTitle.discount
        
        let notificationLabel: UILabel = UILabel()
        notificationLabel.text = layoutViewTitle.notice
        
                
        [nameLabel, mobileLabel, addressLabel, costLabel, discountLabel, notificationLabel].forEach {
            $0.textColor = .black
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }

        
        let nameStackView: UIStackView = .init(arrangedSubviews: [nameLabel, receiverNameField])
        nameStackView.distribution = .fill
        
        let mobileStackView: UIStackView = .init(arrangedSubviews: [mobileLabel, receiverMobileField])
        
        let addressStackView: UIStackView = .init(arrangedSubviews: [addressLabel, addressField])
        
        let costStackView: UIStackView = .init(arrangedSubviews: [costLabel, costField])
        
        let discountStackView: UIStackView = .init(arrangedSubviews: [discountLabel, discountSegmented])
        
        let makeOrderButton: UIButton = UIButton(type: .system)
        makeOrderButton.backgroundColor = .white
        makeOrderButton.setTitle("택배 보내기", for: .normal)
        makeOrderButton.addTarget(self, action: #selector(touchUpOrderButton), for: .touchUpInside)
        
        let mainStackView: UIStackView = .init(arrangedSubviews: [logoImageView, nameStackView, mobileStackView, addressStackView, costStackView, discountStackView, makeOrderButton])
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
        [nameStackView, mobileStackView, addressStackView, costStackView, discountStackView, mainStackView].forEach {
            $0.spacing = 8
            $0.axis = .horizontal
            mainStackView.axis = .vertical
        }

        
        let safeArea: UILayoutGuide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1),
            mainStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -16)
        ])
            
    }
}
