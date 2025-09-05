#!/usr/bin/env python3
"""
Script to expand remaining small region name files with authentic names.
"""

import json

# Northern European Names (Swedish, Norwegian, Danish, Finnish)
NORTHERN_EUROPEAN_FEMALE_NAMES = [
    # Most popular 2024 names
    "Nora", "Emma", "Leah", "Olivia", "Sara", "Selma", "Ellinor", "Ingrid", "Astrid", "Freya",
    "Liv", "Maria", "Aurora", "Helmi", "Sofia", "Ann-Marie", "Elsa", "Freja", "Lilja", "Tuulikki",
    # Traditional Swedish names
    "Anna", "Margareta", "Elisabeth", "Birgitta", "Kristina", "Eva", "Marie", "Karin", "Lena", "Helena",
    "Inger", "Gunilla", "Susanne", "Annika", "Carina", "Agneta", "Monica", "Ulla", "Anita", "Brita",
    # Traditional Norwegian names
    "Kari", "Anne", "Inger", "Liv", "Berit", "Astrid", "Randi", "Marit", "Tone", "Hilde",
    "Solveig", "Gerd", "Brit", "Oddny", "Jorunn", "Turid", "Vigdis", "Eldrid", "Gunhild", "Ragnhild",
    # Traditional Danish names
    "Anna", "Kirsten", "Mette", "Hanne", "Lene", "Susanne", "Tina", "Pia", "Bente", "Dorthe",
    "Birgitte", "Louise", "Charlotte", "Camilla", "Pernille", "Rikke", "Maja", "Karen", "Lone", "Bodil",
    # Traditional Finnish names
    "Aino", "Elina", "Hanna", "Johanna", "Kaarina", "Leena", "Marja", "Pirjo", "Raija", "Sari",
    "Terttu", "Tuula", "Ulla", "Vappu", "Virpi", "Aira", "Eila", "Hilkka", "Irmeli", "Kaisa",
    # Modern Scandinavian names
    "Saga", "Stella", "Alva", "Ebba", "Vera", "Alma", "Agnes", "Ella", "Wilma", "Maja",
    "Lova", "Iris", "Ester", "Sigrid", "Thea", "Mila", "Nova", "Luna", "Ellie", "Vera"
]

NORTHERN_EUROPEAN_MALE_NAMES = [
    # Traditional Swedish names
    "Anders", "Lars", "Karl", "Erik", "Nils", "Per", "Jan", "Mikael", "Hans", "Gunnar",
    "Sven", "Magnus", "Ulf", "Bengt", "Bo", "Christer", "Claes", "Dan", "Fredrik", "Gustaf",
    # Traditional Norwegian names
    "Ole", "Lars", "Knut", "Arne", "Kjell", "Svein", "Rolf", "Geir", "Tor", "Bjørn",
    "Einar", "Gunnar", "Harald", "Ivar", "Magnus", "Nils", "Odd", "Ragnar", "Stein", "Terje",
    # Traditional Danish names
    "Jens", "Peter", "Niels", "Henrik", "Lars", "Anders", "Martin", "Søren", "Thomas", "Michael",
    "Jan", "Jesper", "Klaus", "Morten", "Finn", "Erik", "Christian", "Ole", "Hans", "Bent",
    # Traditional Finnish names
    "Juhani", "Johannes", "Olavi", "Antero", "Tapani", "Kalevi", "Mikael", "Matti", "Pentti", "Eino",
    "Väinö", "Toivo", "Reino", "Paavo", "Veijo", "Aarne", "Yrjö", "Heikki", "Martti", "Seppo",
    # Modern popular names
    "William", "Liam", "Noah", "Oliver", "Lucas", "Hugo", "Elias", "Alexander", "Oscar", "Leon",
    "Emil", "Isak", "Axel", "Filip", "Viggo", "Albin", "Alfred", "Theo", "Vincent", "Edvin"
]

