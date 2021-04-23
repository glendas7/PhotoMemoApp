class PhotoLike {
  String docId; //Firestore auto generated id
  String memoId;
  String likedBy;
  DateTime timestamp; //date

//key for firestore documents
  static const PHOTOMEMO_ID = 'photo_memo_id';
  static const LIKED_BY = 'liked_by';
  static const TIMESTAMP = 'timestamp';

  PhotoLike({
    this.docId,
    this.memoId,
    this.likedBy,
    this.timestamp,
  });

  PhotoLike.clone(PhotoLike l) {
    this.docId = l.docId;
    this.memoId = l.memoId;
    this.likedBy = l.likedBy;
    this.timestamp = l.timestamp;
  }

  void assign(PhotoLike l) {
    this.docId = l.docId;
    this.memoId = l.memoId;
    this.likedBy = l.likedBy;
    this.timestamp = l.timestamp;
  }

//from dart to firestore document compatable
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      LIKED_BY: this.likedBy,
      PHOTOMEMO_ID: this.memoId,
      TIMESTAMP: this.timestamp,
    };
  }

  static PhotoLike deserialize(Map<String, dynamic> doc, String docId) {
    return PhotoLike(
      docId: docId,
      memoId: doc[PHOTOMEMO_ID],
      likedBy: doc[LIKED_BY],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }
}
