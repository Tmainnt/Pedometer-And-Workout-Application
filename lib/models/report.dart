class ReportModel {
  final String id;
  final String postId;
  final String postOwnerId;
  final String reporterId;
  final String reason;
  final String detail;
  final String status;

  ReportModel({
    required this.id,
    required this.postId,
    required this.postOwnerId,
    required this.reporterId,
    required this.reason,
    required this.detail,
    required this.status,
  });

  factory ReportModel.fromDoc(doc) {
    final data = doc.data();

    return ReportModel(
      id: doc.id,
      postOwnerId: data['postOwnerId'] as String? ?? '',
      postId: data['postId'] as String? ?? '',
      reporterId: data['reporterId'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
    );
  }
}
