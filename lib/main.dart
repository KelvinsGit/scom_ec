import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await VotingData.initializeVoterNumbers();
  
  // Initialize Firestore after Firebase is ready
  await FirestoreService.initialize();
  
  runApp(const VotingApp());
}

// Global data storage
class VotingData {
  static const String adminNumber = 'admin001';
  static Set<String> validVoterNumbers = {};
  static Set<String> votersWhoVoted = {};
  static Set<String> votersWhoNominated = {};
  static Map<String, Map<String, int>> nominations = {};
  static Map<String, Map<String, int>> voteResults = {};
  static Map<String, List<String>> adminSubmittedCandidates = {};
  
  // Initialize data from Firestore
  static Future<void> initializeVoterNumbers() async {
    if (validVoterNumbers.isEmpty) {
      try {
        // Try Firestore first with timeout
        final data = await FirestoreService.initializeData().timeout(
          const Duration(seconds: 10),
          onTimeout: () => _getInitialData(),
        );
        
        // Load data from Firestore
        validVoterNumbers = Set<String>.from(data['validVoterNumbers'] ?? []);
        
        // Convert voters who voted from Map to Set
        final votersWhoVotedData = data['votersWhoVoted'] as Map<String, dynamic>? ?? {};
        votersWhoVoted = votersWhoVotedData.keys.toSet();
        
        // Convert voters who nominated from Map to Set
        final votersWhoNominatedData = data['votersWhoNominated'] as Map<String, dynamic>? ?? {};
        votersWhoNominated = votersWhoNominatedData.keys.toSet();
        
        // Convert nominations data
        final nominationsData = data['nominations'] as Map<String, dynamic>? ?? {};
        nominations.clear();
        nominationsData.forEach((position, nominees) {
          final nomineeMap = Map<String, int>.from(nominees as Map);
          nominations[position] = nomineeMap;
        });
        
        // Convert vote results data
        final voteResultsData = data['voteResults'] as Map<String, dynamic>? ?? {};
        voteResults.clear();
        voteResultsData.forEach((position, results) {
          final resultMap = Map<String, int>.from(results as Map);
          voteResults[position] = resultMap;
        });
        
        // Convert admin candidates data
        final candidatesData = data['adminSubmittedCandidates'] as Map<String, dynamic>? ?? {};
        adminSubmittedCandidates.clear();
        candidatesData.forEach((position, candidates) {
          final candidateList = List<String>.from(candidates as List);
          adminSubmittedCandidates[position] = candidateList;
        });
        
        // Start real-time updates for instant synchronization
        _startRealtimeSync();
        
        print('Data loaded successfully from Firestore');
      } catch (e) {
        print('Failed to load from Firestore, using fallback: $e');
        _initializeFallbackData();
      }
    }
  }
  
  // Start real-time synchronization for instant multi-device sync
  static void _startRealtimeSync() {
    FirestoreService.startRealtimeUpdates((data) {
      // Update local data when Firestore changes
      validVoterNumbers = Set<String>.from(data['validVoterNumbers'] ?? []);
      
      final votersWhoVotedData = data['votersWhoVoted'] as Map<String, dynamic>? ?? {};
      votersWhoVoted = votersWhoVotedData.keys.toSet();
      
      final votersWhoNominatedData = data['votersWhoNominated'] as Map<String, dynamic>? ?? {};
      votersWhoNominated = votersWhoNominatedData.keys.toSet();
      
      final nominationsData = data['nominations'] as Map<String, dynamic>? ?? {};
      nominations.clear();
      nominationsData.forEach((position, nominees) {
        final nomineeMap = Map<String, int>.from(nominees as Map);
        nominations[position] = nomineeMap;
      });
      
      final voteResultsData = data['voteResults'] as Map<String, dynamic>? ?? {};
      voteResults.clear();
      voteResultsData.forEach((position, results) {
        final resultMap = Map<String, int>.from(results as Map);
        voteResults[position] = resultMap;
      });
      
      final candidatesData = data['adminSubmittedCandidates'] as Map<String, dynamic>? ?? {};
      adminSubmittedCandidates.clear();
      candidatesData.forEach((position, candidates) {
        final candidateList = List<String>.from(candidates as List);
        adminSubmittedCandidates[position] = candidateList;
      });
      
      print('Real-time data synchronized across all devices');
    });
  }
  
