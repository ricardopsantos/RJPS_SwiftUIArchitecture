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

extension CalendarView {
    enum Config {
        static let monthFont: FontSemantic = .headlineBold
        static let weekDaysFont: FontSemantic = .bodyBold
        static let daysFont: FontSemantic = .body
        enum CurrentDay {
            static let textColor = ColorSemantic.labelPrimary.color
            static let cellBackgroundColor = ColorSemantic.primary.color
        }

        enum CurrentMonth {
            static let textColor = ColorSemantic.labelPrimary.color
            static let cellBackgroundColor = ColorSemantic.labelPrimaryInverted.color
        }

        enum OtherMonths {
            static let textColor = ColorSemantic.labelSecondary.color
            static let cellBackgroundColor = ColorSemantic.labelSecondary.color.opacity(0.2)
        }
    }
}

struct DayView: View {
    @Environment(\.colorScheme) var colorScheme
    private let day: Day
    @Binding private var currentDate: Date
    @Binding private var selectedDay: Date?
    private let maxH: CGFloat = SizeNames.defaultMargin * 2
    private var unitDay: Int {
        Calendar.current.component(.day, from: day.date)
    }

    public init(day: Day, currentDate: Binding<Date>, selectedDay: Binding<Date?>) {
        self.day = day
        self._currentDate = currentDate
        self._selectedDay = selectedDay
    }

    var body: some View {
        Text("\(unitDay)")
            .fontSemantic(CalendarView.Config.daysFont)
            .frame(maxWidth: .infinity, maxHeight: maxH)
            .background(backgroundColor())
            .foregroundColor(textColor())
            .onTapGesture {
                withAnimation {
                    if day.isPrevMonth {
                        currentDate = currentDate.add(month: -1)
                    } else if day.isNextMonth {
                        currentDate = currentDate.add(month: 1)
                    } else {
                        if selectedDay == day.date {
                            selectedDay = nil // Unselect if the same day is tapped
                        } else {
                            selectedDay = day.date
                            currentDate = currentDate.set(day: unitDay)
                        }
                    }
                }
            }
            .cornerRadius2(day.date.isToday ? maxH / 2 : SizeNames.cornerRadius / 2)
    }

    @ViewBuilder
    func backgroundColor() -> some View {
        Group {
            if day.date.isToday {
                CalendarView.Config.CurrentDay.cellBackgroundColor
            } else if day.date == selectedDay {
                CalendarView.Config.CurrentDay.cellBackgroundColor.opacity(0.5)
            } else {
                day.isCurrentMonth ?
                    CalendarView.Config.CurrentMonth.cellBackgroundColor :
                    CalendarView.Config.OtherMonths.cellBackgroundColor
            }
        }
    }

    func textColor() -> Color {
        if day.date.isToday {
            return CalendarView.Config.CurrentDay.textColor
        } else {
            return day.isCurrentMonth ?
                CalendarView.Config.CurrentMonth.textColor :
                CalendarView.Config.OtherMonths.textColor
        }
    }
}

struct CalendarHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding private var currentDate: Date
    public init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
    }

    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    currentDate = currentDate.add(month: -1)
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
                .fontSemantic(CalendarView.Config.monthFont)
                .textColor(ColorSemantic.primary.color)
            Spacer()
            Button(action: {
                withAnimation {
                    currentDate = currentDate.add(month: 1)
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
    @Environment(\.colorScheme) var colorScheme
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }

    var body: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .fontSemantic(CalendarView.Config.weekDaysFont)
                    .textColor(ColorSemantic.labelPrimary.color)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct CalendarMonthlyView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding private var currentDate: Date
    @Binding private var selectedDay: Date?

    public init(currentDate: Binding<Date>, selectedDay: Binding<Date?>) {
        self._currentDate = currentDate
        self._selectedDay = selectedDay
    }

    var body: some View {
        let days = generateDays(for: currentDate)
        VStack(spacing: SizeNames.defaultMarginSmall) {
            ForEach(0..<6) { row in
                HStack(spacing: SizeNames.defaultMarginSmall) {
                    ForEach(0..<7) { col in
                        let day = days[row * 7 + col]
                        DayView(day: day, currentDate: $currentDate, selectedDay: $selectedDay)
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

        let daysBefore = (firstWeekdayOfMonth + 5) % 7 // Days before the start of the month, adjusted for Monday

        for i in 0..<42 {
            let dayOffset = i - daysBefore
            let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth)!
            let isCurrentMonth = calendar.isDate(dayDate, equalTo: date, toGranularity: .month)
            let isPrevMonth = dayOffset < 0
            let isNextMonth = !isCurrentMonth && !isPrevMonth
            days.append(Day(
                date: dayDate,
                isCurrentMonth: isCurrentMonth,
                isPrevMonth: isPrevMonth,
                isNextMonth: isNextMonth
            ))
        }

        return days
    }
}

struct CalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentDate = Date()
    @State private var selectedDay: Date? = nil

    var body: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            CalendarHeaderView(currentDate: $currentDate)
            DaysOfWeekView()
            CalendarMonthlyView(currentDate: $currentDate, selectedDay: $selectedDay)
            Spacer()
        }.onChange(of: currentDate) { new in
            print("New: \(currentDate)")
        }.onChange(of: selectedDay) { new in
            print("New: \(selectedDay)")
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
