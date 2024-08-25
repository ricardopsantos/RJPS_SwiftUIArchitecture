//
//  CalendarView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 25/08/2024.
//

import Foundation
import SwiftUI
//
import DevTools
import DesignSystem
import Common

struct Day {
    let date: Date
    let isCurrentMonth: Bool
    let isPrevMonth: Bool
    let isNextMonth: Bool
}

struct DayView: View {
    let day: Day
    @Binding var currentDate: Date
    let maxH: CGFloat = SizeNames.defaultMargin * 2

    var body: some View {
        Text("\(Calendar.current.component(.day, from: day.date))")
            .frame(maxWidth: .infinity, maxHeight: maxH)
            .background(backgroundColor())
            .foregroundColor(foregroundColor() as? Color)
            .onTapGesture {
                withAnimation {
                    if day.isPrevMonth {
                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                    } else if day.isNextMonth {
                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }
                }
            }
            .cornerRadius2(day.date.isToday ? maxH / 2 : SizeNames.cornerRadius / 2)
    }
    
    @ViewBuilder
    func backgroundColor() -> some View {
        Group {
            if day.date.isToday {
                ColorSemantic.primary.color
            } else {
                day.isCurrentMonth ?
                ColorSemantic.labelPrimaryInverted.color :
                Color.gray.opacity(0.2)
            }
        }
    }
    
    @ViewBuilder
    func foregroundColor() -> some View {
        Group {
            if day.date.isToday {
                ColorSemantic.primary.color
            } else {
                day.isCurrentMonth ?
                ColorSemantic.labelPrimary.color :
                ColorSemantic.labelSecondary.color
            }
        }
    }
}

struct CalendarHeaderView: View {
    @Binding var currentDate: Date
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }
            }) {
                Image(.back)
                    .resizable()
                    .scaledToFit()
                    .frame(width: SizeNames.defaultMargin * 1.5)
                    .tint(ColorSemantic.primary.color)
            }
            Spacer()
            Text(currentDate, formatter: DateFormatter.monthAndYear)
                .fontSemantic(.headline)
            Spacer()
            Button(action: {
                withAnimation {
                    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }
            }) {
                Image(.back)
                    .resizable()
                    .scaledToFit()
                    .frame(width: SizeNames.defaultMargin * 1.5)
                    .tint(ColorSemantic.primary.color)
                    .rotate(degrees: 180)
            }
        }
        .padding(.vertical, SizeNames.defaultMargin)
    }
}

struct DaysOfWeekView: View {
    var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }

    var body: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .fontSemantic(.callout)
                    .textColor(ColorSemantic.labelPrimary.color)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct CalendarMonthlyView: View {
    @Binding var currentDate: Date
    var body: some View {
        let days = generateDays(for: currentDate)
        VStack(spacing: SizeNames.defaultMarginSmall) {
            ForEach(0..<6) { row in
                HStack(spacing: SizeNames.defaultMarginSmall) {
                    ForEach(0..<7) { col in
                        let day = days[row * 7 + col]
                        DayView(day: day, currentDate: $currentDate)
                    }
                }
            }
        }
    }

    func generateDays(for date: Date) -> [Day] {
        let calendar = Calendar.current
        var days = [Day]()

        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstDayOfMonth)

        let daysBefore = (firstWeekdayOfMonth + 5) % 7  // Days before the start of the month, adjusted for Monday

        for i in 0..<42 {
            let dayOffset = i - daysBefore
            let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth)!
            let isCurrentMonth = calendar.isDate(dayDate, equalTo: date, toGranularity: .month)
            let isPrevMonth = dayOffset < 0
            let isNextMonth = !isCurrentMonth && !isPrevMonth
            days.append(Day(date: dayDate, 
                            isCurrentMonth: isCurrentMonth,
                            isPrevMonth: isPrevMonth,
                            isNextMonth: isNextMonth))
        }

        return days
    }
}

struct CalendarView: View {
    @State private var currentDate = Date()
    var body: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            CalendarHeaderView(currentDate: $currentDate)
              //  .background(Color.red)
            DaysOfWeekView()
              //  .background(Color.blue)
            CalendarMonthlyView(currentDate: $currentDate)
              //  .background(Color.green)
            Spacer()
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CalendarView()
}
#endif
