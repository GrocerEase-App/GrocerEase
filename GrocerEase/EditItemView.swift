//
//  ManualEntryView.swift
//  GrocerEase
//
//  Created by Arushi Tyagi on 4/26/25.
//
import SwiftUI

struct LittleBadge: View {
    var text: String
    var color: Color = .green
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.vertical, 3)
            .padding(.horizontal, 5)
            .background(color)
            .cornerRadius(5)
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    var item: GroceryItem
    var onSave: ((GroceryItem) -> Void)?
    
    var body: some View {
        
        Form {
            Section(header: Text("Item Details")) {
                HStack {
                    if let url = item.imageUrl {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .frame(width: 75, height: 75)
                                .clipShape(.buttonBorder)
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 75, height: 75)
                            .clipShape(.buttonBorder)
                    }
                    VStack(alignment: .leading) {
                        Text(item.name)
                        if let brand = item.brand {
                            Text(brand).foregroundStyle(.secondary)
                        }
                        
                    }.padding(5)
                    if item.snap ?? false {
                        Spacer()
                        LittleBadge(text: "SNAP")
                    }
                }
                
                HStack {
                    Text("Price")
                    Spacer()
                    if item.soldByWeight ?? false {
                        Text("about").foregroundStyle(.secondary)
                    }
                    if let originalPrice = item.originalPrice, originalPrice != item.price {
                        Text("$" + String(format: "%.2f", originalPrice)).strikethrough().foregroundStyle(.secondary)
                    }
                    if let price = item.price {
                        Text("$" + String(format: "%.2f", price)).foregroundStyle(.secondary)
                    }
                    if item.soldByWeight ?? false {
                        Text("each").foregroundStyle(.secondary)
                    }
                }
                
                if let unitPrice = item.unitPrice {
                    HStack {
                        Text("Unit Price")
                        Spacer()
                        if let originalUnitPrice = item.originalUnitPrice, originalUnitPrice != item.unitPrice {
                            Text("$" + String(format: "%.2f", originalUnitPrice)).strikethrough().foregroundStyle(.secondary)
                        }
                        if let unitPrice = item.unitPrice {
                            Text("$" + String(format: "%.2f", unitPrice)).foregroundStyle(.secondary)
                        }
                        Text("/").foregroundStyle(.secondary)
                        if let unit = item.unit {
                            Text(unit.symbol).foregroundStyle(.secondary)
                        }
                    }
                }
                

            }
            
            Section("Store Details") {
                Button {
                    print("hi")
                } label: {
                    VStack(alignment: .leading) {
                        Text("\(item.store.brand) #\(item.store.storeNum)")
                        if let address = item.store.address {
                            Text(address).foregroundStyle(.secondary).font(.caption)
                        }
                    }
                }
                
                if let department = item.department {
                    HStack {
                        Text("Department")
                        Spacer()
                        Text(department).foregroundStyle(.secondary)
                    }
                }
                
                if let location = item.location {
                    HStack {
                        Text("Location")
                        Spacer()
                        Text(location).foregroundStyle(.secondary)
                    }
                    
                }
                
                if let inStock = item.inStock {
                    HStack {
                        Text("Availability")
                        Spacer()
                        Text(inStock ? "In Stock" : "Out of Stock").foregroundStyle(.secondary)
                    }
                }
            }
            
            Section {
                if let upc = item.upc {
                    HStack {
                        Text("UPC")
                        Spacer()
                        Text(upc)
                            .foregroundStyle(.secondary)
                    }
                }
                if let sku = item.sku {
                    HStack {
                        Text("SKU")
                        Spacer()
                        Text(sku)
                            .foregroundStyle(.secondary)
                    }
                }
                if let plu = item.plu {
                    HStack {
                        Text("PLU")
                        Spacer()
                        Text(plu)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack {
                    Text("SNAP EBT Eligible")
                    Spacer()
                    
                    if let snap = item.snap {
                        Text(snap ? "Yes" : "No").foregroundStyle(.secondary)
                    } else {
                        Text("Unknown").foregroundStyle(.secondary)
                    }
                        
                }
            } header: {
                Text("Additional Details")
            } footer: {
                Text("To edit details manually, first save the item then return to it in your shopping list.")
            }
            
            
        }
        .navigationTitle("Review Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    item.save()
                    onSave?(item)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
//        EditItemView(item: GroceryItem.sample)
    }
}
