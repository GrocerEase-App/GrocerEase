//
//  DebounceStatePropertyWrapperDemoNative.swift
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
//  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Copyright © 2022 Adam Fordyce. All rights reserved.
//

import SwiftUI
import Combine

/// Adds a "debounce" delay to the State wrapper
///
/// This can be used to "wait" for the user to stop typing before making
/// another API call, reducing the risk of getting rate limited.
@propertyWrapper
struct DebouncedState<Value>: DynamicProperty {
    
    @StateObject private var backingState: BackingState<Value>
    
    init(initialValue: Value, delay: Double = 0.3) {
        self.init(wrappedValue: initialValue, delay: delay)
    }
    
    init(wrappedValue: Value, delay: Double = 0.3) {
        self._backingState = StateObject(wrappedValue: BackingState(originalValue: wrappedValue, delay: delay))
    }
    
    var wrappedValue: Value {
        get {
            backingState.debouncedValue
        }
        nonmutating set {
            backingState.currentValue = newValue
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding {
            backingState.currentValue
        } set: {
            backingState.currentValue = $0
        }
    }
    
    private class BackingState<TValue>: ObservableObject {
        @Published var currentValue: TValue
        @Published var debouncedValue: TValue
        
        private var cancellable: AnyCancellable?
        
        init(originalValue: TValue, delay: Double) {
            self.currentValue = originalValue
            self.debouncedValue = originalValue
            
            cancellable = $currentValue
                .map { value -> AnyPublisher<TValue, Never> in
                    if let str = value as? String, str.isEmpty {
                        // Immediately emit empty strings
                        return Just(value).eraseToAnyPublisher()
                    } else {
                        return Just(value)
                            .delay(for: .seconds(delay), scheduler: RunLoop.main)
                            .eraseToAnyPublisher()
                    }
                }
                .switchToLatest()
                .receive(on: RunLoop.main)
                .assign(to: \.debouncedValue, on: self)
        }
    }
}

struct DebounceStatePropertyWrapperDemoNative: View {
    
    @DebouncedState private var filterText = ""
    @State private var counter = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Input text:")
            TextEditor(text: $filterText)
                .textEditorStyle()
            
            Text("Debounced text:")
                .padding(.top, 15)
            Text(filterText)
                .textOutputStyle()
            
            ZStack {
                Text("\(counter)")
                    .font(.system(size: 50, weight: .light))
                    .frame(width: 100, height: 100)
                    .background(.white)
            }
            .clipShape(Circle())
            .contentShape(Circle())
            .overlay(Circle().stroke(.gray, lineWidth: 1))
            .offset(y: 100)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onChange(of: filterText) {
            counter += 1
        }
    }
}

private extension View {
    
    func textEditorStyle() -> some View {
        frame(height: 100)
            .textBoxBorder()
    }
    
    func textOutputStyle() -> some View {
        padding(5)
            .frame(height: 100, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .textBoxBorder()
    }
    
    func textBoxBorder() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 5))
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray, lineWidth: 1))
    }
}

struct DebounceStatePropertyWrapperDemoNative_Previews: PreviewProvider {
    struct DebounceStatePropertyWrapperDemoNative_Harness: View {
        
        var body: some View {
            DebounceStatePropertyWrapperDemoNative()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color(white: 0.8), Color(white: 0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea()
        }
    }
    
    static var previews: some View {
        DebounceStatePropertyWrapperDemoNative_Harness()
            .previewDevice("iPhone 13 Pro Max")
            .previewDisplayName("iPhone 13 Pro Max")
    }
}
