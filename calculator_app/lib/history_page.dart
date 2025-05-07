import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class HistoryPage extends StatelessWidget {
  final List<String> history;
  final List<DateTime> timestamps;

  const HistoryPage({
    super.key, 
    required this.history,
    required this.timestamps,
  });

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/calculator_history.csv');
      
      // CSV 헤더 작성
      String csvContent = '계산식,결과,날짜,시간\n';
      
      // 각 히스토리 항목을 CSV 형식으로 변환
      for (int i = 0; i < history.length; i++) {
        final timestamp = timestamps[i];
        final dateFormat = DateFormat('yyyy-MM-dd');
        final timeFormat = DateFormat('HH:mm:ss');
        
        // 계산식과 결과 분리
        final parts = history[i].split(' = ');
        final expression = parts[0];
        final result = parts[1];
        
        csvContent += '"$expression","$result","${dateFormat.format(timestamp)}","${timeFormat.format(timestamp)}"\n';
      }
      
      // 파일 저장
      await file.writeAsString(csvContent);
      
      // 파일 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '계산기 히스토리',
      );
    } catch (e) {
      debugPrint('CSV 내보내기 오류: $e');
      // 오류 발생 시 사용자에게 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV 파일 생성 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계산 히스토리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportToCSV(context),
            tooltip: 'CSV로 내보내기',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final timestamp = timestamps[history.length - 1 - index];
          final timeFormat = DateFormat('HH:mm:ss');
          final dateFormat = DateFormat('yyyy-MM-dd');
          
          // 계산식과 결과 분리
          final parts = history[history.length - 1 - index].split(' = ');
          final expression = parts[0];
          final result = parts[1];
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expression,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '= $result',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('결과가 클립보드에 복사되었습니다'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text(
                '${dateFormat.format(timestamp)} ${timeFormat.format(timestamp)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
} 