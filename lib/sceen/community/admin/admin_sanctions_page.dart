import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

class AdminSanctionsPage extends StatefulWidget {
  const AdminSanctionsPage({super.key});

  @override
  State<AdminSanctionsPage> createState() => _AdminSanctionsPageState();
}

class _AdminSanctionsPageState extends State<AdminSanctionsPage> {
  final int _limit = 10;
  List<DocumentSnapshot> _sanctions = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMoreSanctions();
  }

  Future<void> _loadMoreSanctions() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('sanctions')
          .orderBy('create_timestamp', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _sanctions.addAll(snapshot.docs);
          _lastDocument = snapshot.docs.last;

          if (snapshot.docs.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      print("Error loading sanctions: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSanctionDetailDialog(Map<String, dynamic> data) {
    final type = data['type'] ?? 'N/A';
    final reason = data['reason'] ?? 'N/A';
    final userUID = data['user_UID'] ?? 'N/A';
    final detail = data['detail'] ?? 'ไม่มีรายละเอียดเพิ่มเติม';
    final timestamp = data['create_timestamp'] as Timestamp?;

    final dateStr = timestamp != null
        ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} เวลา ${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')} น."
        : "N/A";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.gavel, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'รายละเอียดลงโทษ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogInfoRow('ประเภท', type),
                _buildDialogInfoRow('เหตุผล', reason),
                _buildDialogInfoRow('ผู้ถูกลงโทษ', userUID),
                _buildDialogInfoRow('วันที่', dateStr),
                const SizedBox(height: 15),
                const Text(
                  'รายละเอียด:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(detail, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ประวัติการลงโทษ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: WidgetColors().applicationMainTheme(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: _sanctions.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sanctions.isEmpty
          ? const Center(child: Text("ยังไม่มีประวัติการลงโทษ"))
          : ListView.builder(
              itemCount: _sanctions.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _sanctions.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WidgetColors()
                                    .applicationMainTheme()
                                    .first,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _loadMoreSanctions,
                              child: const Text(
                                "โหลดถัดไป",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
                  );
                }

                final data = _sanctions[index].data() as Map<String, dynamic>;
                final type = data['type'] ?? 'N/A';
                final reason = data['reason'] ?? 'N/A';
                final userUID = data['user_UID'] ?? 'N/A';
                final detail = data['detail'] ?? '';
                final timestamp = data['create_timestamp'] as Timestamp?;

                final dateStr = timestamp != null
                    ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                    : "";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: InkWell(
                    onTap: () {
                      _showSanctionDetailDialog(data);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.warning, color: Colors.white),
                      ),
                      title: Text("ประเภท: $type"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("เหตุผล: $reason"),
                          if (detail.isNotEmpty)
                            Text(
                              "รายละเอียด: $detail",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          Text(
                            "ผู้ถูกลงโทษ (UID): $userUID",
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (dateStr.isNotEmpty)
                            Text(
                              "วันที่: $dateStr",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
