class ReportModel {
  final String id;
  final String postId;
  final String postOwnerId;
  final String reportedUID;
  final String reason;
  final String detail;
  final String status;
  final String reportedName;
  final String commentID;
  final String commentText;

  ReportModel({
    required this.id,
    required this.postId,
    required this.postOwnerId,
    required this.reportedUID,
    required this.reason,
    required this.detail,
    required this.status,
    required this.commentID,
    required this.reportedName,
    required this.commentText,
  });

  factory ReportModel.fromDoc(doc) {
    final data = doc.data();

    return ReportModel(
      id: doc.id,
      postOwnerId: data['postOwnerId'] as String? ?? '',
      postId: data['postId'] as String? ?? '',
      reportedUID: data['reported_uid'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      commentID: data['commentId'] as String? ?? '',
      commentText: data['commentText'] as String? ?? '',
      reportedName: data['reported_name'] as String? ?? '',
    );
  }
}
