//
//  ReusableTextImputField.swift
//  Workout Timer
//
//  Created by Valentin Prossliner on 20/5/24.
//

import Foundation
import SwiftUI

struct TextInputField: View {
    private var title: String
    @Binding private var text: String
    var clearButtonPadding: CGFloat = 20
    
    @Environment(\.clearButtonHidden) var clearButtonHidden
    
    init(_ title: String, text: Binding<String>){
        self.title = title
        self._text = text
    }
    
    
    var clearButton: some View {
        HStack{
            if !clearButtonHidden {
                Spacer()
                Button(action:{ text = ""}){
                    Image(systemName: "multiply.circle.fill")
                        .foregroundStyle(Color(UIColor.systemGray))
                }
            }
            else {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(text.isEmpty ? Color(.placeholderText): .accentColor)
                .offset(y: text.isEmpty ? 0:-25)
                .scaleEffect(text.isEmpty ? 1:0.8, anchor: .leading)
            
            TextField("", text: $text)
                .padding(.trailing, clearButtonPadding)
                .overlay(clearButton)
        }
    
    }
}
