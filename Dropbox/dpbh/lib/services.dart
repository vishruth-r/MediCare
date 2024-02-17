import 'dart:convert';
import 'package:http/http.dart' as http;

class Services {
  static Future<Map<String, dynamic>> fetchDomainsAndCounts() async {
    final String domainsUrl = 'http://192.168.219.96:8000/inference_server/domains/';
    final String countsUrl = 'http://192.168.219.96:8000/inference_server/domain_counts/?domain=';

    try {
      // Fetch domains
      final domainsResponse = await http.get(Uri.parse(domainsUrl));
      if (domainsResponse.statusCode != 200) {
        throw Exception('Failed to fetch domains: ${domainsResponse.body}');
      }
      List<dynamic> domainsData = jsonDecode(domainsResponse.body);
      List<String> domains = domainsData.map((domain) => domain as String).toList();

      // Fetch counts for each domain individually
      Map<String, dynamic> countsData = {};
      for (String domain in domains) {
        final countResponse = await http.get(Uri.parse('$countsUrl$domain'));
        if (countResponse.statusCode != 200) {
          throw Exception('Failed to fetch count for domain $domain: ${countResponse.body}');
        }
        countsData[domain] = jsonDecode(countResponse.body);
        print(countResponse.body);
      }

      return {'domains': domains, 'counts': countsData};
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
