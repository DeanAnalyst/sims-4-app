import '../models/regional_info.dart';
import '../models/enums.dart';

class MapDataService {
  static const List<RegionalInfo> _regionalInfoData = [
    RegionalInfo(
      region: Region.english,
      displayName: 'English-speaking Regions',
      description: 'Primarily English-speaking countries including United States, United Kingdom, Canada, Australia, and New Zealand.',
      countries: [
        CountryInfo(name: 'United States', countryCode: 'US', population: 331900000, capital: 'Washington D.C.'),
        CountryInfo(name: 'United Kingdom', countryCode: 'GB', population: 67500000, capital: 'London'),
        CountryInfo(name: 'Canada', countryCode: 'CA', population: 38200000, capital: 'Ottawa'),
        CountryInfo(name: 'Australia', countryCode: 'AU', population: 25700000, capital: 'Canberra'),
        CountryInfo(name: 'New Zealand', countryCode: 'NZ', population: 5100000, capital: 'Wellington'),
      ],
      languages: ['English'],
      namingTradition: 'Western naming conventions with given name followed by family name. Often includes middle names.',
      totalPopulation: 468400000,
    ),
    
    RegionalInfo(
      region: Region.northAfrican,
      displayName: 'North African',
      description: 'Countries across North Africa including Egypt, Libya, Tunisia, Algeria, Morocco, and Sudan.',
      countries: [
        CountryInfo(name: 'Egypt', countryCode: 'EG', population: 104300000, capital: 'Cairo'),
        CountryInfo(name: 'Algeria', countryCode: 'DZ', population: 44700000, capital: 'Algiers'),
        CountryInfo(name: 'Sudan', countryCode: 'SD', population: 44400000, capital: 'Khartoum'),
        CountryInfo(name: 'Morocco', countryCode: 'MA', population: 37300000, capital: 'Rabat'),
        CountryInfo(name: 'Tunisia', countryCode: 'TN', population: 11800000, capital: 'Tunis'),
        CountryInfo(name: 'Libya', countryCode: 'LY', population: 6900000, capital: 'Tripoli'),
      ],
      languages: ['Arabic', 'Berber', 'French'],
      namingTradition: 'Arabic naming patterns with religious and tribal influences. Names often include patronymic elements.',
      totalPopulation: 249400000,
    ),
    
    RegionalInfo(
      region: Region.subSaharanAfrican,
      displayName: 'Sub-Saharan African',
      description: 'Countries south of the Sahara desert including Nigeria, South Africa, Kenya, Ghana, Tanzania, and Uganda.',
      countries: [
        CountryInfo(name: 'Nigeria', countryCode: 'NG', population: 218500000, capital: 'Abuja'),
        CountryInfo(name: 'Ethiopia', countryCode: 'ET', population: 120300000, capital: 'Addis Ababa'),
        CountryInfo(name: 'South Africa', countryCode: 'ZA', population: 60400000, capital: 'Cape Town'),
        CountryInfo(name: 'Kenya', countryCode: 'KE', population: 54000000, capital: 'Nairobi'),
        CountryInfo(name: 'Uganda', countryCode: 'UG', population: 47100000, capital: 'Kampala'),
        CountryInfo(name: 'Ghana', countryCode: 'GH', population: 32800000, capital: 'Accra'),
      ],
      languages: ['English', 'French', 'Portuguese', 'Swahili', 'Yoruba', 'Igbo', 'Hausa'],
      namingTradition: 'Diverse naming traditions often reflecting tribal, religious, or circumstantial meanings.',
      totalPopulation: 533100000,
    ),
    
    RegionalInfo(
      region: Region.eastAfrican,
      displayName: 'East African',
      description: 'Eastern African countries including Ethiopia, Kenya, Uganda, Tanzania, Rwanda, and Burundi.',
      countries: [
        CountryInfo(name: 'Ethiopia', countryCode: 'ET', population: 120300000, capital: 'Addis Ababa'),
        CountryInfo(name: 'Tanzania', countryCode: 'TZ', population: 61500000, capital: 'Dodoma'),
        CountryInfo(name: 'Kenya', countryCode: 'KE', population: 54000000, capital: 'Nairobi'),
        CountryInfo(name: 'Uganda', countryCode: 'UG', population: 47100000, capital: 'Kampala'),
        CountryInfo(name: 'Rwanda', countryCode: 'RW', population: 13300000, capital: 'Kigali'),
        CountryInfo(name: 'Burundi', countryCode: 'BI', population: 12300000, capital: 'Gitega'),
      ],
      languages: ['Swahili', 'Amharic', 'English', 'French', 'Kinyarwanda'],
      namingTradition: 'Names often reflect hopes, circumstances of birth, or ancestral connections.',
      totalPopulation: 308500000,
    ),
    
    RegionalInfo(
      region: Region.southAfrican,
      displayName: 'South African',
      description: 'Southern African countries including South Africa, Botswana, Namibia, Swaziland, and Lesotho.',
      countries: [
        CountryInfo(name: 'South Africa', countryCode: 'ZA', population: 60400000, capital: 'Cape Town'),
        CountryInfo(name: 'Botswana', countryCode: 'BW', population: 2400000, capital: 'Gaborone'),
        CountryInfo(name: 'Namibia', countryCode: 'NA', population: 2500000, capital: 'Windhoek'),
        CountryInfo(name: 'Lesotho', countryCode: 'LS', population: 2100000, capital: 'Maseru'),
        CountryInfo(name: 'Eswatini', countryCode: 'SZ', population: 1200000, capital: 'Mbabane'),
      ],
      languages: ['English', 'Afrikaans', 'Zulu', 'Xhosa', 'Setswana'],
      namingTradition: 'Combination of indigenous African naming traditions and colonial influences.',
      totalPopulation: 68600000,
    ),
    
    RegionalInfo(
      region: Region.centralEuropean,
      displayName: 'Central European',
      description: 'Central European countries including Germany, Austria, Switzerland, Czech Republic, Slovakia, and Hungary.',
      countries: [
        CountryInfo(name: 'Germany', countryCode: 'DE', population: 83200000, capital: 'Berlin'),
        CountryInfo(name: 'Czech Republic', countryCode: 'CZ', population: 10700000, capital: 'Prague'),
        CountryInfo(name: 'Hungary', countryCode: 'HU', population: 9700000, capital: 'Budapest'),
        CountryInfo(name: 'Austria', countryCode: 'AT', population: 9000000, capital: 'Vienna'),
        CountryInfo(name: 'Switzerland', countryCode: 'CH', population: 8700000, capital: 'Bern'),
        CountryInfo(name: 'Slovakia', countryCode: 'SK', population: 5500000, capital: 'Bratislava'),
      ],
      languages: ['German', 'Czech', 'Hungarian', 'Slovak', 'French', 'Italian'],
      namingTradition: 'Germanic and Slavic naming traditions with patronymic surnames and religious influences.',
      totalPopulation: 126800000,
    ),
    
    RegionalInfo(
      region: Region.northernEuropean,
      displayName: 'Northern European',
      description: 'Nordic countries including Norway, Sweden, Denmark, Finland, and Iceland.',
      countries: [
        CountryInfo(name: 'Sweden', countryCode: 'SE', population: 10400000, capital: 'Stockholm'),
        CountryInfo(name: 'Norway', countryCode: 'NO', population: 5400000, capital: 'Oslo'),
        CountryInfo(name: 'Finland', countryCode: 'FI', population: 5500000, capital: 'Helsinki'),
        CountryInfo(name: 'Denmark', countryCode: 'DK', population: 5800000, capital: 'Copenhagen'),
        CountryInfo(name: 'Iceland', countryCode: 'IS', population: 370000, capital: 'Reykjavik'),
      ],
      languages: ['Swedish', 'Norwegian', 'Danish', 'Finnish', 'Icelandic'],
      namingTradition: 'Traditional patronymic naming systems, often with nature-inspired names.',
      totalPopulation: 27470000,
    ),
    
    RegionalInfo(
      region: Region.easternEuropean,
      displayName: 'Eastern European',
      description: 'Eastern European countries including Russia, Poland, Ukraine, Belarus, Czech Republic, and Slovakia.',
      countries: [
        CountryInfo(name: 'Russia', countryCode: 'RU', population: 146200000, capital: 'Moscow'),
        CountryInfo(name: 'Ukraine', countryCode: 'UA', population: 43800000, capital: 'Kyiv'),
        CountryInfo(name: 'Poland', countryCode: 'PL', population: 38000000, capital: 'Warsaw'),
        CountryInfo(name: 'Czech Republic', countryCode: 'CZ', population: 10700000, capital: 'Prague'),
        CountryInfo(name: 'Belarus', countryCode: 'BY', population: 9400000, capital: 'Minsk'),
        CountryInfo(name: 'Slovakia', countryCode: 'SK', population: 5500000, capital: 'Bratislava'),
      ],
      languages: ['Russian', 'Polish', 'Ukrainian', 'Czech', 'Slovak', 'Belarusian'],
      namingTradition: 'Slavic naming traditions with patronymic middle names and family surnames.',
      totalPopulation: 253600000,
    ),
    
    RegionalInfo(
      region: Region.middleEastern,
      displayName: 'Middle Eastern',
      description: 'Countries of the Middle East including Saudi Arabia, Iran, Iraq, Syria, Jordan, Lebanon, Israel, and Turkey.',
      countries: [
        CountryInfo(name: 'Turkey', countryCode: 'TR', population: 84300000, capital: 'Ankara'),
        CountryInfo(name: 'Iran', countryCode: 'IR', population: 85000000, capital: 'Tehran'),
        CountryInfo(name: 'Iraq', countryCode: 'IQ', population: 41200000, capital: 'Baghdad'),
        CountryInfo(name: 'Saudi Arabia', countryCode: 'SA', population: 35000000, capital: 'Riyadh'),
        CountryInfo(name: 'Syria', countryCode: 'SY', population: 18300000, capital: 'Damascus'),
        CountryInfo(name: 'Jordan', countryCode: 'JO', population: 10200000, capital: 'Amman'),
        CountryInfo(name: 'Israel', countryCode: 'IL', population: 9400000, capital: 'Jerusalem'),
        CountryInfo(name: 'Lebanon', countryCode: 'LB', population: 6800000, capital: 'Beirut'),
      ],
      languages: ['Arabic', 'Persian', 'Turkish', 'Hebrew', 'Kurdish'],
      namingTradition: 'Arabic and Persian naming traditions with religious significance and tribal affiliations.',
      totalPopulation: 290200000,
    ),
    
    RegionalInfo(
      region: Region.southAsian,
      displayName: 'South Asian',
      description: 'Countries of South Asia including India, Pakistan, Bangladesh, Sri Lanka, Nepal, and Bhutan.',
      countries: [
        CountryInfo(name: 'India', countryCode: 'IN', population: 1380000000, capital: 'New Delhi'),
        CountryInfo(name: 'Pakistan', countryCode: 'PK', population: 225200000, capital: 'Islamabad'),
        CountryInfo(name: 'Bangladesh', countryCode: 'BD', population: 166300000, capital: 'Dhaka'),
        CountryInfo(name: 'Sri Lanka', countryCode: 'LK', population: 22200000, capital: 'Colombo'),
        CountryInfo(name: 'Nepal', countryCode: 'NP', population: 29600000, capital: 'Kathmandu'),
        CountryInfo(name: 'Bhutan', countryCode: 'BT', population: 770000, capital: 'Thimphu'),
      ],
      languages: ['Hindi', 'Urdu', 'Bengali', 'Tamil', 'Telugu', 'Marathi', 'Gujarati', 'Punjabi'],
      namingTradition: 'Diverse traditions including patronymic, caste-based, and religious naming conventions.',
      totalPopulation: 1824070000,
    ),
    
    RegionalInfo(
      region: Region.eastAsian,
      displayName: 'East Asian',
      description: 'East Asian countries including China, Japan, South Korea, Mongolia, and Taiwan.',
      countries: [
        CountryInfo(name: 'China', countryCode: 'CN', population: 1412000000, capital: 'Beijing'),
        CountryInfo(name: 'Japan', countryCode: 'JP', population: 125800000, capital: 'Tokyo'),
        CountryInfo(name: 'South Korea', countryCode: 'KR', population: 51800000, capital: 'Seoul'),
        CountryInfo(name: 'Taiwan', countryCode: 'TW', population: 23600000, capital: 'Taipei'),
        CountryInfo(name: 'Mongolia', countryCode: 'MN', population: 3300000, capital: 'Ulaanbaatar'),
      ],
      languages: ['Chinese (Mandarin)', 'Japanese', 'Korean', 'Mongolian'],
      namingTradition: 'Family name first followed by given name. Names often have meaningful characters or syllables.',
      totalPopulation: 1616500000,
    ),
    
    RegionalInfo(
      region: Region.oceania,
      displayName: 'Oceania',
      description: 'Pacific Island countries including Australia, New Zealand, Fiji, Papua New Guinea, and other Pacific nations.',
      countries: [
        CountryInfo(name: 'Australia', countryCode: 'AU', population: 25700000, capital: 'Canberra'),
        CountryInfo(name: 'Papua New Guinea', countryCode: 'PG', population: 9100000, capital: 'Port Moresby'),
        CountryInfo(name: 'New Zealand', countryCode: 'NZ', population: 5100000, capital: 'Wellington'),
        CountryInfo(name: 'Fiji', countryCode: 'FJ', population: 920000, capital: 'Suva'),
        CountryInfo(name: 'Solomon Islands', countryCode: 'SB', population: 690000, capital: 'Honiara'),
        CountryInfo(name: 'Vanuatu', countryCode: 'VU', population: 320000, capital: 'Port Vila'),
      ],
      languages: ['English', 'Tok Pisin', 'Maori', 'Fijian', 'French'],
      namingTradition: 'Mix of indigenous Pacific Islander traditions and Western colonial influences.',
      totalPopulation: 41830000,
    ),
    
    RegionalInfo(
      region: Region.lithuanian,
      displayName: 'Lithuanian',
      description: 'Lithuania, a Baltic state with unique linguistic and cultural traditions.',
      countries: [
        CountryInfo(name: 'Lithuania', countryCode: 'LT', population: 2800000, capital: 'Vilnius'),
      ],
      languages: ['Lithuanian'],
      namingTradition: 'Distinctive gender-specific surname endings that change based on marital status and family relations.',
      totalPopulation: 2800000,
    ),
  ];

  Future<List<RegionalInfo>> getAllRegionalInfo() async {
    return _regionalInfoData;
  }

  Future<RegionalInfo?> getRegionalInfo(Region region) async {
    try {
      return _regionalInfoData.firstWhere((info) => info.region == region);
    } catch (e) {
      return null;
    }
  }

  Future<List<CountryInfo>> getCountriesForRegion(Region region) async {
    final regionalInfo = await getRegionalInfo(region);
    return regionalInfo?.countries ?? [];
  }
}