  // Fallback initialization
  static void _initializeFallbackData() {
    // Random unpredictable voter IDs
    validVoterNumbers.addAll({
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
      'v29873', 'v74516', 'v01284', 'v68357', 'v42692', 'v97543', 'v34878', 'v61735', 'v08492', 'v53967',
      'v27684', 'v74351', 'v01896', 'v68543', 'v43278', 'v91735', 'v26492', 'v73168', 'v08625', 'v65394',
      'v32871', 'v78546', 'v05293', 'v61782', 'v48459', 'v93126', 'v26873', 'v70548', 'v47215', 'v83992',
      'v01657', 'v68324', 'v45297', 'v91876', 'v37543', 'v84298', 'v01975', 'v63642', 'v49387', 'v76254',
      'v02893', 'v68574', 'v45231', 'v91786', 'v38463', 'v75142', 'v02897', 'v64358', 'v31725', 'v78492',
      'v05367', 'v72634', 'v49381', 'v16858', 'v83527', 'v04294', 'v61773', 'v38492', 'v95167', 'v27844',
      'v64313', 'v01896', 'v78563', 'v45238', 'v91707', 'v26874', 'v73549', 'v08296', 'v64973', 'w32458'
    });
    
    // Initialize adminSubmittedCandidates with all positions
    adminSubmittedCandidates.addAll({
      'Chairperson': [],
      'Secretary': [],
      'Treasurer': [],
      'Prayer Director': [],
      'Publicity Director': [],
      'Fundraising Director': [],
      'Welfare Director': [],
      'Activities Director': [],
      'Equipments Director': [],
    });
    
    // Initialize vote results
    final positions = [
      'Chairperson', 'Secretary', 'Treasurer', 'Prayer Director',
      'Publicity Director', 'Fundraising Director', 'Welfare Director',
      'Activities Director', 'Equipments Director'
    ];
      
    for (final position in positions) {
      voteResults[position] = {};
    }
  }
  
  // Save nominations to Firestore for real-time sync
  static Future<bool> saveNominationsToServer() async {
    return await FirestoreService.saveNominations(nominations);
  }
  
  // Save votes to Firestore for real-time sync
  static Future<bool> saveVotesToServer() async {
    return await FirestoreService.saveVotes(voteResults);
  }
  
  // Save admin candidates to Firestore for real-time sync
  static Future<bool> saveCandidatesToServer() async {
    return await FirestoreService.saveAdminCandidates(adminSubmittedCandidates);
  }
  
  // Mark voter as nominated on Firestore for real-time sync
  static Future<bool> markVoterAsNominatedOnServer(String voterNumber) async {
    return await FirestoreService.markVoterAsNominated(voterNumber);
  }
  
  // Mark voter as voted on Firestore for real-time sync
  static Future<bool> markVoterAsVotedOnServer(String voterNumber) async {
    return await FirestoreService.markVoterAsVoted(voterNumber);
  }
  
  // Refresh data from Firestore for real-time sync
  static Future<void> refreshData() async {
    try {
      final data = await FirestoreService.getCurrentData();
      
      // Update local data with Firestore data
      final votersWhoVotedData = data['votersWhoVoted'] as Map<String, dynamic>? ?? {};
      votersWhoVoted = votersWhoVotedData.keys.toSet();
      
      final votersWhoNominatedData = data['votersWhoNominated'] as Map<String, dynamic>? ?? {};
      votersWhoNominated = votersWhoNominatedData.keys.toSet();
      
      // Update nominations
      final nominationsData = data['nominations'] as Map<String, dynamic>? ?? {};
      nominations.clear();
      nominationsData.forEach((position, nominees) {
        final nomineeMap = Map<String, int>.from(nominees as Map);
        nominations[position] = nomineeMap;
      });
      
      // Update vote results
      final voteResultsData = data['voteResults'] as Map<String, dynamic>? ?? {};
      voteResults.clear();
      voteResultsData.forEach((position, results) {
        final resultMap = Map<String, int>.from(results as Map);
        voteResults[position] = resultMap;
      });
      
      // Update admin candidates
      final candidatesData = data['adminSubmittedCandidates'] as Map<String, dynamic>? ?? {};
      adminSubmittedCandidates.clear();
      candidatesData.forEach((position, candidates) {
        final candidateList = List<String>.from(candidates as List);
        adminSubmittedCandidates[position] = candidateList;
      });
      
      print('Data refreshed from server');
    } catch (e) {
      print('Failed to refresh data: $e');
    }
  }
  
