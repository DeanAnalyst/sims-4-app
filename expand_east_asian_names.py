#!/usr/bin/env python3
"""
Script to expand East Asian name files with authentic Chinese, Japanese, and Korean names.
"""

import json
import random

# Authentic East Asian names based on 2024 research
CHINESE_FEMALE_NAMES = [
    # Traditional names
    "Li Mei", "Wang Ying", "Zhang Wei", "Liu Fang", "Chen Jing", "Yang Ning", "Zhao Lei", "Wu Xia", "Huang Min", "Zhou Yu",
    "Xu Lan", "Sun Hong", "Ma Li", "Zhu Ping", "Hu Yun", "Guo Qing", "He Jia", "Lin Rui", "Luo Xin", "Song Dan",
    # Modern popular names from 2024
    "Wang Jinyi", "Li Shujing", "Zhang Yutong", "Chen Mengmeng", "Liu Bingbing", "Yang Anna", "Zhao Jingyi", "Wu Shuyi", 
    "Huang Chunfang", "Zhou Aiai", "Xu Chun", "Sun Yue", "Ma Fang", "Zhu Bing", "Hu Meng", "Guo An", "He Yu", 
    "Lin Jing", "Luo Shu", "Song Ai", "Wang Yina", "Li Mengmeng", "Zhang Jingyi", "Chen Shuyi", "Liu Chunfang",
    # More traditional names
    "Yang Aixia", "Zhao Chunfei", "Wu Yueling", "Huang Fanghua", "Zhou Jingru", "Xu Bingjing", "Sun Mengting", 
    "Ma Anna", "Zhu Yutong", "Hu Jingying", "Guo Shuhua", "He Chunjing", "Lin Yuexia", "Luo Fangmei", "Song Jingtong",
    "Wang Shiyu", "Li Xinyi", "Zhang Ruoxi", "Chen Yiran", "Liu Zihan", "Yang Yuchen", "Zhao Xinrui", "Wu Kexin",
    "Huang Yutong", "Zhou Shiqi", "Xu Mengqi", "Sun Ruixi", "Ma Keyi", "Zhu Yuxin", "Hu Ruiqi"
]

CHINESE_MALE_NAMES = [
    # Traditional names  
    "Wang Wei", "Li Ming", "Zhang Qiang", "Liu Jun", "Chen Gang", "Yang Jian", "Zhao Lei", "Wu Bin", "Huang Tao", "Zhou Peng",
    "Xu Dong", "Sun Jie", "Ma Long", "Zhu Feng", "Hu Jun", "Guo Bin", "He Tao", "Lin Wei", "Luo Ming", "Song Gang",
    # Popular modern names
    "Wang Hao", "Li Yang", "Zhang Yu", "Chen Kai", "Liu Bo", "Yang Cheng", "Zhao Han", "Wu Feng", "Huang Jun", "Zhou Qiang",
    "Xu Gang", "Sun Lei", "Ma Bin", "Zhu Tao", "Hu Wei", "Guo Ming", "He Jian", "Lin Dong", "Luo Peng", "Song Jie",
    "Wang Jingtao", "Li Weiming", "Zhang Qiangbin", "Chen Jungang", "Liu Taojian", "Yang Leidong", "Zhao Binpeng", 
    "Wu Fengjie", "Huang Junhao", "Zhou Yangyu", "Xu Kaibo", "Sun Chenhan", "Ma Fengjun", "Zhu Qiangtao", "Hu Weiming"
]

JAPANESE_FEMALE_NAMES = [
    # Traditional names
    "Tanaka Sakura", "Suzuki Yuki", "Takahashi Akiko", "Watanabe Harumi", "Ito Michiko", "Yamamoto Keiko", "Nakamura Tomoko", 
    "Kobayashi Naoko", "Kato Yoko", "Yoshida Reiko", "Yamada Noriko", "Sasaki Kumiko", "Yamaguchi Emiko", "Saito Mariko", 
    "Matsumoto Kyoko", "Inoue Junko", "Kimura Chikako", "Hayashi Satomi", "Shimizu Hiromi", "Yamazaki Mayumi",
    # Modern popular 2024 names
    "Sato Hina", "Tanaka Yui", "Suzuki Aoi", "Takahashi Mei", "Watanabe Rin", "Ito Mio", "Yamamoto Sora", "Nakamura Riko",
    "Kobayashi Emma", "Kato Himari", "Yoshida Kokoro", "Yamada Tsumugi", "Sasaki Ichika", "Yamaguchi Akari", 
    "Saito Honoka", "Matsumoto Miyu", "Inoue Yuna", "Kimura Ema", "Hayashi Rena", "Shimizu Kana", "Yamazaki Aya",
    "Tanaka Hana", "Suzuki Nana", "Takahashi Rika", "Watanabe Saki", "Ito Yuka", "Yamamoto Emi", "Nakamura Ai"
]