# Northern European surnames
NORTHERN_EUROPEAN_SURNAMES = [
    # Swedish surnames
    "Andersson", "Johansson", "Karlsson", "Nilsson", "Eriksson", "Larsson", "Olsson", "Persson", "Svensson", "Gustafsson",
    "Pettersson", "Jonsson", "Jansson", "Hansson", "Bengtsson", "Jönsson", "Lindberg", "Jakobsson", "Magnusson", "Olofsson",
    # Norwegian surnames
    "Hansen", "Johansen", "Olsen", "Larsen", "Andersen", "Pedersen", "Nilsen", "Kristiansen", "Jensen", "Karlsen",
    "Johnsen", "Pettersen", "Eriksen", "Berg", "Haugen", "Hagen", "Johannessen", "Andresen", "Jacobsen", "Dahl",
    # Danish surnames
    "Nielsen", "Jensen", "Hansen", "Pedersen", "Andersen", "Christensen", "Larsen", "Sørensen", "Rasmussen", "Jørgensen",
    "Petersen", "Madsen", "Kristensen", "Olsen", "Thomsen", "Christiansen", "Poulsen", "Johansen", "Møller", "Mortensen",
    # Finnish surnames
    "Virtanen", "Korhonen", "Mäkinen", "Nieminen", "Mäkelä", "Hämäläinen", "Laine", "Heikkinen", "Koskinen", "Järvinen",
    "Lehtonen", "Lehtinen", "Saarinen", "Hakkarainen", "Haapala", "Kinnunen", "Salminen", "Heinonen", "Niemi", "Heikkilä"
]

# Oceania Names (Australian, New Zealand, Pacific Islander)
OCEANIA_FEMALE_NAMES = [
    # Popular Australian/NZ names 2024
    "Charlotte", "Amelia", "Isla", "Olivia", "Mia", "Lily", "Isabella", "Hazel", "Harper", "Mila",
    "Frankie", "Billie", "Mackenzie", "Evie", "Lottie", "Claire", "Jasmine", "Grace", "Sophie", "Ruby",
    "Chloe", "Zoe", "Emily", "Jessica", "Sarah", "Emma", "Madison", "Hannah", "Abigail", "Elizabeth",
    # Traditional Australian names
    "Kylie", "Narelle", "Janine", "Tracey", "Michelle", "Nicole", "Rebecca", "Melissa", "Catherine", "Jennifer",
    "Danielle", "Samantha", "Amanda", "Natalie", "Rachel", "Kelly", "Lisa", "Karen", "Susan", "Helen",
    # Māori names from New Zealand
    "Aroha", "Te Aroha", "Maia", "Moana", "Anahera", "Atarangi", "Manaia", "Rangimarie", "Rangi", "Marama",
    "Tui", "Kiri", "Hine", "Mere", "Ngaio", "Ripeka", "Wikitoria", "Rewi", "Aroha", "Hinewai",
    # Pacific Islander names
    "Leilani", "Nalani", "Kailani", "Mahina", "Kalea", "Noelani", "Tiana", "Moana", "Lani", "Kaia",
    "Sione", "Mele", "Ana", "Seini", "Salome", "Mere", "Vika", "Lupe", "Tala", "Sina"
]

OCEANIA_MALE_NAMES = [
    # Popular Australian/NZ names 2024
    "Oliver", "Jack", "Noah", "William", "James", "Henry", "Lucas", "Liam", "Alexander", "Mason",
    "Ethan", "Leo", "Samuel", "Hunter", "Jacob", "Lachlan", "Finn", "Cooper", "Max", "Charlie",
    "Thomas", "Benjamin", "Isaac", "Harrison", "Xavier", "Sebastian", "Hudson", "Kai", "Eli", "Oscar",
    # Traditional Australian names
    "Bruce", "Shane", "Wayne", "Darren", "Glenn", "Craig", "Brett", "Troy", "Dean", "Dale",
    "Scott", "Mark", "Paul", "Andrew", "Matthew", "Daniel", "David", "Michael", "John", "Robert",
    # Māori names from New Zealand
    "Wiremu", "Hoani", "Pita", "Manu", "Tamati", "Matiu", "Rangi", "Tane", "Kahu", "Manaia",
    "Ngai", "Rewa", "Paki", "Koro", "Hemi", "Rawiri", "Turi", "Wiki", "Paora", "Hone",
    # Pacific Islander names  
    "Kai", "Malo", "Sione", "Viliami", "Tevita", "Sami", "Peni", "Semi", "Iosua", "Petelo",
    "Taniela", "Paulo", "Filipe", "Ioane", "Simione", "Leone", "Mosese", "Setoki", "Alipate", "Isaia"
]

