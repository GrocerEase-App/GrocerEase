//
//  Binding.swift
//  GrocerEase
//
//  Created by Finlay Nathan on 5/21/25.
//

import SwiftUI

extension Binding {
    /// Allows controls which require a float binding (such as Slider) to bind to
    /// an integer variable.
    ///
    /// Credit: https://stackoverflow.com/a/74356845
    public static func convert<TInt, TFloat>(_ intBinding: Binding<TInt>)
        -> Binding<TFloat>
    where
        TInt: BinaryInteger,
        TFloat: BinaryFloatingPoint
    {
        Binding<TFloat>(
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }
}
