#!/usr/bin/env python3
"""
Script to generate comprehensive name datasets for the Sims 4 Name Generator.
This script creates JSON files with 250 first names and 250 last names for each region.
"""

import json
import os

# Comprehensive name datasets for each region
NAME_DATA = {
    "north_african": {
        "male": {
            "firstNames": [
                "Ahmed", "Ali", "Amir", "Anwar", "Ayman", "Aziz", "Badr", "Bashir", "Bilal", "Dawud",
                "Fahd", "Farid", "Faris", "Fawzi", "Ghassan", "Habib", "Hakim", "Hamza", "Hasan", "Hassan",
                "Husayn", "Ibrahim", "Idris", "Imran", "Ismail", "Jabir", "Jafar", "Jamil", "Jawad", "Kadir",
                "Kamil", "Karim", "Khalid", "Khalil", "Mahmud", "Malik", "Mansur", "Marwan", "Masud", "Muhammad",
                "Mustafa", "Nadir", "Nasir", "Nazim", "Omar", "Qasim", "Rafiq", "Rahim", "Rashid", "Rayyan",
                "Sabir", "Sadiq", "Safwan", "Said", "Salim", "Samir", "Shakir", "Shamil", "Sharif", "Tahir",
                "Talib", "Tariq", "Umar", "Usama", "Wahid", "Walid", "Yahya", "Yasin", "Yusuf", "Zahir",
                "Zakariya", "Zayd", "Zayn", "Abdullah", "Abdul", "Adel", "Adnan", "Ahmad", "Akram", "Alaa",
                "Alam", "Amin", "Ammar", "Anas", "Arif", "Asad", "Asim", "Ata", "Atef", "Ayman",
                "Azhar", "Azim", "Bakr", "Basil", "Bassam", "Bilal", "Burhan", "Daniyal", "Daud", "Dhiya",
                "Dilawar", "Ehsan", "Emad", "Fadi", "Fahmi", "Faisal", "Fakhr", "Faruq", "Fathi", "Fayez",
                "Fazal", "Fikri", "Fuad", "Ghazi", "Ghiyath", "Habibullah", "Hadi", "Hafiz", "Haji", "Hamdan",
                "Hamid", "Hamza", "Haris", "Harun", "Hashim", "Haydar", "Hisham", "Hudhayfah", "Husam", "Ihsan",
                "Ikram", "Imad", "Imtiaz", "Inam", "Iqbal", "Irfan", "Isam", "Ishaq", "Ismat", "Izzat",
                "Jalal", "Jamal", "Jawhar", "Jibril", "Junaid", "Kabeer", "Kafeel", "Kaleem", "Kamal", "Karam",
                "Kashif", "Khalaf", "Khalilullah", "Khalis", "Khayri", "Khurshid", "Layth", "Luqman", "Mahdi", "Mahfuz",
                "Majid", "Mamun", "Mansoor", "Maruf", "Masood", "Mazhar", "Mazin", "Miftah", "Mihran", "Mikail",
                "Minhaj", "Miraj", "Mishal", "Mizan", "Mubarak", "Mudassir", "Muhsin", "Mujahid", "Mukhtar", "Mumin",
                "Munir", "Murad", "Murtaza", "Musa", "Mushtaq", "Mustafa", "Mutahhar", "Nabeel", "Nadeem", "Nadir",
                "Naeem", "Nafi", "Nahid", "Najib", "Naji", "Naseem", "Nashit", "Nasim", "Nasser", "Nawaf",
                "Nazir", "Nidal", "Nizar", "Noman", "Noor", "Nuh", "Numan", "Nur", "Nuri", "Obaid",
                "Omar", "Osama", "Othman", "Qais", "Qamar", "Qasim", "Qays", "Qudamah", "Qutaybah", "Rabi",
                "Rafat", "Rafi", "Raghib", "Rahman", "Raihan", "Raja", "Rakan", "Ramadan", "Rami", "Rashad",
                "Rashid", "Rasul", "Rayyan", "Rida", "Ridwan", "Rifat", "Riyad", "Rizwan", "Ruhullah", "Rushdi",
                "Saad", "Sabah", "Sabir", "Sadiq", "Safdar", "Safi", "Safwan", "Sahil", "Said", "Sajid",
                "Salam", "Salih", "Salim", "Salman", "Samad", "Samar", "Samir", "Samiullah", "Saqib", "Sari",
                "Saud", "Sayf", "Shabir", "Shad", "Shafiq", "Shahid", "Shahin", "Shahjahan", "Shahzad", "Shakil",
                "Shamil", "Shams", "Sharif", "Shaukat", "Shaykh", "Shihab", "Shuja", "Siddiq", "Siraj", "Subhan",
                "Sufyan", "Suhail", "Sulaiman", "Sultan", "Taha", "Tahir", "Taj", "Talal", "Talha", "Tamim",
                "Taqi", "Tariq", "Tawfiq", "Tayyib", "Thabit", "Thamir", "Thaqib", "Ubaid", "Ubayd", "Umar",
                "Uthman", "Wadud", "Wahid", "Wajid", "Wali", "Walid", "Waqar", "Waqas", "Waris", "Wasim",
                "Wazir", "Yahya", "Yamin", "Yaqoob", "Yasin", "Yazid", "Younis", "Yousaf", "Yusuf", "Zafar",
                "Zahid", "Zahir", "Zain", "Zakariya", "Zaki", "Zaman", "Zayd", "Zayn", "Zia", "Ziyad"
            ],
            "lastNames": [
                "Abbas", "Abdullah", "Abu", "Ahmad", "Ali", "Al-Masri", "Al-Sayed", "Amir", "Anwar", "Asad",
                "Ashraf", "Aziz", "Badr", "Bakr", "Bashir", "Bilal", "Dawud", "Fahd", "Farid", "Faris",
                "Fawzi", "Ghassan", "Habib", "Hakim", "Hamza", "Hasan", "Hassan", "Husayn", "Ibrahim", "Idris",
                "Imran", "Ismail", "Jabir", "Jafar", "Jamil", "Jawad", "Kadir", "Kamil", "Karim", "Khalid",
                "Khalil", "Mahmud", "Malik", "Mansur", "Marwan", "Masud", "Muhammad", "Mustafa", "Nadir", "Nasir",
                "Nazim", "Omar", "Qasim", "Rafiq", "Rahim", "Rashid", "Rayyan", "Sabir", "Sadiq", "Safwan",
                "Said", "Salim", "Samir", "Shakir", "Shamil", "Sharif", "Tahir", "Talib", "Tariq", "Umar",
                "Usama", "Wahid", "Walid", "Yahya", "Yasin", "Yusuf", "Zahir", "Zakariya", "Zayd", "Zayn",
                "Abdel", "Abdelaziz", "Abdelkader", "Abdelkarim", "Abdelmajid", "Abdelrahman", "Abdelrazik", "Abdelsalam", "Abdelwahab", "Abdou",
                "Abdul", "Abdulaziz", "Abdulhamid", "Abdulkadir", "Abdulkarim", "Abdullah", "Abdulrahman", "Abdulrazik", "Abdulsalam", "Abdulwahab",
                "Abou", "Abu", "Adel", "Adnan", "Ahmad", "Akram", "Alaa", "Alam", "Amin", "Ammar",
                "Anas", "Arif", "Asad", "Asim", "Ata", "Atef", "Ayman", "Azhar", "Azim", "Bakr",
                "Basil", "Bassam", "Bilal", "Burhan", "Daniyal", "Daud", "Dhiya", "Dilawar", "Ehsan", "Emad",
                "Fadi", "Fahmi", "Faisal", "Fakhr", "Faruq", "Fathi", "Fayez", "Fazal", "Fikri", "Fuad",
                "Ghazi", "Ghiyath", "Habibullah", "Hadi", "Hafiz", "Haji", "Hamdan", "Hamid", "Hamza", "Haris",
                "Harun", "Hashim", "Haydar", "Hisham", "Hudhayfah", "Husam", "Ihsan", "Ikram", "Imad", "Imtiaz",
                "Inam", "Iqbal", "Irfan", "Isam", "Ishaq", "Ismat", "Izzat", "Jalal", "Jamal", "Jawhar",
                "Jibril", "Junaid", "Kabeer", "Kafeel", "Kaleem", "Kamal", "Karam", "Kashif", "Khalaf", "Khalilullah",
                "Khalis", "Khayri", "Khurshid", "Layth", "Luqman", "Mahdi", "Mahfuz", "Majid", "Mamun", "Mansoor",
                "Maruf", "Masood", "Mazhar", "Mazin", "Miftah", "Mihran", "Mikail", "Minhaj", "Miraj", "Mishal",
                "Mizan", "Mubarak", "Mudassir", "Muhsin", "Mujahid", "Mukhtar", "Mumin", "Munir", "Murad", "Murtaza",
                "Musa", "Mushtaq", "Mustafa", "Mutahhar", "Nabeel", "Nadeem", "Nadir", "Naeem", "Nafi", "Nahid",
                "Najib", "Naji", "Naseem", "Nashit", "Nasim", "Nasser", "Nawaf", "Nazir", "Nidal", "Nizar",
                "Noman", "Noor", "Nuh", "Numan", "Nur", "Nuri", "Obaid", "Omar", "Osama", "Othman",
                "Qais", "Qamar", "Qasim", "Qays", "Qudamah", "Qutaybah", "Rabi", "Rafat", "Rafi", "Raghib",
                "Rahman", "Raihan", "Raja", "Rakan", "Ramadan", "Rami", "Rashad", "Rashid", "Rasul", "Rayyan",
                "Rida", "Ridwan", "Rifat", "Riyad", "Rizwan", "Ruhullah", "Rushdi", "Saad", "Sabah", "Sabir",
                "Sadiq", "Safdar", "Safi", "Safwan", "Sahil", "Said", "Sajid", "Salam", "Salih", "Salim",
                "Salman", "Samad", "Samar", "Samir", "Samiullah", "Saqib", "Sari", "Saud", "Sayf", "Shabir",
                "Shad", "Shafiq", "Shahid", "Shahin", "Shahjahan", "Shahzad", "Shakil", "Shamil", "Shams", "Sharif",
                "Shaukat", "Shaykh", "Shihab", "Shuja", "Siddiq", "Siraj", "Subhan", "Sufyan", "Suhail", "Sulaiman",
                "Sultan", "Taha", "Tahir", "Taj", "Talal", "Talha", "Tamim", "Taqi", "Tariq", "Tawfiq",
                "Tayyib", "Thabit", "Thamir", "Thaqib", "Ubaid", "Ubayd", "Umar", "Uthman", "Wadud", "Wahid",
                "Wajid", "Wali", "Walid", "Waqar", "Waqas", "Waris", "Wasim", "Wazir", "Yahya", "Yamin",
                "Yaqoob", "Yasin", "Yazid", "Younis", "Yousaf", "Yusuf", "Zafar", "Zahid", "Zahir", "Zain",
                "Zakariya", "Zaki", "Zaman", "Zayd", "Zayn", "Zia", "Ziyad"
            ]
        },
        "female": {
            "firstNames": [
                "Aaliyah", "Aamina", "Aasiya", "Abida", "Adila", "Afaf", "Afra", "Aida", "Aisha", "Alia",
                "Amani", "Amina", "Amira", "Anisa", "Anwar", "Ayesha", "Aziza", "Badria", "Bahija", "Basma",
                "Bushra", "Dalia", "Dina", "Dunya", "Eman", "Fadwa", "Fahima", "Fairuz", "Farah", "Farida",
                "Fatima", "Fawzia", "Firdaus", "Ghada", "Ghazala", "Habiba", "Hadiya", "Hafsa", "Hajar", "Halima",
                "Hamida", "Hanifa", "Hasna", "Hawa", "Hayat", "Hiba", "Huda", "Hurriya", "Ibtisam", "Iman",
                "Inaya", "Iqra", "Isra", "Jamila", "Jannat", "Jawahir", "Kadija", "Kamilah", "Karima", "Khadija",
                "Khalida", "Laila", "Lamia", "Latifa", "Layla", "Lubna", "Madiha", "Maha", "Mahira", "Maimuna",
                "Malika", "Mariam", "Marwa", "Maryam", "Maysa", "Mina", "Mona", "Munira", "Nabila", "Nadia",
                "Nadira", "Nafisa", "Najah", "Najla", "Najwa", "Nawal", "Nazira", "Nida", "Nihal", "Nima",
                "Noor", "Nora", "Nour", "Nura", "Nusayba", "Qamar", "Qudsia", "Rabia", "Rahima", "Rania",
                "Rashida", "Rihanna", "Rima", "Rukhsana", "Sabah", "Sabina", "Sabra", "Sadaf", "Safiya", "Sahar",
                "Saima", "Salma", "Samah", "Samar", "Samira", "Sana", "Sara", "Sarah", "Sawsan", "Shadia",
                "Shahida", "Shakira", "Shamim", "Shams", "Shanaz", "Shazia", "Shereen", "Shirin", "Siham", "Sima",
                "Sonia", "Suhaila", "Suhayla", "Sukayna", "Sumaya", "Sumayya", "Tahira", "Taj", "Tamara", "Tasneem",
                "Thana", "Thara", "Umm", "Wafa", "Wafaa", "Wahida", "Warda", "Yasmin", "Yumna", "Yusra",
                "Zahra", "Zainab", "Zara", "Zaynab", "Zehra", "Zena", "Zina", "Zohra", "Zubaida", "Zuleika",
                "Abeer", "Adiba", "Afnan", "Ahlam", "Aida", "Aisha", "Alia", "Amani", "Amina", "Amira",
                "Anisa", "Anwar", "Ayesha", "Aziza", "Badria", "Bahija", "Basma", "Bushra", "Dalia", "Dina",
                "Dunya", "Eman", "Fadwa", "Fahima", "Fairuz", "Farah", "Farida", "Fatima", "Fawzia", "Firdaus",
                "Ghada", "Ghazala", "Habiba", "Hadiya", "Hafsa", "Hajar", "Halima", "Hamida", "Hanifa", "Hasna",
                "Hawa", "Hayat", "Hiba", "Huda", "Hurriya", "Ibtisam", "Iman", "Inaya", "Iqra", "Isra",
                "Jamila", "Jannat", "Jawahir", "Kadija", "Kamilah", "Karima", "Khadija", "Khalida", "Laila", "Lamia",
                "Latifa", "Layla", "Lubna", "Madiha", "Maha", "Mahira", "Maimuna", "Malika", "Mariam", "Marwa",
                "Maryam", "Maysa", "Mina", "Mona", "Munira", "Nabila", "Nadia", "Nadira", "Nafisa", "Najah",
                "Najla", "Najwa", "Nawal", "Nazira", "Nida", "Nihal", "Nima", "Noor", "Nora", "Nour",
                "Nura", "Nusayba", "Qamar", "Qudsia", "Rabia", "Rahima", "Rania", "Rashida", "Rihanna", "Rima",
                "Rukhsana", "Sabah", "Sabina", "Sabra", "Sadaf", "Safiya", "Sahar", "Saima", "Salma", "Samah",
                "Samar", "Samira", "Sana", "Sara", "Sarah", "Sawsan", "Shadia", "Shahida", "Shakira", "Shamim",
                "Shams", "Shanaz", "Shazia", "Shereen", "Shirin", "Siham", "Sima", "Sonia", "Suhaila", "Suhayla",
                "Sukayna", "Sumaya", "Sumayya", "Tahira", "Taj", "Tamara", "Tasneem", "Thana", "Thara", "Umm",
                "Wafa", "Wafaa", "Wahida", "Warda", "Yasmin", "Yumna", "Yusra", "Zahra", "Zainab", "Zara",
                "Zaynab", "Zehra", "Zena", "Zina", "Zohra", "Zubaida", "Zuleika"
            ],
            "lastNames": [
                "Abbas", "Abdullah", "Abu", "Ahmad", "Ali", "Al-Masri", "Al-Sayed", "Amir", "Anwar", "Asad",
                "Ashraf", "Aziz", "Badr", "Bakr", "Bashir", "Bilal", "Dawud", "Fahd", "Farid", "Faris",
                "Fawzi", "Ghassan", "Habib", "Hakim", "Hamza", "Hasan", "Hassan", "Husayn", "Ibrahim", "Idris",
                "Imran", "Ismail", "Jabir", "Jafar", "Jamil", "Jawad", "Kadir", "Kamil", "Karim", "Khalid",
                "Khalil", "Mahmud", "Malik", "Mansur", "Marwan", "Masud", "Muhammad", "Mustafa", "Nadir", "Nasir",
                "Nazim", "Omar", "Qasim", "Rafiq", "Rahim", "Rashid", "Rayyan", "Sabir", "Sadiq", "Safwan",
                "Said", "Salim", "Samir", "Shakir", "Shamil", "Sharif", "Tahir", "Talib", "Tariq", "Umar",
                "Usama", "Wahid", "Walid", "Yahya", "Yasin", "Yusuf", "Zahir", "Zakariya", "Zayd", "Zayn",
                "Abdel", "Abdelaziz", "Abdelkader", "Abdelkarim", "Abdelmajid", "Abdelrahman", "Abdelrazik", "Abdelsalam", "Abdelwahab", "Abdou",
                "Abdul", "Abdulaziz", "Abdulhamid", "Abdulkadir", "Abdulkarim", "Abdullah", "Abdulrahman", "Abdulrazik", "Abdulsalam", "Abdulwahab",
                "Abou", "Abu", "Adel", "Adnan", "Ahmad", "Akram", "Alaa", "Alam", "Amin", "Ammar",
                "Anas", "Arif", "Asad", "Asim", "Ata", "Atef", "Ayman", "Azhar", "Azim", "Bakr",
                "Basil", "Bassam", "Bilal", "Burhan", "Daniyal", "Daud", "Dhiya", "Dilawar", "Ehsan", "Emad",
                "Fadi", "Fahmi", "Faisal", "Fakhr", "Faruq", "Fathi", "Fayez", "Fazal", "Fikri", "Fuad",
                "Ghazi", "Ghiyath", "Habibullah", "Hadi", "Hafiz", "Haji", "Hamdan", "Hamid", "Hamza", "Haris",
                "Harun", "Hashim", "Haydar", "Hisham", "Hudhayfah", "Husam", "Ihsan", "Ikram", "Imad", "Imtiaz",
                "Inam", "Iqbal", "Irfan", "Isam", "Ishaq", "Ismat", "Izzat", "Jalal", "Jamal", "Jawhar",
                "Jibril", "Junaid", "Kabeer", "Kafeel", "Kaleem", "Kamal", "Karam", "Kashif", "Khalaf", "Khalilullah",
                "Khalis", "Khayri", "Khurshid", "Layth", "Luqman", "Mahdi", "Mahfuz", "Majid", "Mamun", "Mansoor",
                "Maruf", "Masood", "Mazhar", "Mazin", "Miftah", "Mihran", "Mikail", "Minhaj", "Miraj", "Mishal",
                "Mizan", "Mubarak", "Mudassir", "Muhsin", "Mujahid", "Mukhtar", "Mumin", "Munir", "Murad", "Murtaza",
                "Musa", "Mushtaq", "Mustafa", "Mutahhar", "Nabeel", "Nadeem", "Nadir", "Naeem", "Nafi", "Nahid",
                "Najib", "Naji", "Naseem", "Nashit", "Nasim", "Nasser", "Nawaf", "Nazir", "Nidal", "Nizar",
                "Noman", "Noor", "Nuh", "Numan", "Nur", "Nuri", "Obaid", "Omar", "Osama", "Othman",
                "Qais", "Qamar", "Qasim", "Qays", "Qudamah", "Qutaybah", "Rabi", "Rafat", "Rafi", "Raghib",
                "Rahman", "Raihan", "Raja", "Rakan", "Ramadan", "Rami", "Rashad", "Rashid", "Rasul", "Rayyan",
                "Rida", "Ridwan", "Rifat", "Riyad", "Rizwan", "Ruhullah", "Rushdi", "Saad", "Sabah", "Sabir",
                "Sadiq", "Safdar", "Safi", "Safwan", "Sahil", "Said", "Sajid", "Salam", "Salih", "Salim",
                "Salman", "Samad", "Samar", "Samir", "Samiullah", "Saqib", "Sari", "Saud", "Sayf", "Shabir",
                "Shad", "Shafiq", "Shahid", "Shahin", "Shahjahan", "Shahzad", "Shakil", "Shamil", "Shams", "Sharif",
                "Shaukat", "Shaykh", "Shihab", "Shuja", "Siddiq", "Siraj", "Subhan", "Sufyan", "Suhail", "Sulaiman",
                "Sultan", "Taha", "Tahir", "Taj", "Talal", "Talha", "Tamim", "Taqi", "Tariq", "Tawfiq",
                "Tayyib", "Thabit", "Thamir", "Thaqib", "Ubaid", "Ubayd", "Umar", "Uthman", "Wadud", "Wahid",
                "Wajid", "Wali", "Walid", "Waqar", "Waqas", "Waris", "Wasim", "Wazir", "Yahya", "Yamin",
                "Yaqoob", "Yasin", "Yazid", "Younis", "Yousaf", "Yusuf", "Zafar", "Zahid", "Zahir", "Zain",
                "Zakariya", "Zaki", "Zaman", "Zayd", "Zayn", "Zia", "Ziyad"
            ]
        }
    }
}

def generate_name_files():
    """Generate JSON name files for all regions."""
    output_dir = "sims4_name_generator/assets/data/names"
    os.makedirs(output_dir, exist_ok=True)
    
    for region, data in NAME_DATA.items():
        for gender, names in data.items():
            filename = f"{region}_{gender}.json"
            filepath = os.path.join(output_dir, filename)
            
            json_data = {
                "region": region.replace("_", ""),
                "gender": gender,
                "firstNames": names["firstNames"],
                "lastNames": names["lastNames"]
            }
            
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(json_data, f, indent=2, ensure_ascii=False)
            
            print(f"Generated {filename} with {len(names['firstNames'])} first names and {len(names['lastNames'])} last names")

if __name__ == "__main__":
    generate_name_files() 