#!/usr/bin/env python3
"""
Script to expand Middle Eastern name files with authentic Arabic and Persian names.
"""

import json

# Authentic Middle Eastern female names based on 2024 research
MIDDLE_EASTERN_FEMALE_NAMES = [
    # Traditional popular names
    "Fatima", "Aisha", "Mariam", "Zainab", "Khadija", "Hafsa", "Ruqayyah", "Umm Kulthum", "Zaynab", "Sayyida",
    # Modern popular Arabic names 2024
    "Amira", "Noor", "Layla", "Zara", "Yara", "Lina", "Maya", "Dina", "Rana", "Reem", "Sara", "Lara", "Nour",
    "Yasmin", "Jana", "Hala", "Dania", "Rania", "Ghada", "Hanan", "Iman", "Nadia", "Rima", "Salam", "Warda",
    # Persian names
    "Shirin", "Soraya", "Nasrin", "Golshan", "Banafsheh", "Setareh", "Maryam", "Narges", "Zahra", "Mina",
    "Anahita", "Farah", "Laleh", "Niloofar", "Parichehr", "Roya", "Samira", "Taraneh", "Vida", "Yasaman",
    # Additional traditional names
    "Aaliyah", "Abir", "Adila", "Afaf", "Amal", "Asma", "Basma", "Bushra", "Dalal", "Fariha", "Ghalia",
    "Huda", "Iman", "Jamila", "Karima", "Latifa", "Malika", "Nabila", "Qadira", "Rahma", "Safiya", "Samira",
    "Tahira", "Wafaa", "Zahara", "Aziza", "Badriya", "Faiza", "Habiba", "Ikram", "Jawahir", "Kamilah",
    "Leila", "Mahira", "Naima", "Ola", "Qamar", "Rasha", "Sabrina", "Talia", "Umber", "Widad", "Yasmina",
    "Zulaikha", "Amina", "Batool", "Farah", "Hiba", "Ibtisam", "Jannah", "Lubna", "Manal", "Nayeli",
    # Contemporary names
    "Minahil", "Irha", "Mehmal", "Hoorain", "Arisha", "Lubna", "Hina", "Zimal", "Malaika"
]

MIDDLE_EASTERN_MALE_NAMES = [
    # Traditional names
    "Muhammad", "Ali", "Hassan", "Hussein", "Omar", "Abdullah", "Ibrahim", "Ahmed", "Mohammed", "Yusuf", "Isa",
    "Musa", "Harun", "Sulaiman", "Dawud", "Yahya", "Zakariya", "Ishaq", "Ismail", "Yaqub", "Adam",
    # Modern popular names
    "Amir", "Khalid", "Rashid", "Samir", "Tariq", "Zaid", "Farid", "Hamid", "Jamal", "Karim", "Majid", "Nabil",
    "Qasim", "Rafiq", "Salim", "Walid", "Yasir", "Zaki", "Adel", "Basim", "Fahad", "Ghassan", "Hadi",
    # Persian names
    "Cyrus", "Darius", "Farhad", "Kaveh", "Kourosh", "Nader", "Omid", "Parviz", "Rostam", "Shahram",
    "Arash", "Babak", "Ehsan", "Farzad", "Hooman", "Kamran", "Milad", "Navid", "Peyman", "Ramin",
    "Saeed", "Vahid", "Behrooz", "Dariush", "Farshad", "Hossein", "Javad", "Masoud", "Pouya", "Reza",
    # Additional traditional names
    "Abdul Rahman", "Abdul Aziz", "Abdul Malik", "Abdul Hadi", "Mahmoud", "Mustafa", "Othman", "Bilal",
    "Umar", "Uthman", "Talha", "Zubair", "Sa'd", "Abu Bakr", "Khalil", "Marwan", "Yazid", "Mu'awiya",
    "Harith", "Nu'man", "Qutaiba", "Rabi'", "Sa'id", "Walid", "Yazid", "Zayn", "Ziyad", "Amr",
    # Contemporary Arabic names  
    "Faisal", "Saud", "Nasser", "Mansour", "Fahd", "Salman", "Bandar", "Turki", "Khalil", "Marwan",
    "Osama", "Wael", "Amjad", "Hatim", "Mazen", "Fawaz", "Nawaf", "Rayan", "Sultan", "Yazeed"
]

