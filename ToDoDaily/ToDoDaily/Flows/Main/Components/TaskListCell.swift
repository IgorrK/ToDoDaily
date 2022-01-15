//
//  TaskListCell.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 12.01.2022.
//

import SwiftUI

struct TaskListCell: View {
    
    // MARK: - Properties
    
    @Binding var task: TaskItem
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 8.0) {
            header
            
            Text(task.text ?? "")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8.0)
        .padding(.vertical, 8.0)
        .background(Asset.Colors.listRowBackground.color)
        .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8.0)
                .stroke(Asset.Colors.primaryBorder.color, lineWidth: 1.0)
        )
    }
}

// MARK: - Subviews
private extension TaskListCell {
    private var header: some View {
        guard let dueDate = task.dueDate else { return AnyView(EmptyView()) }
        
        let day = dueDate.component(.day)
        let weekday = dueDate.component(.weekday)
        let month = dueDate.component(.month)
        
        guard let weekdaySymbol = Calendar.current.shortWeekdaySymbols[safe: weekday - 1],
              let monthSymbol = Calendar.current.shortMonthSymbols[safe: month - 1] else {
                  return AnyView(EmptyView())
              }
        
        return AnyView(
            HStack {
                VStack(alignment: .leading, spacing: 0.0) {
                    
                    HStack(alignment: .center, spacing: 4.0) {
                        
                        Text("\(day)")
                            .font(.system(size: 40.0, weight: .bold))
                        
                        VStack(alignment: .leading) {
                            
                            Text(monthSymbol)
                                .font(.system(size: 14.0, weight: .bold))
                            
                            Text(weekdaySymbol)
                                .font(.system(size: 14.0, weight: .bold))
                        }
                        
                        Text(dueDate, style: .time)
                            .font(.system(size: 20.0, weight: .bold))
                            .padding(.top, 12.0)
                    }
                    
                    Asset.Colors.listSeparator.color
                        .frame(height: 1.0)
                    
                }
                .fixedSize(horizontal: true, vertical: false)
                
                Spacer()
            }
        )
    }
}
