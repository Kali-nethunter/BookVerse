import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ReadingProgress extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onProgressChanged;

  const ReadingProgress({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onProgressChanged,
  }) : super(key: key);

  @override
  _ReadingProgressState createState() => _ReadingProgressState();
}

class _ReadingProgressState extends State<ReadingProgress> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalPages > 0 ? _currentPage / widget.totalPages : 0.0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3047),
              ),
            ),
            SizedBox(height: 12),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 20.0,
              animationDuration: 1000,
              percent: progress,
              center: Text(
                "${(_currentPage / widget.totalPages * 100).toStringAsFixed(1)}%",
                style: TextStyle(color: Colors.white),
              ),
              progressColor: Color(0xFF2D3047),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text('Page: $_currentPage / ${widget.totalPages}'),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final newPage = _currentPage + 10;
                    if (newPage <= widget.totalPages) {
                      setState(() {
                        _currentPage = newPage;
                      });
                      widget.onProgressChanged(newPage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE84855),
                  ),
                  child: Text('+10 Pages'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Slider(
              value: _currentPage.toDouble(),
              min: 0,
              max: widget.totalPages.toDouble(),
              onChanged: (value) {
                setState(() {
                  _currentPage = value.toInt();
                });
              },
              onChangeEnd: (value) {
                widget.onProgressChanged(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }
}