  // Get initial data structure for fallback
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

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCOM 2026 Voting',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.red),
      ),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInPage(),
        '/': (context) => const HomePage(),
        '/nominate': (context) => const NominatePage(),
        '/vote': (context) => const VotePage(),
        '/admin': (context) => const AdminPage(),
      },
    );
  }
}

/* ---------------- SIGN IN PAGE ---------------- */
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _voterNumberController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    VotingData.initializeVoterNumbers();
  }
  
  String generateRandomVoterNumber() {
    final random = Random();
    final validNumbers = VotingData.validVoterNumbers.toList();
    return validNumbers[random.nextInt(validNumbers.length)];
  }

  void _signIn() {
    final voterNumber = _voterNumberController.text.trim();
    
    if (voterNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a voter number')),
      );
      return;
    }
    
    if (voterNumber == VotingData.adminNumber) {
      Navigator.pushReplacementNamed(context, '/admin');
      return;
    }
    
    if (!VotingData.validVoterNumbers.contains(voterNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid voter number')),
      );
      return;
    }
    
    if (VotingData.votersWhoVoted.contains(voterNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This voter has already voted')),
      );
      return;
    }
    
    Navigator.pushReplacementNamed(context, '/', arguments: voterNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.red.shade400, Colors.red.shade700],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.how_to_vote,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MUBAS SCOM EC 2026',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Voter Authentication',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _voterNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Voter Number',
                        hintText: 'Enter your voter number (e.g., v00001)',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        final randomVoter = generateRandomVoterNumber();
                        _voterNumberController.text = randomVoter;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Generated: $randomVoter')),
                        );
                      },
                      child: const Text('-'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voterNumberController.dispose();
    super.dispose();
  }
}

/* ---------------- HOME PAGE ---------------- */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final voterNumber = ModalRoute.of(context)?.settings.arguments as String? ?? 'Unknown';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MUBAS SCOM EC 2026'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Voter: $voterNumber',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signin');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.how_to_vote,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to SCOM EC 2026 Elections',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/nominate', arguments: voterNumber),
                child: const Text('Nominate'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/vote', arguments: voterNumber),
                child: const Text('Vote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- NOMINATE PAGE ---------------- */
class NominatePage extends StatefulWidget {
  const NominatePage({super.key});

  @override
  State<NominatePage> createState() => _NominatePageState();
}

class _NominatePageState extends State<NominatePage> {
  final List<String> positions = const [
    'Chairperson',
    'Secretary',
    'Treasurer',
    'Prayer Director',
    'Publicity Director',
    'Fundraising Director',
    'Welfare Director',
    'Activities Director',
    'Equipments Director',
  ];

  final Map<String, TextEditingController> _controllers = {};
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    for (final position in positions) {
      _controllers[position] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voterNumber = ModalRoute.of(context)?.settings.arguments as String? ?? 'Unknown';
    final hasNominated = VotingData.votersWhoNominated.contains(voterNumber) || _hasSubmitted;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nominate Candidates'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Voter: $voterNumber',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: hasNominated
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Thank you for submitting your nominees',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Each voter can only nominate once',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: positions.length,
              itemBuilder: (context, index) {
                final position = positions[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controllers[position],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter nominee name',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: hasNominated
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () async {
                print('Check button pressed');
                
                // Check if any nomination is entered
                bool hasAnyNomination = false;
                for (final position in positions) {
                  final nominee = _controllers[position]?.text.trim();
                  if (nominee != null && nominee.isNotEmpty) {
                    hasAnyNomination = true;
                    print('Found nomination: $nominee for $position');
                    break;
                  }
                }
                
                if (!hasAnyNomination) {
                  print('No nominations entered');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter at least one nominee name')),
                  );
                  return;
                }
                
                print('Starting nomination submission...');
                
                // Save nominations with counts and track voter
                for (final position in positions) {
                  final nominee = _controllers[position]?.text.trim();
                  if (nominee != null && nominee.isNotEmpty) {
                    VotingData.nominations[position] ??= {};
                    VotingData.nominations[position]![nominee] = 
                        (VotingData.nominations[position]![nominee] ?? 0) + 1;
                    print('Added nomination: $nominee for $position (count: ${VotingData.nominations[position]![nominee]})');
                  }
                }
                
                // Mark this voter as having nominated
                VotingData.votersWhoNominated.add(voterNumber);
                print('Marked voter $voterNumber as nominated');
                
                try {
                  // Save to server
                  print('Saving nominations to server...');
                  final nominationsSaved = await VotingData.saveNominationsToServer();
                  print('Nominations saved: $nominationsSaved');
                  
                  print('Marking voter as nominated on server...');
                  final voterMarked = await VotingData.markVoterAsNominatedOnServer(voterNumber);
                  print('Voter marked: $voterMarked');
                  
                  // Update state to disable form
                  setState(() {
                    _hasSubmitted = true;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nominations submitted successfully')),
                  );
                  print('Nomination submission completed successfully');
                } catch (e) {
                  print('Error during nomination submission: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting nominations: $e')),
                  );
                }
              },
              child: const Icon(Icons.check),
            ),
    );
  }
}

