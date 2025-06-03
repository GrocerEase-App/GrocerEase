# GrocerEase Contribution Guidelines

The authors of the Swift programming language have not proposed an official style guide. However, the latest release of Xcode comes bundled with a formatting tool that follows the most commonly used practices for writing clean Swift code.

Therefore, it should be sufficient to run this formatter in Editor \> Structure \> Format File with ‘swift-format’ before pushing any completed code to avoid inconsistencies in style.

All other conventions that cannot be handled automatically, such as symbol naming, should follow Google’s style guide which is available at the following link.  
[Swift Style Guide](https://google.github.io/swift/)

It is also necessary for maintainability that all symbols be described with inline documentation by following the process described by Apple at the link below, barring the exceptions in the above style guide, such as if the symbol is extremely self-explanatory or an inherited symbol is already sufficiently described in a superclass.  
[Writing symbol documentation in your source files](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files)

All models should provide sample data. All views should have previews using sample data.

SwiftUI View names should end in “View” unless they wrap a single, specific control, such as “CurrentLocationButton” or “GroceryListMenu.”

If a view does significant processing on underlying data, its logic should be extracted to a ViewModel. If a view only displays data and does not modify it, it should not have an associated ViewModel.

For development simplicity, a String describing an error is an appropriate way to throw an error. Typed throws were only recently added and more research needs to be done to decide the best way to implement them.

Do not commit code to the main branch that does not compile (install and run) successfully.

File names should match the name of the top-level symbol (class) they contain. Files should not contain more than one top level definition