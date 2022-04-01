//
//  ProductDetailInfo.swift
//  collectionViewTe
//
//  Created by 이호엽 on 2022/03/28.
//

import Foundation

struct ProductInformation: Codable{
    let productDetailInfo : [ProductDetailInfo]

    enum CodingKeys: String, CodingKey {
        case productDetailInfo = "data"
    }
}


struct ProductDetailInfo : Codable {
    var content_no : Int
    var sub_title : String
    var sold_out_flag : String
    var fvr_cnt : Int
    var main_img_path : String
    var title : String
    var comment_cnt : Int
    var reg_date : String
    var content_div_cd : String
    var img_path : String
    var best_order : Int
    var hit_cnt : Int
    var link_url : String
}


