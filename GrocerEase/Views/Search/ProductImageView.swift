//
//  ProductImageView.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/20/25.
//

import SwiftUI

struct ProductImageView: View {
    var url: URL?
    var large: Bool = false
    var size: CGFloat {
        return large ? 100 : 50
    }
    var body: some View {
        VStack {
            if let url = url {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .frame(width: size, height: size)
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: size, height: size)
            }
        }
    }
}


