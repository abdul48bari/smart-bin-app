import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bin_sub.dart';
import '../models/alert.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BinSub>> getSubBins(String binId) {
    return _db
        .collection('bins')
        .doc(binId)
        .collection('subBins')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BinSub.fromFirestore(doc.id, doc.data()))
            .toList());


  
  }
  Stream<List<AlertModel>> getActiveAlerts(String binId) {
  return _db
      .collection('bins')
      .doc(binId)
      .collection('alerts')
      .where('resolved', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) =>
              AlertModel.fromFirestore(doc.id, doc.data()))
          .toList());
}

}
