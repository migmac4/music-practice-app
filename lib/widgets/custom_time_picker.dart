import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late bool isAM;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    isAM = selectedHour < 12;
  }

  void _initializeTimeFormat(BuildContext context) {
    if (!_initialized) {
      if (!MediaQuery.of(context).alwaysUse24HourFormat) {
        selectedHour = selectedHour % 12;
        if (selectedHour == 0) selectedHour = 12;
      }
      _initialized = true;
    }
  }

  String _formatHour(int hour, bool use24HourFormat) {
    if (use24HourFormat) {
      return hour.toString().padLeft(2, '0');
    } else {
      if (hour == 0) return '12';
      return hour.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    _initializeTimeFormat(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour Selector
        SizedBox(
          width: 70,
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: use24HourFormat ? 24 : 12,
              builder: (context, index) {
                final displayHour = use24HourFormat ? index : (index == 0 ? 12 : index);
                final isSelected = selectedHour == displayHour;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _formatHour(displayHour, use24HourFormat),
                      style: TextStyle(
                        fontSize: isSelected ? 24 : 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                          ? (Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Theme.of(context).primaryColor)
                          : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                if (use24HourFormat) {
                  selectedHour = index;
                } else {
                  selectedHour = index == 0 ? 12 : index;
                  final actualHour = isAM ? selectedHour % 12 : (selectedHour % 12) + 12;
                  widget.onTimeChanged(TimeOfDay(hour: actualHour, minute: selectedMinute));
                }
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            ':',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        // Minute Selector
        SizedBox(
          width: 70,
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 12,
              builder: (context, index) {
                final minute = index * 5;
                final isSelected = selectedMinute == minute;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      minute.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: isSelected ? 24 : 20,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                          ? (Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Theme.of(context).primaryColor)
                          : null,
                      ),
                    ),
                  ),
                );
              },
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedMinute = index * 5;
                if (!use24HourFormat) {
                  final actualHour = isAM ? selectedHour % 12 : (selectedHour % 12) + 12;
                  widget.onTimeChanged(TimeOfDay(hour: actualHour, minute: selectedMinute));
                } else {
                  widget.onTimeChanged(TimeOfDay(hour: selectedHour, minute: selectedMinute));
                }
              });
            },
          ),
        ),
        if (!use24HourFormat) ...[
          const SizedBox(width: 16),
          // AM/PM Selector
          GestureDetector(
            onTap: () {
              setState(() {
                isAM = !isAM;
                final actualHour = isAM ? selectedHour % 12 : (selectedHour % 12) + 12;
                widget.onTimeChanged(TimeOfDay(hour: actualHour, minute: selectedMinute));
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAM ? 'AM' : 'PM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
} 