# Oceania surnames
OCEANIA_SURNAMES = [
    # Common Australian/NZ surnames
    "Smith", "Johnson", "Brown", "Wilson", "Taylor", "Jones", "Williams", "Davis", "Miller", "Martin",
    "Anderson", "Jackson", "Thompson", "White", "Harris", "Clark", "Lewis", "Robinson", "Walker", "Hall",
    "Young", "King", "Wright", "Hill", "Scott", "Green", "Adams", "Baker", "Nelson", "Carter",
    "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins",
    # Traditional Australian surnames
    "O'Brien", "McDonald", "Kelly", "Murphy", "Ryan", "Sullivan", "Walsh", "O'Connor", "Murray", "Reid",
    # Māori surnames
    "Williams", "Jones", "Smith", "Brown", "Wilson", "Campbell", "Stewart", "Thomson", "Anderson", "Johnson",
    "Ngata", "Tauroa", "Henare", "Pere", "Rēhia", "Manu", "Kahu", "Tamati", "Hoani", "Wiremu",
    # Pacific Islander surnames
    "Taumalolo", "Fifita", "Fonua", "Havili", "Latu", "Mafi", "Moala", "Nonu", "Pangai", "Piukala",
    "Tupou", "Vea", "Vuna", "Fainga'a", "Holani", "Kaufusi", "Langi", "Lousi", "Mahina", "Pouha"
]

def expand_northern_european_files():
    """Expand Northern European name files."""
    # Female names
    female_data = {
        "region": "northernEuropean",
        "gender": "female",
        "firstNames": sorted(NORTHERN_EUROPEAN_FEMALE_NAMES),
        "lastNames": sorted(NORTHERN_EUROPEAN_SURNAMES)
    }
    
    # Male names
    male_data = {
        "region": "northernEuropean",
        "gender": "male", 
        "firstNames": sorted(NORTHERN_EUROPEAN_MALE_NAMES),
        "lastNames": sorted(NORTHERN_EUROPEAN_SURNAMES)
    }
    
    # Write files
    with open('sims4_name_generator/assets/data/names/northernEuropean_female.json', 'w', encoding='utf-8') as f:
        json.dump(female_data, f, ensure_ascii=False, indent=2)
    
    with open('sims4_name_generator/assets/data/names/northernEuropean_male.json', 'w', encoding='utf-8') as f:
        json.dump(male_data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated northernEuropean_female.json: {len(female_data['firstNames'])} first names, {len(female_data['lastNames'])} last names")
    print(f"Updated northernEuropean_male.json: {len(male_data['firstNames'])} first names, {len(male_data['lastNames'])} last names")

def expand_oceania_files():
    """Expand Oceania name files."""
    # Female names
    female_data = {
        "region": "oceania",
        "gender": "female",
        "firstNames": sorted(OCEANIA_FEMALE_NAMES),
        "lastNames": sorted(OCEANIA_SURNAMES)
    }
    
    # Male names
    male_data = {
        "region": "oceania", 
        "gender": "male",
        "firstNames": sorted(OCEANIA_MALE_NAMES),
        "lastNames": sorted(OCEANIA_SURNAMES)
    }
    
    # Write files
    with open('sims4_name_generator/assets/data/names/oceania_female.json', 'w', encoding='utf-8') as f:
        json.dump(female_data, f, ensure_ascii=False, indent=2)
    
    with open('sims4_name_generator/assets/data/names/oceania_male.json', 'w', encoding='utf-8') as f:
        json.dump(male_data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated oceania_female.json: {len(female_data['firstNames'])} first names, {len(female_data['lastNames'])} last names")
    print(f"Updated oceania_male.json: {len(male_data['firstNames'])} first names, {len(male_data['lastNames'])} last names")

def main():
    expand_northern_european_files()
    expand_oceania_files()

if __name__ == "__main__":
    main()