JAPANESE_MALE_NAMES = [
    # Traditional names
    "Sato Hiroshi", "Suzuki Takeshi", "Takahashi Akira", "Tanaka Kenji", "Watanabe Shingo", "Ito Masaki", "Yamamoto Daisuke",
    "Nakamura Kazuki", "Kobayashi Yuki", "Kato Taro", "Yoshida Jiro", "Yamada Saburo", "Sasaki Shiro", "Yamaguchi Goro",
    "Saito Rokuro", "Matsumoto Hachi", "Inoue Kyu", "Kimura Ju", "Hayashi Ichiro", "Shimizu Nijo",
    # Modern popular 2024 names
    "Yamazaki Haruto", "Sato Sota", "Tanaka Ren", "Suzuki Riku", "Takahashi Yuto", "Watanabe Hinata", "Ito Asahi",
    "Yamamoto Minato", "Nakamura Kaito", "Kobayashi Yuma", "Kato Sho", "Yoshida Hayato", "Yamada Daiki", "Sasaki Takumi",
    "Yamaguchi Kento", "Saito Ryo", "Matsumoto Yuki", "Inoue Shota", "Kimura Tsubasa", "Hayashi Koki", "Shimizu Raito"
]

KOREAN_FEMALE_NAMES = [
    # Traditional names
    "Kim So-young", "Lee Min-jung", "Park Jung-sook", "Choi Hye-jin", "Jung Mi-kyung", "Kang Sun-hee", "Cho Kyung-ja", 
    "Yoon Young-hee", "Lim Sook-ja", "Han Myung-ja", "Shin Hye-sook", "Oh Sun-ja", "Seo Young-ja", "Kwon Kyung-sook",
    "Moon Hye-kyung", "Ahn Soo-jin", "Jang Min-kyung", "Hong Sung-hee", "Nam Young-sook", "Song Hye-young",
    # Modern popular 2024 names  
    "Kim Yi-seo", "Lee Seo-ah", "Park Ji-yu", "Choi Seo-yeon", "Jung Ha-eun", "Kang Ye-rin", "Cho Min-seo", 
    "Yoon Chae-won", "Lim So-eun", "Han Yu-jin", "Shin Ye-won", "Oh Ha-yeon", "Seo Yu-na", "Kwon Chae-young",
    "Moon So-hyun", "Ahn Ji-woo", "Jang Ye-eun", "Hong Da-eun", "Nam Yu-ri", "Song Min-ji", "Kim Eun-chae", 
    "Lee Bo-ra", "Park Na-eun", "Choi Ga-eun", "Jung So-min", "Kang Hye-jin", "Cho Yu-jin"
]

KOREAN_MALE_NAMES = [
    # Traditional names
    "Kim Min-ho", "Lee Sung-min", "Park Jae-hyun", "Choi Dong-hyun", "Jung Hyun-woo", "Kang Min-gyu", "Cho Seung-hoon",
    "Yoon Jae-min", "Lim Tae-hyun", "Han Kyung-ho", "Shin Jong-soo", "Oh Myung-ho", "Seo Young-ho", "Kwon Hyung-jun",
    "Moon Sung-ho", "Ahn Jin-woo", "Jang Min-ho", "Hong Sung-min", "Nam Young-min", "Song Hye-sung",
    # Modern popular 2024 names
    "Kim Do-yun", "Lee Si-woo", "Park Ha-jun", "Choi Yu-jun", "Jung Ye-jun", "Kang Seo-jun", "Cho Ji-ho",
    "Yoon Min-jun", "Lim Jun-seo", "Han Geon-woo", "Shin Woo-jin", "Oh Hyun-jun", "Seo Jun-woo", "Kwon Do-hyun",
    "Moon Seo-jin", "Ahn Min-gyu", "Jang Ye-chan", "Hong Jun-ho", "Nam Tae-yoon", "Song Woo-bin", "Kim Ji-hun",
    "Lee Jun-young", "Park Seo-woo", "Choi Min-seo", "Jung Ha-ram", "Kang Ye-joon", "Cho Jun-seok"
]

# Combine all names by gender
FEMALE_NAMES = CHINESE_FEMALE_NAMES + JAPANESE_FEMALE_NAMES + KOREAN_FEMALE_NAMES
MALE_NAMES = CHINESE_MALE_NAMES + JAPANESE_MALE_NAMES + KOREAN_MALE_NAMES

# Extract surnames from full names
SURNAMES = list(set([name.split()[0] for name in FEMALE_NAMES + MALE_NAMES]))

def expand_east_asian_files():
    """Expand the East Asian name files with authentic names."""
    
    # Female names
    female_data = {
        "region": "eastAsian",
        "gender": "female",
        "firstNames": sorted(list(set([name.split()[1] for name in FEMALE_NAMES]))),
        "lastNames": sorted(SURNAMES)
    }
    
    # Male names  
    male_data = {
        "region": "eastAsian", 
        "gender": "male",
        "firstNames": sorted(list(set([name.split()[1] for name in MALE_NAMES]))),
        "lastNames": sorted(SURNAMES)
    }
    
    # Write files
    with open('sims4_name_generator/assets/data/names/eastAsian_female.json', 'w', encoding='utf-8') as f:
        json.dump(female_data, f, ensure_ascii=False, indent=2)
    
    with open('sims4_name_generator/assets/data/names/eastAsian_male.json', 'w', encoding='utf-8') as f:
        json.dump(male_data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated eastAsian_female.json: {len(female_data['firstNames'])} first names, {len(female_data['lastNames'])} last names")
    print(f"Updated eastAsian_male.json: {len(male_data['firstNames'])} first names, {len(male_data['lastNames'])} last names")

if __name__ == "__main__":
    expand_east_asian_files()