# Common Middle Eastern surnames with proper Arabic patronymic structure
MIDDLE_EASTERN_SURNAMES = [
    # Al- prefixed surnames (most common)
    "Al-Ahmad", "Al-Hassan", "Al-Hussein", "Al-Mahmoud", "Al-Rashid", "Al-Sabah", "Al-Thani", "Al-Maktoum",
    "Al-Nahyan", "Al-Qasimi", "Al-Zahra", "Al-Ansari", "Al-Hashemi", "Al-Omari", "Al-Tamimi", "Al-Ghamdi",
    "Al-Otaibi", "Al-Dosari", "Al-Shammari", "Al-Harbi", "Al-Mutairi", "Al-Zahrani", "Al-Qahtani",
    # Ibn/Bin patronymic surnames
    "Ibn Saud", "Ibn Rashid", "Ibn Abdullah", "Ibn Mohammed", "Ibn Ahmed", "Ibn Omar", "Ibn Ali", "Ibn Hassan",
    # Common surnames without prefixes
    "Mohammed", "Ahmed", "Ali", "Hassan", "Hussein", "Omar", "Abdullah", "Ibrahim", "Yusuf", "Mahmoud",
    "Rashid", "Khalil", "Mansour", "Nasser", "Faisal", "Saleh", "Saeed", "Farid", "Hamid", "Majid",
    "Khan", "Sheikh", "Imam", "Qadi", "Hafiz", "Maulana", "Mirza", "Shah", "Pasha", "Bey",
    # Regional surnames
    "Al-Masri", "Al-Shami", "Al-Iraqi", "Al-Hijazi", "Al-Najdi", "Al-Yamani", "Al-Maghribi", "Al-Sudani",
    "Al-Kuwaiti", "Al-Bahraini", "Al-Qatari", "Al-Emirati", "Al-Omani", "Al-Lubnani", "Al-Urduni", "Al-Filastini",
    # Traditional family names
    "Abdel Rahman", "Abdul Aziz", "Abdul Malik", "Abdul Hadi", "Abdul Karim", "Abdul Latif", "Abdul Wahab",
    "Bin Laden", "Bin Zayed", "Bin Mohammed", "Bin Rashid", "Bin Khalifa", "Bin Hamad", "Bin Thani"
]

def expand_middle_eastern_files():
    """Expand the Middle Eastern name files with authentic names."""
    
    # Female names
    female_data = {
        "region": "middleEastern",
        "gender": "female", 
        "firstNames": sorted(MIDDLE_EASTERN_FEMALE_NAMES),
        "lastNames": sorted(MIDDLE_EASTERN_SURNAMES)
    }
    
    # Male names
    male_data = {
        "region": "middleEastern",
        "gender": "male",
        "firstNames": sorted(MIDDLE_EASTERN_MALE_NAMES),
        "lastNames": sorted(MIDDLE_EASTERN_SURNAMES)
    }
    
    # Write files
    with open('sims4_name_generator/assets/data/names/middleEastern_female.json', 'w', encoding='utf-8') as f:
        json.dump(female_data, f, ensure_ascii=False, indent=2)
    
    with open('sims4_name_generator/assets/data/names/middleEastern_male.json', 'w', encoding='utf-8') as f:
        json.dump(male_data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated middleEastern_female.json: {len(female_data['firstNames'])} first names, {len(female_data['lastNames'])} last names")
    print(f"Updated middleEastern_male.json: {len(male_data['firstNames'])} first names, {len(male_data['lastNames'])} last names")

if __name__ == "__main__":
    expand_middle_eastern_files()