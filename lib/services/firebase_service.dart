import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseVotingService {
  static FirebaseDatabase? _database;
  static DatabaseReference? _votingDataRef;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Initialize Firebase with proper options
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: "AIzaSyATIGBCcwYegWF3-xkjEMieAyGKuDm8EjU",
            authDomain: "scom-voting-system.firebaseapp.com",
            databaseURL: "https://scom-voting-system-default-rtdb.firebaseio.com",
            projectId: "scom-voting-system",
            storageBucket: "scom-voting-system.firebasestorage.app",
            messagingSenderId: "146506278502",
            appId: "1:146506278502:android:51f04abbf0c206375eafa7"
          ),
        );
      }
      
      _database = FirebaseDatabase.instance;
      _votingDataRef = _database!.ref('votingData');
      
      // Enable offline persistence for better reliability
      try {
        _database!.setPersistenceEnabled(true);
        _database!.setPersistenceCacheSizeBytes(10000000); // 10MB cache
      } catch (e) {
        print('Offline persistence already enabled or not available: $e');
      }
      
      print('Firebase initialized successfully');
    } catch (e) {
      print('Failed to initialize Firebase: $e');
      rethrow;
    }
  }
  
  // Get current data from Firebase
  static Future<Map<String, dynamic>> getCurrentData() async {
    try {
      if (_votingDataRef == null) {
        throw Exception('Firebase not initialized');
      }
      
      DataSnapshot snapshot = await _votingDataRef!.get();
      if (snapshot.exists) {
        final data = snapshot.value;
        Map<String, dynamic> dataMap = {};
        
        if (data != null && data is Map) {
          // Convert each key to string and value to dynamic
          data.forEach((key, value) {
            dataMap[key.toString()] = value;
          });
        }
        
        return dataMap;
      } else {
        return _getInitialData();
      }
    } catch (e) {
      print('Failed to get current data: $e');
      return _getInitialData();
    }
  }
  
  // Initialize data from Firebase
  static Future<Map<String, dynamic>> initializeData() async {
    try {
      if (_votingDataRef == null) {
        await initialize();
      }
      
      // First, create the initial database structure if it doesn't exist
      await _initializeDatabaseStructure();
      
      return await getCurrentData();
    } catch (e) {
      print('Failed to initialize data from Firebase: $e');
      return _getInitialData();
    }
  }
  
  // Initialize database structure
  static Future<void> _initializeDatabaseStructure() async {
    try {
      final snapshot = await _votingDataRef!.get();
      if (!snapshot.exists) {
        // Create initial structure
        final initialData = _getInitialData();
        await _votingDataRef!.set(initialData);
        print('Initial database structure created in Firebase');
      }
    } catch (e) {
      print('Failed to initialize database structure: $e');
    }
  }
  
  // Save nominations to Firebase
  static Future<bool> saveNominations(Map<String, Map<String, int>> nominations) async {
    try {
      if (_votingDataRef == null) {
        throw Exception('Firebase not initialized');
      }
      
      await _votingDataRef!.child('nominations').set(nominations);
      print('Nominations saved successfully to Firebase');
      return true;
    } catch (e) {
      print('Failed to save nominations: $e');
      return false;
    }
  }
  
  // Save votes to Firebase
  static Future<bool> saveVotes(Map<String, Map<String, int>> votes) async {
    try {
      if (_votingDataRef == null) {
        throw Exception('Firebase not initialized');
      }
      
      await _votingDataRef!.child('voteResults').set(votes);
      print('Votes saved successfully to Firebase');
      return true;
    } catch (e) {
      print('Failed to save votes: $e');
      return false;
    }
  }
  
  // Save admin candidates to Firebase
  static Future<bool> saveAdminCandidates(Map<String, List<String>> candidates) async {
    try {
      if (_votingDataRef == null) {
        throw Exception('Firebase not initialized');
      }
      
      await _votingDataRef!.child('adminSubmittedCandidates').set(candidates);
      print('Admin candidates saved successfully to Firebase');
      return true;
    } catch (e) {
      print('Failed to save admin candidates: $e');
      return false;
    }
  }
  
  // Mark voter as nominated in Firebase
  static Future<bool> markVoterAsNominated(String voterNumber) async {
    try {
      if (_votingDataRef == null) {
        throw Exception('Firebase not initialized');
      }
      
      await _votingDataRef!.child('votersWhoNominated').child(voterNumber).set(true);
      print('Voter marked as nominated: $voterNumber');
      return true;
    } catch (e) {
      print('Failed to mark voter as nominated: $e');
      return false;
    }
  }
  
  // Mark voter as voted in Firebase
  static Future<bool> markVoterAsVoted(String voterNumber) async {
    try {
      if (_votingDataRef == null) {
        throw Exception('Firebase not initialized');
      }
      
      await _votingDataRef!.child('votersWhoVoted').child(voterNumber).set(true);
      print('Voter marked as voted: $voterNumber');
      return true;
    } catch (e) {
      print('Failed to mark voter as voted: $e');
      return false;
    }
  }
  
  // Listen to real-time updates
  static StreamSubscription<DatabaseEvent>? _dataSubscription;
  
  static void startRealtimeUpdates(Function(Map<String, dynamic>) onData) {
    if (_votingDataRef == null) {
      print('Firebase not initialized, cannot start realtime updates');
      return;
    }
    
    _dataSubscription = _votingDataRef!.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value;
        Map<String, dynamic> dataMap = {};
        
        if (data != null && data is Map) {
          // Convert each key to string and value to dynamic
          data.forEach((key, value) {
            dataMap[key.toString()] = value;
          });
        }
        
        onData(dataMap);
        print('Real-time data update received');
      }
    });
    
    print('Real-time updates started');
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
        'v54812', 'v28379', 'v91546', 'v06723', 'v73158', 'v49207', 'v86495', 'v31861', 'v57924', 'v20673',
        'v84319', 'v07586', 'v62147', 'v39852', 'v91308', 'v26475', 'v78031', 'v45296', 'v13764', 'v68523',
        'v04187', 'v59342', 'v21879', 'v74615', 'v38264', 'v91537', 'v06982', 'v52748', 'v81306', 'v37491',
        'v64253', 'v19876', 'v80534', 'v27169', 'v53892', 'v06325', 'v71984', 'v45617', 'v98273', 'v32148',
        'v67509', 'v04286', 'v51873', 'v29741', 'v86315', 'v13482', 'v57969', 'v40527', 'v92184', 'v26853',
        'v73416', 'v08392', 'v61748', 'v38573', 'v94207', 'v25964', 'v70138', 'v47685', 'v81329', 'v15876',
        'v62943', 'v09518', 'v57284', 'v31769', 'v84532', 'v06397', 'v72854', 'v49123', 'v96478', 'v23615',
        'v68792', 'v15473', 'v82306', 'v47961', 'v03248', 'v71593', 'v46827', 'v98164', 'v30785', 'v65219',
        'v12873', 'v74356', 'v09284', 'v61739', 'v38472', 'v95128', 'v26395', 'v70846', 'v47513', 'v83972',
        'v01658', 'v64293', 'v28571', 'v91746', 'v06324', 'v73859', 'v49518', 'v86273', 'v32197', 'v57486',
        'v20953', 'v74218', 'v06584', 'v53147', 'v29873', 'v81492', 'v47368', 'v92531', 'v18675', 'v64029',
        'v31784', 'v75261', 'v09846', 'v52379', 'v28615', 'v74192', 'v01873', 'v63548', 'v49217', 'v86754',
        'v12483', 'v73926', 'v05794', 'v61873', 'v38542', 'v94217', 'v26984', 'v70351', 'v47628', 'v81593',
        'v03267', 'v64894', 'v21573', 'v78216', 'v45982', 'v92745', 'v06831', 'v51378', 'v84625', 'v37192',
        'v62457', 'v09328', 'v75186', 'v42873', 'v98542', 'v31769', 'v68324', 'v05297', 'v72648', 'v49315',
        'v86472', 'v13985', 'v60253', 'v27816', 'v74539', 'v01684', 'v58327', 'v31296', 'v67973', 'v44852',
        'v91528', 'v06395', 'v73264', 'v48931', 'v82675', 'v15492', 'v67348', 'v02873', 'v59516', 'v34289',
        'v71854', 'v08327', 'v64293', 'v31768', 'v98542', 'v25973', 'v70418', 'v47685', 'v93152', 'v16897',
        'v62374', 'v09531', 'v74286', 'v41873', 'v98527', 'v35294', 'v62148', 'v07873', 'v54392', 'v28657',
        'v71428', 'v06395', 'v84273', 'v51946', 'v28713', 'v73482', 'v09567', 'v62834', 'v47391', 'v81652',
        'v03927', 'v68494', 'v25173', 'v71846', 'v48392', 'v93257', 'v16784', 'v60523', 'v37896', 'v84173',
        'v01268', 'v67935', 'v42482', 'v98757', 'v35314', 'v72689', 'v09546', 'v64213', 'v31878', 'v78542',
        'v05397', 'v72684', 'v49351', 'v16827', 'v83592', 'v04273', 'v61748', 'v38495', 'v95162', 'v27843',
        'v64218', 'v01973', 'v78492', 'v45367', 'v92834', 'v16795', 'v60248', 'v37913', 'v84672', 'v51397',
        'v28464', 'v75193', 'v01876', 'v64352', 'v31729', 'v98476', 'v45923', 'v71268', 'v08594', 'v63147',
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
