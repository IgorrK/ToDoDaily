//
//  SettingsRow.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 01.01.2022.
//

import SwiftUI

struct SettingsRow: View {
    
    // MARK: - Properties
    
    var item: SettingsItem
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, 16.0)

            Spacer()
            
            item.icon
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.primary)
                .frame(width: 24.0, height: 24.0)
                .padding(.trailing, 16.0)
        }
        .navigationTitle(L10n.Settings.title)
    }
}

struct SettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRow(item: .editProfile)
    }
}


fileprivate extension SettingsItem {
    var title: String {
        switch self {
        case .editProfile:
            return L10n.Settings.editProfile
        case .logOut:
            return L10n.Settings.logOut
        }
    }
    
    var icon: Image {
        switch self {
        case .editProfile:
            return Asset.Images.edit.image
        case .logOut:
            return Asset.Images.logOut.image
        }
    }
}