/* ---------------- VOTE PAGE ---------------- */
class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final Map<String, String?> selectedCandidates = {};
  
  final Map<String, List<String>> candidatesByPosition = {
    'Chairperson': ['Alice Banda', 'Brian Tembo', 'Catherine Phiri'],
    'Secretary': ['John Phiri', 'Mary Chirwa', 'David Banda'],
    'Treasurer': ['Esther Kachinga', 'Frank Mwale', 'Grace Nyirenda'],
    'Prayer Director': ['Peter Zulu', 'Sarah Mwanza', 'Thomas Chanda'],
    'Publicity Director': ['Linda Banda', 'Mike Phiri', 'Nancy Tembo'],
    'Fundraising Director': ['Robert Mwale', 'Susan Kachinga', 'Victor Nyirenda'],
    'Welfare Director': 'Anna Zulu Chanda Mwale Beatrice Phiri'.split(' '),
    'Activities Director': ['Charles Banda', 'Diana Tembo', 'Eric Kachinga'],
    'Equipments Director': ['Henry Mwale', 'Isabel Tembo', 'Jacob Kachinga'],
  };

  List<String> getCandidatesForPosition(String position) {
    // Use admin-submitted candidates if available, otherwise fall back to defaults
    final adminCandidates = VotingData.adminSubmittedCandidates[position] ?? [];
    if (adminCandidates.isNotEmpty) {
      return adminCandidates;
    }
    return candidatesByPosition[position] ?? [];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final voterNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    if (VotingData.votersWhoVoted.contains(voterNumber)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlreadyVotedDialog();
      });
    }
  }

  void _showAlreadyVotedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vote Already Cast'),
          content: const Text('You have already voted. Each voter can only vote once.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _submitVotes() async {
    final voterNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    
    if (VotingData.votersWhoVoted.contains(voterNumber)) {
      _showAlreadyVotedDialog();
      return;
    }

    // Record votes
    for (final entry in selectedCandidates.entries) {
      final position = entry.key;
      final candidate = entry.value;
      if (candidate != null) {
        final positionResults = VotingData.voteResults[position] ?? {};
        positionResults[candidate] = (positionResults[candidate] ?? 0) + 1;
        VotingData.voteResults[position] = positionResults;
      }
    }

    VotingData.votersWhoVoted.add(voterNumber);
    
    // Save to server
    await VotingData.saveVotesToServer();
    await VotingData.markVoterAsVotedOnServer(voterNumber);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Votes submitted successfully! Voter: $voterNumber'),
        duration: const Duration(seconds: 3),
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final voterNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    final hasVoted = VotingData.votersWhoVoted.contains(voterNumber);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Voter: $voterNumber',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: hasVoted
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'You have already voted',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Thank you for participating!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: candidatesByPosition.entries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...getCandidatesForPosition(entry.key).map((candidate) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedCandidates[entry.key] = candidate;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: selectedCandidates[entry.key] == candidate 
                                          ? Colors.red.shade50 
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: candidate,
                                          groupValue: selectedCandidates[entry.key],
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCandidates[entry.key] = value;
                                            });
                                          },
                                          activeColor: Colors.red,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            candidate,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: selectedCandidates[entry.key] == candidate 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                              color: selectedCandidates[entry.key] == candidate 
                                                  ? Colors.red 
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedCandidates.length == candidatesByPosition.length
                          ? _submitVotes
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        selectedCandidates.length == candidatesByPosition.length
                            ? 'Submit Votes'
                            : 'Select ${candidatesByPosition.length - selectedCandidates.length} more positions',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/* ---------------- ADMIN PAGE ---------------- */
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Voters', icon: Icon(Icons.people)),
            Tab(text: 'Nominations', icon: Icon(Icons.how_to_vote)),
            Tab(text: 'Candidates', icon: Icon(Icons.person_add)),
            Tab(text: 'Results', icon: Icon(Icons.bar_chart)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signin');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVotersTab(),
          _buildNominationsTab(),
          _buildCandidatesTab(),
          _buildResultsTab(),
        ],
      ),
    );
  }

  Widget _buildVotersTab() {
    final totalVoters = VotingData.validVoterNumbers.length;
    final votedCount = VotingData.votersWhoVoted.length;
    final notVotedCount = totalVoters - votedCount;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Voting Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('$totalVoters', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const Text('Total Voters'),
                        ],
                      ),
                      Column(
                        children: [
                          Text('$votedCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                          const Text('Voted'),
                        ],
                      ),
                      Column(
                        children: [
                          Text('$notVotedCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                          const Text('Not Voted'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('All Voter Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: VotingData.validVoterNumbers.length,
                      itemBuilder: (context, index) {
                        final voterNumber = VotingData.validVoterNumbers.elementAt(index);
                        final hasVoted = VotingData.votersWhoVoted.contains(voterNumber);
                        
                        return ListTile(
                          title: Text(voterNumber),
                          trailing: Icon(
                            hasVoted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: hasVoted ? Colors.green : Colors.grey,
                          ),
                          subtitle: Text(hasVoted ? 'Voted' : 'Not voted'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNominationsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nominations Received', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: VotingData.nominations.isEmpty
                  ? const Center(child: Text('No nominations received yet'))
                  : ListView.builder(
                      itemCount: VotingData.nominations.length,
                      itemBuilder: (context, index) {
                        final position = VotingData.nominations.keys.elementAt(index);
                        final nominees = VotingData.nominations[position] ?? {};
                        
                        // Sort nominees by count (highest first)
                        final sortedNominees = nominees.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(position, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                                const SizedBox(height: 8),
                                if (sortedNominees.isEmpty)
                                  const Text('No nominations for this position yet', style: TextStyle(color: Colors.grey))
                                else
                                  ...sortedNominees.map((nomineeEntry) {
                                    final nomineeName = nomineeEntry.key;
                                    final nominationCount = nomineeEntry.value;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              nomineeName,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$nominationCount',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Voting Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: VotingData.voteResults.length,
                itemBuilder: (context, index) {
                  final position = VotingData.voteResults.keys.elementAt(index);
                  final results = VotingData.voteResults[position] ?? {};
                  
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(position, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 8),
                          if (results.isEmpty)
                            const Text('No votes recorded yet', style: TextStyle(color: Colors.grey))
                          else
                            ...results.entries.map((entry) {
                              final candidate = entry.key;
                              final votes = entry.value;
                              final totalVotes = results.values.fold(0, (a, b) => a + b);
                              final percentage = totalVotes > 0 ? (votes / totalVotes * 100).toStringAsFixed(1) : '0.0';
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(candidate)),
                                    Text('$votes votes'),
                                    const SizedBox(width: 10),
                                    Text('($percentage%)', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidatesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Manage Candidates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: VotingData.adminSubmittedCandidates.length,
              itemBuilder: (context, index) {
                final position = VotingData.adminSubmittedCandidates.keys.elementAt(index);
                final candidates = VotingData.adminSubmittedCandidates[position] ?? [];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              position,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                _showAddCandidateDialog(position);
                              },
                              tooltip: 'Add Candidate',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (candidates.isEmpty)
                          const Text('No candidates added yet', style: TextStyle(color: Colors.grey))
                        else
                          ...candidates.asMap().entries.map((entry) {
                            final candidateIndex = entry.key;
                            final candidateName = entry.value;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${candidateIndex + 1}. $candidateName'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeCandidate(position, candidateIndex);
                                    },
                                    tooltip: 'Remove Candidate',
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCandidateDialog(String position) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Candidate for $position'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter candidate name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final candidateName = controller.text.trim();
                if (candidateName.isNotEmpty) {
                  setState(() {
                    VotingData.adminSubmittedCandidates[position] ??= [];
                    if (!VotingData.adminSubmittedCandidates[position]!.contains(candidateName)) {
                      VotingData.adminSubmittedCandidates[position]!.add(candidateName);
                    }
                  });
                  // Save to server
                  await VotingData.saveCandidatesToServer();
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeCandidate(String position, int index) async {
    setState(() {
      VotingData.adminSubmittedCandidates[position]?.removeAt(index);
    });
    // Save to server
    await VotingData.saveCandidatesToServer();
  }
}
