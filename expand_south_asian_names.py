#!/usr/bin/env python3
"""
Script to expand South Asian name files with authentic Indian and Pakistani names.
"""

import json

# Authentic South Asian female names (Indian, Pakistani, Bangladeshi, Sri Lankan)
SOUTH_ASIAN_FEMALE_NAMES = [
    # Traditional popular names
    "Priya", "Anita", "Sunita", "Kavita", "Riya", "Pooja", "Sonia", "Neha", "Meera", "Asha",
    "Deepika", "Kavitha", "Lakshmi", "Saraswati", "Durga", "Kali", "Radha", "Sita", "Geeta", "Maya",
    # Modern popular 2024 names
    "Aditi", "Ishani", "Aadhya", "Anaya", "Avni", "Diya", "Kiara", "Myra", "Saanvi", "Veda",
    "Arya", "Aarya", "Aanya", "Navya", "Pari", "Riya", "Tara", "Zara", "Kiera", "Ira",
    # Traditional regional names
    "Padmini", "Kamala", "Shanti", "Uma", "Prema", "Vani", "Sudha", "Usha", "Lalita", "Pushpa",
    "Rekha", "Nisha", "Kiran", "Jyoti", "Savita", "Veena", "Lata", "Anuradha", "Gayatri", "Vasanti",
    # Bengali names
    "Aparna", "Bani", "Chandana", "Debjani", "Indrani", "Jayanti", "Kaberi", "Lopamudra", "Madhavi", "Namrata",
    # Tamil/South Indian names
    "Aishwarya", "Bhavana", "Chitra", "Divya", "Geetha", "Harini", "Janaki", "Kalpana", "Latha", "Mala",
    "Nalini", "Padma", "Rajani", "Sangeetha", "Thara", "Vasudha", "Yamini", "Zuhra", "Bindu", "Chinmayi",
    # Punjabi/North Indian names
    "Amandeep", "Balvinder", "Daljeet", "Gurbani", "Harpreet", "Jasbir", "Karamjeet", "Lovepreet", "Manpreet", "Navpreet",
    # Pakistani/Urdu names
    "Farah", "Hina", "Kinza", "Maria", "Nadia", "Rabia", "Sana", "Tania", "Uzma", "Warda",
    "Ayesha", "Bushra", "Fatima", "Hafsa", "Jamila", "Khadija", "Maryam", "Noor", "Rukhsana", "Zainab",
    # Contemporary trending names
    "Alisha", "Ariana", "Ishika", "Khushi", "Mahika", "Palak", "Rhea", "Shanaya", "Tanvi", "Urvi"
]

SOUTH_ASIAN_MALE_NAMES = [
    # Traditional popular names  
    "Raj", "Ravi", "Sunil", "Anil", "Manoj", "Sanjay", "Ajay", "Vijay", "Rakesh", "Mahesh",
    "Krishna", "Rama", "Shiva", "Vishnu", "Ganesh", "Hanuman", "Arjun", "Bhima", "Yudhishthira", "Nakula",
    # Modern popular 2024 names
    "Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh", "Ayaan", "Krishna", "Ishaan",
    "Shaurya", "Atharv", "Rudra", "Rian", "Kiaan", "Advaith", "Arnav", "Veer", "Aahan", "Rehan",
    # Traditional regional names
    "Ashok", "Deepak", "Harish", "Jagdish", "Kamal", "Lalit", "Mohan", "Naresh", "Om", "Prem",
    "Ramesh", "Santosh", "Tarun", "Umesh", "Vinod", "Yash", "Bhaskar", "Chandra", "Dinesh", "Gopal",
    # Bengali names
    "Amitabh", "Biswajit", "Chiranjib", "Debashish", "Gautam", "Hriday", "Indraneel", "Jayanta", "Kaushik", "Manas",
    # Tamil/South Indian names
    "Arumugam", "Balasubramaniam", "Chandrasekhar", "Dhananjay", "Ezhil", "Ganesh", "Hari", "Ilango", "Jagan", "Karthik",
    "Lakshman", "Murugan", "Natarajan", "Parthasarathy", "Rajesh", "Subramani", "Thangam", "Ulaganathan", "Vasudevan", "Yuvan",
    # Punjabi/North Indian names
    "Amarjeet", "Balwinder", "Daljit", "Gurmeet", "Hardeep", "Jasdeep", "Karanbir", "Lovedeep", "Mandeep", "Navdeep",
    # Pakistani/Urdu names
    "Ahmad", "Bilal", "Danish", "Farhan", "Hassan", "Imran", "Junaid", "Kamran", "Luqman", "Mohammad",
    "Noman", "Omar", "Qasim", "Rashid", "Salman", "Tariq", "Usman", "Waqas", "Yasir", "Zeeshan",
    # Contemporary trending names
    "Aryan", "Dhruv", "Ishan", "Kabir", "Neil", "Parth", "Riaan", "Samarth", "Tanish", "Vedant"
]

