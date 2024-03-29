import 'dart:io';
import 'package:collection/collection.dart';
import 'package:example/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class PerformerCard extends StatefulWidget {
  final DateTime date;
  final List<Period> initialPeriods;
  final PerformerCardStyle style;
  final ValueChanged<List<Period>> onPerformerCardButtonPressed;
  final String? locale;
  const PerformerCard(
    this.date, {
    super.key,
    required this.initialPeriods,
    this.style = const PerformerCardStyle(),
    required this.onPerformerCardButtonPressed,
    this.locale,
  });

  @override
  State<PerformerCard> createState() => _PerformerCardState();
}

class _PerformerCardState extends State<PerformerCard> {
  late List<Period> periods = widget.initialPeriods;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale ?? Platform.localeName;
    var date = DateFormat('EEEE, d MMMM', locale).format(widget.date);
    date = date = date.replaceRange(
      0,
      1,
      date.substring(0, 1).toUpperCase(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      decoration: widget.style.cardDecoration,
      child: Column(
        children: [
          Text(
            date,
            style: widget.style.dateTextStyle,
          ),
          Text(
            widget.initialPeriods.isEmpty
                ? widget.style.emptyInstructionText
                : widget.style.instructionText,
            style: widget.style.instructionTextStyle,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Column(
              children: [
                ...widget.initialPeriods
                    .mapIndexed(
                      (index, period) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: _PeriodRow(
                          initialPeriod: period,
                          index: index,
                          onPeriodPicked: (Period period) =>
                              setState(() => periods[index] = period),
                          onPeriodDelete: (Period preiod) =>
                              setState(() => periods.removeAt(index)),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(
              () => periods.add(Period(DateTime.now(), DateTime.now())),
            ),
            style: widget.style.addButtonStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.style.addButtonIcon,
                const SizedBox(width: 8),
                Text(
                  widget.style.addButtonText,
                  style: widget.style.addButtonTextStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: widget.style.requestButtonStyle,
            onPressed: () => widget.onPerformerCardButtonPressed(periods),
            child: Text(
              widget.style.requestButtonText,
              style: widget.style.requestButtonTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatefulWidget {
  final Period initialPeriod;
  final int index;
  final void Function(Period period) onPeriodPicked;
  final void Function(Period preiod) onPeriodDelete;
  const _PeriodRow({
    required this.initialPeriod,
    required this.index,
    required this.onPeriodPicked,
    required this.onPeriodDelete,
  });

  @override
  State<_PeriodRow> createState() => _PeriodRowState();
}

class _PeriodRowState extends State<_PeriodRow> {
  late Period period = widget.initialPeriod;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 23,
            child: Center(
              child: Text(
                (widget.index + 1).toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5C5B5F),
                  height: 11 / 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          _TimeWidget(
            time: period.startTime,
            onTap: () => showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(period.startTime),
            ).then(
              (value) => setState(
                () {
                  period.startTime = period.startTime
                      .copyWith(hour: value?.hour, minute: value?.minute);
                  if (period.startTime.isAfter(period.endTime)) {
                    period.endTime = period.startTime;
                  }
                  widget.onPeriodPicked(period);
                },
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 10,
            height: 1,
            color: const Color(0xFF5C5B5F),
          ),
          const SizedBox(width: 5),
          _TimeWidget(
            time: period.endTime,
            onTap: () => showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(period.endTime),
            ).then(
              (value) => setState(
                () {
                  period.endTime = period.endTime
                      .copyWith(hour: value?.hour, minute: value?.minute);
                  if (period.endTime.isBefore(period.startTime)) {
                    period.startTime = period.endTime;
                  }
                  widget.onPeriodPicked(period);
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => widget.onPeriodDelete(period),
            child: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFF5454),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeWidget extends StatelessWidget {
  final DateTime time;
  final VoidCallback onTap;
  const _TimeWidget({
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13.5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(7)),
          color: Color(0xFF131414),
        ),
        child: Text(
          DateFormat('Hm').format(time),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 11 / 18,
          ),
        ),
      ),
    );
  }
}

class Period {
  DateTime startTime;
  DateTime endTime;
  Period(
    this.startTime,
    this.endTime,
  );
}
