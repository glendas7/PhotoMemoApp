class PhotoComment {
  String docId; //Firestore auto generated id
  String memoId;
  String createdBy;
  String content;
  DateTime timestamp;
  String originalPoster; //date

//key for firestore documents
  static const CONTENT = 'content';
  static const CREATED_BY = 'createdBy';
  static const TIMESTAMP = 'timestamp';
  static const PHOTOMEMO_ID = 'photo_memo_id';
  static const ORIGINAL_POSTER = 'originalPoster';

  PhotoComment({
    this.memoId,
    this.docId,
    this.createdBy,
    this.content,
    this.timestamp,
    this.originalPoster,
  });

  PhotoComment.clone(PhotoComment c) {
    this.docId = c.docId;
    this.memoId = c.memoId;
    this.createdBy = c.createdBy;
    this.content = c.content;
    this.timestamp = c.timestamp;
    this.originalPoster = c.originalPoster;
  }

  void assign(PhotoComment c) {
    this.docId = c.docId;
    this.memoId = c.memoId;
    this.createdBy = c.createdBy;
    this.content = c.content;
    this.timestamp = c.timestamp;
    this.originalPoster = c.originalPoster;
  }

//from dart to firestore document compatable
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      CREATED_BY: this.createdBy,
      PHOTOMEMO_ID: this.memoId,
      CONTENT: this.content,
      TIMESTAMP: this.timestamp,
      ORIGINAL_POSTER: this.originalPoster,
    };
  }

  static PhotoComment deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoComment(
      docId: docId,
      createdBy: doc[CREATED_BY],
      originalPoster: doc[ORIGINAL_POSTER],
      content: doc[CONTENT],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }

  static String validateContent(String value) {
    if (value == null || value.length < 2)
      return 'too short';
    else
      return null;
  }
}
