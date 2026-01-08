import 'dart:convert';
import 'package:http/http.dart' as http;

class OnlineVotingService {
  // Replace with your actual server URL
  static const String _baseUrl = 'https://your-voting-server.com/api';
  
  // Initialize data from server
  static Future<Map<String, dynamic>> initializeData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/initialize'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to initialize data');
      }
    } catch (e) {
      // Fallback to local data if server is unavailable
      print('Server unavailable, using local data: $e');
      return _getFallbackData();
    }
  }
  
  // Save nominations to server
  static Future<bool> saveNominations(Map<String, Map<String, int>> nominations) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/nominations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nominations': nominations}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to save nominations: $e');
      return false;
    }
  }
  
  // Save votes to server
  static Future<bool> saveVotes(Map<String, Map<String, int>> votes) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/votes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'votes': votes}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to save votes: $e');
      return false;
    }
  }
  
  // Save admin candidates to server
  static Future<bool> saveAdminCandidates(Map<String, List<String>> candidates) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/candidates'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'candidates': candidates}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to save candidates: $e');
      return false;
    }
  }
  
  // Mark voter as nominated
  static Future<bool> markVoterAsNominated(String voterNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/voter/nominated'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'voterNumber': voterNumber}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to mark voter as nominated: $e');
      return false;
    }
  }
  
  // Mark voter as voted
  static Future<bool> markVoterAsVoted(String voterNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/voter/voted'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'voterNumber': voterNumber}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to mark voter as voted: $e');
      return false;
    }
  }
  
  // Get current data from server
  static Future<Map<String, dynamic>> getCurrentData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/data'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get current data');
      }
    } catch (e) {
      print('Failed to get current data: $e');
      return {};
    }
  }
  
  // Fallback data for offline mode
  static Map<String, dynamic> _getFallbackData() {
    return {
      'validVoterNumbers': [
        'v10101', 'v18345', 'v92674', 'v05892', 'v61783', 'v34921', 'v87564', 'v29318', 'v50647',
        'v71829', 'v04573', 'v68214', 'v39756', 'v82103', 'v16489', 'v73592', 'v40867', 'v97235', 'v25148',
        // ... (add all voter IDs here)
      ],
      'votersWhoVoted': [],
      'votersWhoNominated': [],
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