# Common South Asian surnames
SOUTH_ASIAN_SURNAMES = [
    # Most common surnames (mentioned in your query)
    "Sharma", "Patel", "Singh", "Gupta", "Kumar", "Shah", "Agarwal", "Jain",
    # Other common Hindi/North Indian surnames
    "Mishra", "Tiwari", "Yadav", "Chauhan", "Rajput", "Thakur", "Verma", "Shukla", "Pandey", "Srivastava",
    "Chandra", "Joshi", "Bansal", "Mahajan", "Malhotra", "Kapoor", "Chopra", "Arora", "Bhatia", "Sethi",
    # Gujarati surnames
    "Patel", "Shah", "Mehta", "Desai", "Modi", "Joshi", "Parikh", "Amin", "Vyas", "Trivedi",
    # Punjabi surnames
    "Singh", "Kaur", "Gill", "Sandhu", "Brar", "Dhillon", "Sidhu", "Bajwa", "Grewal", "Mann",
    # South Indian surnames
    "Reddy", "Nair", "Menon", "Pillai", "Iyer", "Iyengar", "Rao", "Chandra", "Krishna", "Raman",
    "Naidu", "Chetty", "Mudaliar", "Gounder", "Naicker", "Balaji", "Suresh", "Ramesh", "Ganesh", "Mohan",
    # Bengali surnames
    "Banerjee", "Chatterjee", "Mukherjee", "Bhattacharya", "Chakraborty", "Ghosh", "Bose", "Sen", "Das", "Dutta",
    "Roy", "Sarkar", "Mitra", "Pal", "Saha", "Biswas", "Mandal", "Halder", "Bhowmik", "Majumdar",
    # Marathi surnames
    "Patil", "Kulkarni", "Joshi", "Deshpande", "Shinde", "Jadhav", "More", "Kale", "Pawar", "Bhosale",
    # Pakistani/Muslim surnames
    "Khan", "Ali", "Ahmed", "Hassan", "Hussain", "Shah", "Malik", "Qureshi", "Sheikh", "Siddiqui",
    "Butt", "Chaudhry", "Awan", "Bhatti", "Rajput", "Dar", "Lone", "Wani", "Mir", "Andrabi",
    # Other regional surnames
    "Acharya", "Bhandari", "Chowdhury", "Fernandes", "Gomes", "D'Souza", "Pereira", "Rodrigues", "Silva", "Costa"
]

def expand_south_asian_files():
    """Expand the South Asian name files with authentic names."""
    
    # Female names
    female_data = {
        "region": "southAsian",
        "gender": "female",
        "firstNames": sorted(SOUTH_ASIAN_FEMALE_NAMES),
        "lastNames": sorted(SOUTH_ASIAN_SURNAMES)
    }
    
    # Male names
    male_data = {
        "region": "southAsian", 
        "gender": "male",
        "firstNames": sorted(SOUTH_ASIAN_MALE_NAMES),
        "lastNames": sorted(SOUTH_ASIAN_SURNAMES)
    }
    
    # Write files
    with open('sims4_name_generator/assets/data/names/southAsian_female.json', 'w', encoding='utf-8') as f:
        json.dump(female_data, f, ensure_ascii=False, indent=2)
    
    with open('sims4_name_generator/assets/data/names/southAsian_male.json', 'w', encoding='utf-8') as f:
        json.dump(male_data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated southAsian_female.json: {len(female_data['firstNames'])} first names, {len(female_data['lastNames'])} last names")
    print(f"Updated southAsian_male.json: {len(male_data['firstNames'])} first names, {len(male_data['lastNames'])} last names")

if __name__ == "__main__":
    expand_south_asian_files()