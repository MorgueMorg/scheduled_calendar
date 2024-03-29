import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:provider/provider.dart';
import 'package:scheduled_calendar/src/calendar_state/calendar_state.dart';
import 'package:scheduled_calendar/src/utils/date_models.dart';
import 'package:scheduled_calendar/src/utils/date_utils.dart';
import 'package:scheduled_calendar/src/utils/enums.dart';
import 'package:scheduled_calendar/src/utils/styles.dart';
import 'package:scheduled_calendar/src/utils/typedefs.dart';
import 'package:scheduled_calendar/src/widgets/hero_animation.dart';
import 'package:scheduled_calendar/src/widgets/month_name_view.dart';
import 'package:scheduled_calendar/src/widgets/week_view.dart';
import 'package:scheduled_calendar/src/widgets/weeks_separator.dart';

class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.month,
    this.weeksSeparator = const WeeksSeparator(),
    required this.startWeekWithSunday,
    this.minDate,
    this.maxDate,
    this.focusedDateCardBuilder,
    this.focusedDateCardAnimationCurve,
    this.focusedDateCardAnimationDuration,
    this.dayStyle = const ScheduledCalendarDayStyle(),
    this.onDayPressed,
    required this.monthNameStyle,
    this.isCalendarMode = false,
    this.daysOff = const [DateTime.saturday, DateTime.sunday],
    required this.interaction,
    required this.dayFooterBuilder,
    this.isWorkDay,
    required this.displayWeekdays,
    required this.dayFooterPadding,
    required this.firstWeekSeparator,
  });

  final Month month;
  final Widget weeksSeparator;
  final bool startWeekWithSunday;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateBuilder? focusedDateCardBuilder;
  final Duration? focusedDateCardAnimationDuration;
  final Curve? focusedDateCardAnimationCurve;
  final ScheduleCalendarMonthNameStyle monthNameStyle;
  final ScheduledCalendarDayStyle dayStyle;
  final bool isCalendarMode;
  final List<int> daysOff;
  final ValueChanged<DateTime?>? onDayPressed;
  final CalendarInteraction interaction;
  final DateBuilder? dayFooterBuilder;
  final bool Function(DateTime)? isWorkDay;
  final bool displayWeekdays;
  final double dayFooterPadding;
  final Widget firstWeekSeparator;

  @override
  Widget build(BuildContext context) {
    final weeksList = DateUtils.weeksList(month: month);
    final state = context.watch<CalendarState>();
    final focusedDate = state.focusedDate;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: monthNameStyle.centerMonthName
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            monthNameStyle.centerMonthName
                ? const SizedBox()
                : weeksList.first.length < 7
                    ? Spacer(
                        flex: 7 - weeksList.first.length,
                      )
                    : const SizedBox(),
            Flexible(
              flex: monthNameStyle.centerMonthName ? 1 : weeksList.first.length,
              child: MonthNameView(
                month,
                monthNameStyle: monthNameStyle,
              ),
            ),
          ],
        ),
        Column(
          children: [
            ...weeksList.mapIndexed((index, week) {
              return HeroAnimation(
                isHorizontalCalendar: false,
                tag: week.contains(focusedDate) ? week.toString() : week,
                child: Provider.value(
                  value: state,
                  child: WeekView(
                    week,
                    startWeekWithSunday: startWeekWithSunday,
                    interaction: interaction,
                    weeksSeparator: weeksSeparator,
                    onDayPressed: onDayPressed,
                    dayStyle: dayStyle,
                    isCalendarMode: isCalendarMode,
                    focusedDateCardBuilder: focusedDateCardBuilder,
                    selectedDateCardAnimationCurve:
                        focusedDateCardAnimationCurve,
                    selectedDateCardAnimationDuration:
                        focusedDateCardAnimationDuration,
                    isFirstWeek: index == 0,
                    isLastWeek: index == weeksList.length - 1,
                    daysOff: daysOff,
                    locale: monthNameStyle.monthNameLocale,
                    dayFooterBuilder: dayFooterBuilder,
                    isWorkDay: isWorkDay,
                    displayWeekdays: displayWeekdays,
                    dayFooterPadding: dayFooterPadding,
                    firstWeekSeparator: firstWeekSeparator,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
