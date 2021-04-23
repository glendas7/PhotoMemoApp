class Profile {
  String docId; //Firestore auto generated id
  String email;
  DateTime signUpDate;
  String description;
  String name;
  DateTime lastVisitedShared;
  DateTime lastVisitedHome;

//key for firestore documents
  static const DESCRIPTION = 'description';
  static const USER_EMAIL = 'user_email';
  static const SIGNUP_DATE = 'signup_date';
  static const NAME = 'name';
  static const LAST_SHAREDPAGE_VISIT = 'sharedpage_visit_date';
  static const LAST_HOME_VISIT = 'home_visit_date';

  Profile({
    this.docId,
    this.email,
    this.signUpDate,
    this.description,
    this.name,
    this.lastVisitedShared,
    this.lastVisitedHome,
  });

  Profile.clone(Profile p) {
    this.docId = p.docId;
    this.email = p.email;
    this.signUpDate = p.signUpDate;
    this.description = p.description;
    this.name = p.name;
    this.lastVisitedShared = p.lastVisitedShared;
    this.lastVisitedHome = p.lastVisitedHome;
  }

  void assign(Profile p) {
    this.docId = p.docId;
    this.email = p.email;
    this.signUpDate = p.signUpDate;
    this.description = p.description;
    this.name = p.name;
    this.lastVisitedShared = p.lastVisitedShared;
    this.lastVisitedHome = p.lastVisitedHome;
  }

//from dart to firestore document compatable
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      DESCRIPTION: this.description,
      SIGNUP_DATE: this.signUpDate,
      NAME: this.name,
      USER_EMAIL: this.email,
      LAST_SHAREDPAGE_VISIT: this.lastVisitedShared,
      LAST_HOME_VISIT: this.lastVisitedHome,
    };
  }

  static Profile deserialize(Map<String, dynamic> doc, String docId) {
    return Profile(
      docId: docId,
      email: doc[USER_EMAIL],
      name: doc[NAME],
      description: doc[DESCRIPTION],
      lastVisitedShared: doc[LAST_SHAREDPAGE_VISIT] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[LAST_SHAREDPAGE_VISIT].millisecondsSinceEpoch),
      lastVisitedHome: doc[LAST_HOME_VISIT] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[LAST_HOME_VISIT].millisecondsSinceEpoch),
      signUpDate: doc[SIGNUP_DATE] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[SIGNUP_DATE].millisecondsSinceEpoch),
    );
  }
}
