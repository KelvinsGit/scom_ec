import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

class FirestoreService {
  static FirebaseFirestore? _firestore;
  static CollectionReference? _votingCollection;
  
  // Initialize Firestore
  static Future<void> initialize() async {
    try {
      _firestore = FirebaseFirestore.instance;
      _votingCollection = _firestore!.collection('votingData');
      
      print('Firestore initialized successfully');
    } catch (e) {
      print('Failed to initialize Firestore: $e');
      rethrow;
    }
  }
  
  // Get current data from Firestore
  static Future<Map<String, dynamic>> getCurrentData() async {
    try {
      if (_votingCollection == null) {
        throw Exception('Firestore not initialized');
      }
      
      DocumentSnapshot snapshot = await _votingCollection!.doc('mainData').get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data;
      } else {
        return _getInitialData();
      }
    } catch (e) {
      print('Failed to get current data: $e');
      return _getInitialData();
    }
  }
  
  // Initialize data from Firestore
  static Future<Map<String, dynamic>> initializeData() async {
    try {
      if (_votingCollection == null) {
        await initialize();
      }
      
      // First, create initial database structure if it doesn't exist
      await _initializeDatabaseStructure();
      
      return await getCurrentData();
    } catch (e) {
      print('Failed to initialize data from Firestore: $e');
      return _getInitialData();
    }
  }
  
  // Initialize database structure
  static Future<void> _initializeDatabaseStructure() async {
    try {
      DocumentSnapshot snapshot = await _votingCollection!.doc('mainData').get();
      if (!snapshot.exists) {
        // Create initial structure
        final initialData = _getInitialData();
        await _votingCollection!.doc('mainData').set(initialData);
        print('Initial database structure created in Firestore');
      }
    } catch (e) {
      print('Failed to initialize database structure: $e');
    }
  }
  
  // Save nominations to Firestore
  static Future<bool> saveNominations(Map<String, Map<String, int>> nominations) async {
    try {
      if (_votingCollection == null) {
        throw Exception('Firestore not initialized');
      }
      
      await _votingCollection!.doc('mainData').update({'nominations': nominations});
      print('Nominations saved successfully to Firestore');
      return true;
    } catch (e) {
      print('Failed to save nominations: $e');
      return false;
    }
  }
  
  // Save votes to Firestore
  static Future<bool> saveVotes(Map<String, Map<String, int>> votes) async {
    try {
      if (_votingCollection == null) {
        throw Exception('Firestore not initialized');
      }
      
      await _votingCollection!.doc('mainData').update({'voteResults': votes});
      print('Votes saved successfully to Firestore');
      return true;
    } catch (e) {
      print('Failed to save votes: $e');
      return false;
    }
  }
  
  // Save admin candidates to Firestore
  static Future<bool> saveAdminCandidates(Map<String, List<String>> candidates) async {
    try {
      if (_votingCollection == null) {
        throw Exception('Firestore not initialized');
      }
      
      await _votingCollection!.doc('mainData').update({'adminSubmittedCandidates': candidates});
      print('Admin candidates saved successfully to Firestore');
      return true;
    } catch (e) {
      print('Failed to save admin candidates: $e');
      return false;
    }
  }
  
  // Mark voter as voted in Firestore
  static Future<bool> markVoterAsVoted(String voterNumber) async {
    try {
      if (_votingCollection == null) {
        throw Exception('Firestore not initialized');
      }
      
      await _votingCollection!.doc('mainData').update({
        'votersWhoVoted.$voterNumber': true
      });
      print('Voter marked as voted: $voterNumber');
      return true;
    } catch (e) {
      print('Failed to mark voter as voted: $e');
      return false;
    }
  }
  
  // Mark voter as nominated in Firestore
  static Future<bool> markVoterAsNominated(String voterNumber) async {
    try {
      if (_votingCollection == null) {
        throw Exception('Firestore not initialized');
      }
      
      await _votingCollection!.doc('mainData').update({
        'votersWhoNominated.$voterNumber': true
      });
      print('Voter marked as nominated: $voterNumber');
      return true;
    } catch (e) {
      print('Failed to mark voter as nominated: $e');
      return false;
    }
  }
  
  // Listen to real-time updates
  static StreamSubscription<DocumentSnapshot>? _dataSubscription;
  
  static void startRealtimeUpdates(Function(Map<String, dynamic>) onData) {
    if (_votingCollection == null) {
      print('Firestore not initialized, cannot start realtime updates');
      return;
    }
    
    _dataSubscription = _votingCollection!.doc('mainData').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        onData(data);
        print('Real-time data update received from Firestore');
      }
    });
    
    print('Real-time updates started from Firestore');
  }
  
  static void stopRealtimeUpdates() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
    print('Real-time updates stopped');
  }
  
  // Get initial data structure
  static Map<String, dynamic> _getInitialData() {
    return {
      'validVoterNumbers': [
        'v10101', 'v18345', 'v92674', 'v05892', 'v61783', 'v34921', 'v87564', 'v29318', 'v50647',
        'v71829', 'v04573', 'v68214', 'v39756', 'v82103', 'v16489', 'v73592', 'v40867', 'v97235', 'v25148',
        'v61974', 'v08326', 'v54791', 'v31268', 'v79504', 'v13857', 'v46382', 'v92176', 'v27493', 'v65018',
        'v38642', 'v81975', 'v07431', 'v52386', 'v19724', 'v64093', 'v28517', 'v73149', 'v46802', 'v90538',
        'v15276', 'v68794', 'v02341', 'v57869', 'v31407', 'v84253', 'v19685', 'v72916', 'v45372', 'v08194',
        'v63728', 'v26415', 'v79583', 'v04267', 'v51839', 'v87306', 'v32984', 'v60152', 'v17693', 'v94527',
        'v38861', 'v05329', 'v71648', 'v29473', 'v86715', 'v13284', 'v58097', 'v42536', 'v90168', 'v24751',
        'v61309', 'v07842', 'v53976', 'v28513', 'v76428', 'v19705', 'v83267', 'v45093', 'v62184', 'v07635',
        'v94827', 'v36154', 'v70293', 'v18576', 'v42938', 'v56321', 'v80765', 'v12489', 'v37602', 'v61538',
        'v25947', 'v81306', 'v47892', 'v63574', 'v09128', 'v54267', 'v31895', 'v76043', 'v29581', 'v84602',
        'v17359', 'v52084', 'v96731', 'v40826', 'v71593', 'v04972', 'v68135', 'v23708', 'v59461', 'v82647',
        'v35192', 'v07463', 'v61807', 'v28539', 'v74316', 'v49058', 'v83275', 'v16904', 'v52731', 'v78692',
        'v34518', 'v60247', 'v91856', 'v07392', 'v46185', 'v72803', 'v19574', 'v53029', 'v87641', 'v24968',
        'v61395', 'v08742', 'v52918', 'v37406', 'v84273', 'v19564', 'v72839', 'v46512', 'v90387', 'v25106',
        'v67843', 'v03579', 'v51268', 'v89427', 'v36105', 'v72984', 'v48631', 'v90576', 'v24319', 'v61852',
        'v83705', 'v15492', 'v47638', 'v60921', 'v28574', 'v71396', 'v44058', 'v86731', 'v29504', 'v61847',
        'v83295', 'v07643', 'v51928', 'v38467', 'v65102', 'v97835', 'v24619', 'v58307', 'v71294', 'v43568',
        'v16923', 'v58074', 'v32791', 'v64538', 'v90215', 'v27863', 'v51409', 'v83742', 'v19675', 'v45038',
        'v72361', 'v08954', 'v61237', 'v48509', 'v83176', 'v25493', 'v60728', 'v94315', 'v37682', 'v52947',
        'v81406', 'v26973', 'v53528', 'v78291', 'v41675', 'v60394', 'v92857', 'v37146', 'v58523', 'v74208',
        'v19673', 'v52418', 'v78935', 'v04267', 'v61594', 'v87321', 'v32856', 'v70143', 'v45678', 'v92301',
        'v38765', 'v15432', 'v62109', 'v97876', 'v34543', 'v81210', 'v58967', 'v23434', 'v67101', 'v44878',
        'v91545', 'v38212', 'v64979', 'v02636', 'v71393', 'v48860', 'v82527', 'v19294', 'v56171', 'v73448',
        'v30715', 'v68482', 'v95149', 'v42816', 'v78573', 'v05240', 'v61907', 'v28674', 'v54391', 'v81068',
        'v27735', 'v64402', 'v91969', 'v38636', 'v65313', 'v02880', 'v79547', 'v46214', 'v82981', 'v19658',
        'v54325', 'v81092', 'v47769', 'v63436', 'v90113', 'v26880', 'v53547', 'v80214', 'v16981', 'v42658',
        'v79335', 'v06002', 'v72769', 'v49436', 'v86113', 'v52880', 'v79547', 'v26214', 'v42981', 'v69658',
        'v36325', 'v83092', 'v59769', 'v26436', 'v53113', 'v70880', 'v97547', 'v64214', 'v31981', 'v58658',
        'v25335', 'v62002', 'v98769', 'v65436', 'v92113', 'v48880', 'v75547', 'v42214', 'v78981', 'v15658',
        'v42335', 'v79002', 'v56769', 'v23436', 'v60113', 'v87880', 'v14547', 'v81214', 'v37981', 'v54658',
        'v18335', 'v65002', 'v32769', 'v09436', 'v46113', 'v73880', 'v00547', 'v67214', 'v43981', 'v70658',
        'v54335', 'v81002', 'v57769', 'v24436', 'v31113', 'v58880', 'v85547', 'v52214', 'v78981', 'v45658'
      ],
      'votersWhoVoted': {},
      'votersWhoNominated': {},
      'nominations': {},
      'voteResults': {},
      'adminSubmittedCandidates': {
        'Chairperson': [],
        'Secretary': [],
        'Treasurer': [],
        'Prayer Director': [],
        'Publicity Director': [],
        'Fundraising Director': [],
        'Welfare Director': [],
        'Activities Director': [],
        'Equipments Director': [],
      }
    };
  }
}
