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

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seletor de Hora
        SizedBox(
          width: 70,
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 24,
              builder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: selectedHour == index ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: selectedHour == index ? 24 : 20,
                        fontWeight: selectedHour == index ? FontWeight.bold : FontWeight.normal,
                        color: selectedHour == index 
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
                selectedHour = index;
                widget.onTimeChanged(TimeOfDay(hour: selectedHour, minute: selectedMinute));
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
        // Seletor de Minutos
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
                return Container(
                  decoration: BoxDecoration(
                    color: selectedMinute == index * 5 ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (index * 5).toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: selectedMinute == index * 5 ? 24 : 20,
                        fontWeight: selectedMinute == index * 5 ? FontWeight.bold : FontWeight.normal,
                        color: selectedMinute == index * 5 
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
                widget.onTimeChanged(TimeOfDay(hour: selectedHour, minute: selectedMinute));
              });
            },
          ),
        ),
      ],
    );
  }
} 