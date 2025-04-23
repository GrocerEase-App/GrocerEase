import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var quantity = 1
    @State private var priceString = ""
    @State private var store = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Info") {
                    TextField("Name", text: $name)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                    TextField("Store (optional)", text: $store)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
                    .disabled(name.isEmpty || Double(priceString) == nil)
                }
            }
        }
    }

    private func saveItem() {
        let price = Double(priceString) ?? 0.0
        let newItem = Item(name: name, quantity: quantity, price: price, store: store)
        modelContext.insert(newItem)
    }
}
