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
import Common

public extension CalendarView {
    enum Config {
        static let monthFont: FontSemantic = Header.defaultTitleFontSemantic
        static let weekDaysFont: FontSemantic = .bodyBold
        static let daysFont: FontSemantic = .body
        enum CurrentDay {
            static let currentDayShapeIsCircle = false
            static let textColor = ColorSemantic.labelPrimary.color
            static let cellBackgroundColor = ColorSemantic.primary.color
        }

        enum CurrentMonth {
            static let textColor = ColorSemantic.labelPrimary.color
            static let cellBackgroundColor = ColorSemantic.primary.color.opacity(0.1)
        }

        enum OtherMonths {
            static let textColor = ColorSemantic.labelSecondary.color
            static let cellBackgroundColor = ColorSemantic.labelSecondary.color.opacity(0.1)
        }
    }
}

public extension CalendarView {
    struct DayModel {
        public let date: Date
        public let isCurrentMonth: Bool
        public let isPrevMonth: Bool
        public let isNextMonth: Bool
        public let events: [Color]

        public init(date: Date, isCurrentMonth: Bool, isPrevMonth: Bool, isNextMonth: Bool, events: [Color]) {
            self.date = date
            self.isCurrentMonth = isCurrentMonth
            self.isPrevMonth = isPrevMonth
            self.isNextMonth = isNextMonth
            self.events = Array(Set(events)) // Remove duplicated
        }
    }
}


public struct DayView: View {
    @Environment(\.colorScheme) var colorScheme
    private let day: CalendarView.DayModel
    @Binding private var currentDate: Date
    @Binding private var selectedDay: Date?
    private var cellHeight: CGFloat {
        (
            screenWidth
                - 2 * SizeNames.defaultMargin // Side Margin
                - 6 * SizeNames.defaultMarginSmall // Inner Space
        ) / 7.0 // Days on a row
    }

    private var unitDay: Int {
        Calendar.current.component(.day, from: day.date)
    }

    public init(day: CalendarView.DayModel, currentDate: Binding<Date>, selectedDay: Binding<Date?>) {
        self.day = day
        self._currentDate = currentDate
        self._selectedDay = selectedDay
    }

    public var body: some View {
        ZStack {
            dayView
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
            eventsView
        }
        .frame(height: cellHeight)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    var eventsView: some View {
        if day.events.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                Spacer()
                LinearGradient(gradient: Gradient(colors: day.events),
                               startPoint: .leading,
                               endPoint: .trailing)
                .frame(height: 6)
                .cornerRadius2(3)
                .opacity(0.5)
            }
        }
    }
    
    var dayView: some View {
        Text("\(unitDay)")
            .fontSemantic(CalendarView.Config.daysFont)
            .frame(height: cellHeight)
            .frame(maxWidth: .infinity)
            .background(backgroundColor())
            .foregroundColor(textColor())
            .doIf(CalendarView.Config.CurrentDay.currentDayShapeIsCircle, transform: {
                $0.cornerRadius2(day.date.isToday ? cellHeight / 2 : SizeNames.cornerRadius / 2)
            })
            .doIf(!CalendarView.Config.CurrentDay.currentDayShapeIsCircle, transform: {
                $0.cornerRadius2(SizeNames.cornerRadius / 2)
            })
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

public struct CalendarHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding private var currentDate: Date
    @Binding private var selectedDay: Date?
    public init(currentDate: Binding<Date>, selectedDay: Binding<Date?>) {
        self._currentDate = currentDate
        self._selectedDay = selectedDay
    }

    public var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    currentDate = currentDate.add(month: -1)
                    selectedDay = nil
                }
            }) {
                Image("back")
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
                    selectedDay = nil
                }
            }) {
                Image("back")
                    .resizable()
                    .scaledToFit()
                    .frame(width: SizeNames.defaultMargin * 1.5)
                    .tint(ColorSemantic.primary.color)
                    .rotate(degrees: 180)
            }
        }
    }
}

public struct DaysOfWeekView: View {
    @Environment(\.colorScheme) var colorScheme
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }

    public var body: some View {
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

public struct CalendarMonthlyView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding private var currentDate: Date
    @Binding private var selectedDay: Date?
    @Binding private var eventsForDay: [Date: [Color]] // New Binding variable

    public init(currentDate: Binding<Date>, selectedDay: Binding<Date?>, eventsForDay: Binding<[Date: [Color]]>) {
        self._currentDate = currentDate
        self._selectedDay = selectedDay
        self._eventsForDay = eventsForDay
    }

    public var body: some View {
         let days = generateDays(for: currentDate)
         VStack(spacing: 0) {
             ForEach(0..<6) { row in
                 HStack(spacing: SizeNames.defaultMarginSmall) {
                     let allDays = (0..<7).map({ days[row * 7 + $0] })
                     let someDaysAreCurrentMonth = !allDays.filter({ $0.isCurrentMonth }).isEmpty
                     if someDaysAreCurrentMonth {
                         ForEach(0..<7) { col in
                             let day = days[row * 7 + col]
                             DayView(day: day, currentDate: $currentDate, selectedDay: $selectedDay)
                         }
                     } else {
                         // Don't display full rows that have only days from other month
                         EmptyView()
                     }
                 }
                 SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
             }
         }
     }

    func generateDays(for date: Date) -> [CalendarView.DayModel] {
            let calendar = Calendar.current
            var days = [CalendarView.DayModel]()

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

                let associated = eventsForDay.filter({ $0.key.isSame(day: dayDate) }).first?.value ?? []
                // Get the events for this date from the dateDic dictionary
                days.append(.init(
                    date: dayDate,
                    isCurrentMonth: isCurrentMonth,
                    isPrevMonth: isPrevMonth,
                    isNextMonth: isNextMonth,
                    events: associated
                ))
            }

            return days
        }
}

public struct CalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding private var currentDate: Date
    @Binding private var selectedDay: Date?
    @Binding private var eventsForDay: [Date: [Color]]
    private let onSelectedDay: (Date?) -> Void
    private let onSelectedMonth: (Date) -> Void
    public init(
         currentDate: Binding<Date>,
         selectedDay: Binding<Date?>,
         eventsForDay: Binding<[Date: [Color]]>,
         onSelectedDay: @escaping (Date?) -> Void,
         onSelectedMonth: @escaping (Date) -> Void
     ) {
         self._currentDate = currentDate
         self._selectedDay = selectedDay
         self._eventsForDay = eventsForDay
         self.onSelectedDay = onSelectedDay
         self.onSelectedMonth = onSelectedMonth
     }

    public var body: some View {
        VStack(spacing: SizeNames.defaultMarginSmall) {
            CalendarHeaderView(currentDate: $currentDate, selectedDay: $selectedDay)
            DaysOfWeekView()
            CalendarMonthlyView(currentDate: $currentDate, selectedDay: $selectedDay, eventsForDay: $eventsForDay)
            Spacer()
        }.onChange(of: currentDate) { new in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "currentDate", new.description), .view)
            onSelectedMonth(new)
        }.onChange(of: selectedDay) { new in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "selectedDay", new?.description), .view)
            onSelectedDay(new)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CalendarView(
        currentDate: .constant(Date()),
        selectedDay: .constant(Date()), 
        eventsForDay: .constant(
            [
                Date().add(days: -12): [.red, .blue, .green],
                Date().add(days: -11): [.red, .blue],
                Date().add(days: -10): [.red],
             Date(): [.red]
            ]
        ),
        onSelectedDay: { _ in },
        onSelectedMonth: { _ in }
    )
    .paddingHorizontal(SizeNames.defaultMargin)
}
#endif
