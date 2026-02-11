import '../models/gamification_models.dart';

/// Complete learning roadmap for AstroLearn
class LearningRoadmap {
  static const List<LearningChapter> chapters = [
    // FOUNDATION - Planets
    LearningChapter(
      id: 'planets_intro',
      title: 'Introduction to Planets',
      description: 'Understand the 9 Grahas and their roles',
      icon: '🪐',
      orderIndex: 1,
      xpReward: 100,
      prerequisites: [],
      lessons: [
        Lesson(
          id: 'planets_intro_reading',
          title: 'Reading: The Grahas',
          content: 'In Vedic Astrology, planets are called Grahas...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'planets_intro_quiz_lesson',
          title: 'Quiz: Planetary Basics',
          content: 'Test your knowledge of the 9 Grahas.',
          xpReward: 100,
          type: LessonType.quiz,
          quizId: 'planets_intro_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'sun_deep_dive',
      title: 'The Sun - Soul & Identity',
      description: 'Master the Sun\'s influence on self and vitality',
      icon: '☉',
      orderIndex: 2,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
        Lesson(
          id: 'sun_reading',
          title: 'Reading: Surya',
          content: 'The Sun represents the Soul, Ego, and Authority...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'sun_quiz_lesson',
          title: 'Quiz: The Sun',
          content: 'Test your knowledge of Surya.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'sun_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'moon_deep_dive',
      title: 'The Moon - Mind & Emotions',
      description: 'Understand emotional patterns and mental peace',
      icon: '☽',
      orderIndex: 3,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'moon_reading',
          title: 'Reading: Chandra',
          content: 'The Moon governs the Mind, Emotions, and Mother...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'moon_quiz_lesson',
          title: 'Quiz: The Moon',
          content: 'Test your knowledge of Chandra.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'moon_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'mars_deep_dive',
      title: 'Mars - Energy & Action',
      description: 'Channel courage and drive effectively',
      icon: '♂',
      orderIndex: 4,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'mars_reading',
          title: 'Reading: Mangal',
          content: 'Mars is the planet of Energy, Action, and Courage...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'mars_quiz_lesson',
          title: 'Quiz: Mars',
          content: 'Test your knowledge of Mangal.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'mars_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'mercury_deep_dive',
      title: 'Mercury - Communication & Intelligence',
      description: 'Develop analytical thinking and expression',
      icon: '☿',
      orderIndex: 5,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'mercury_reading',
          title: 'Reading: Budha',
          content: 'Mercury rules Intellect, Communication, and Humor...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'mercury_quiz_lesson',
          title: 'Quiz: Mercury',
          content: 'Test your knowledge of Budha.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'mercury_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'jupiter_deep_dive',
      title: 'Jupiter - Wisdom & Expansion',
      description: 'Cultivate knowledge and growth mindset',
      icon: '♃',
      orderIndex: 6,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'jupiter_reading',
          title: 'Reading: Brihaspati',
          content: 'Jupiter represents Wisdom, Expansion, and Grace...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'jupiter_quiz_lesson',
          title: 'Quiz: Jupiter',
          content: 'Test your knowledge of Brihaspati.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'jupiter_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'venus_deep_dive',
      title: 'Venus - Love & Beauty',
      description: 'Enhance relationships and creativity',
      icon: '♀',
      orderIndex: 7,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'venus_reading',
          title: 'Reading: Shukra',
          content: 'Venus rules Love, Relationships, and Luxury...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'venus_quiz_lesson',
          title: 'Quiz: Venus',
          content: 'Test your knowledge of Shukra.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'venus_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'saturn_deep_dive',
      title: 'Saturn - Discipline & Karma',
      description: 'Build structure and long-term success',
      icon: '♄',
      orderIndex: 8,
      xpReward: 150,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'saturn_reading',
          title: 'Reading: Shani',
          content: 'Saturn teaches Patience, Discipline, and Time...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'saturn_quiz_lesson',
          title: 'Quiz: Saturn',
          content: 'Test your knowledge of Shani.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'saturn_quiz',
        ),
      ],
      category: 'planets',
    ),
    LearningChapter(
      id: 'rahu_ketu',
      title: 'Rahu & Ketu - Shadow Planets',
      description: 'Navigate desires and spiritual growth',
      icon: '☊☋',
      orderIndex: 9,
      xpReward: 200,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'rahu_ketu_reading',
          title: 'Reading: The Nodes',
          content: 'Rahu is Obsession, Ketu is Detachment...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'rahu_ketu_quiz_lesson',
          title: 'Quiz: Rahu & Ketu',
          content: 'Test your knowledge of the Shadow Planets.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'rahu_ketu_quiz',
        ),
      ],
      category: 'planets',
    ),

    // HOUSES - Life Areas
    LearningChapter(
      id: 'houses_intro',
      title: 'The 12 Houses System',
      description: 'Map your life areas through Bhavas',
      icon: '🏠',
      orderIndex: 10,
      xpReward: 100,
      prerequisites: ['planets_intro'],
      lessons: [
         Lesson(
          id: 'houses_intro_reading',
          title: 'Reading: The Bhavas',
          content: 'The 12 Houses map to different areas of human life...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'houses_intro_quiz_lesson',
          title: 'Quiz: House Basics',
          content: 'Test your knowledge of the Bhava system.',
          xpReward: 100,
          type: LessonType.quiz,
          quizId: 'houses_intro_quiz',
        ),
      ],
      category: 'houses',
    ),
    LearningChapter(
      id: 'houses_1_to_4',
      title: 'Houses 1-4: Self & Foundation',
      description: 'Identity, wealth, courage, and home',
      icon: '🏡',
      orderIndex: 11,
      xpReward: 200,
      prerequisites: ['houses_intro'],
      lessons: [
         Lesson(
          id: 'houses_1_4_reading',
          title: 'Reading: The Foundation',
          content: 'From Self (1st) to Home (4th)...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'houses_1_to_4_quiz_lesson',
          title: 'Quiz: First Quadrant',
          content: 'Test your knowledge of Houses 1-4.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'houses_1_to_4_quiz',
        ),
      ],
      category: 'houses',
    ),
    LearningChapter(
      id: 'houses_5_to_8',
      title: 'Houses 5-8: Creation & Transformation',
      description: 'Creativity, service, partnerships, mysteries',
      icon: '🔄',
      orderIndex: 12,
      xpReward: 200,
      prerequisites: ['houses_intro'],
      lessons: [
         Lesson(
          id: 'houses_5_8_reading',
          title: 'Reading: Development',
          content: 'Creativity (5th) to Transformation (8th)...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'houses_5_to_8_quiz_lesson',
          title: 'Quiz: Second Quadrant',
          content: 'Test your knowledge of Houses 5-8.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'houses_5_to_8_quiz',
        ),
      ],
      category: 'houses',
    ),
    LearningChapter(
      id: 'houses_9_to_12',
      title: 'Houses 9-12: Higher Purpose & Liberation',
      description: 'Dharma, career, gains, and moksha',
      icon: '🌟',
      orderIndex: 13,
      xpReward: 200,
      prerequisites: ['houses_intro'],
      lessons: [
         Lesson(
          id: 'houses_9_12_reading',
          title: 'Reading: Transcendence',
          content: 'Dharma (9th) to Moksha (12th)...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'houses_9_to_12_quiz_lesson',
          title: 'Quiz: Third Quadrant',
          content: 'Test your knowledge of Houses 9-12.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'houses_9_to_12_quiz',
        ),
      ],
      category: 'houses',
    ),

    // SIGNS - Behavioral Patterns
    LearningChapter(
      id: 'signs_intro',
      title: 'The 12 Zodiac Signs',
      description: 'Understand behavioral styles and motivations',
      icon: '♈',
      orderIndex: 14,
      xpReward: 100,
      prerequisites: ['houses_intro'],
      lessons: [
         Lesson(
          id: 'signs_intro_reading',
          title: 'Reading: The Rashis',
          content: 'Zodiac signs (Rashis) flavor the planetary energy...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'signs_intro_quiz_lesson',
          title: 'Quiz: Zodiac Types',
          content: 'Test your knowledge of Sign classifications.',
          xpReward: 100,
          type: LessonType.quiz,
          quizId: 'signs_intro_quiz',
        ),
      ],
      category: 'signs',
    ),
    LearningChapter(
      id: 'fire_signs',
      title: 'Fire Signs: Aries, Leo, Sagittarius',
      description: 'Action, creativity, and inspiration',
      icon: '🔥',
      orderIndex: 15,
      xpReward: 150,
      prerequisites: ['signs_intro'],
      lessons: [
         Lesson(
          id: 'fire_signs_reading',
          title: 'Reading: Agni Tattva',
          content: 'Aries, Leo, Sagittarius...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'fire_signs_quiz_lesson',
          title: 'Quiz: Fire Signs',
          content: 'Check your grasp of the fiery triplicity.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'fire_signs_quiz',
        ),
      ],
      category: 'signs',
    ),
    LearningChapter(
      id: 'earth_signs',
      title: 'Earth Signs: Taurus, Virgo, Capricorn',
      description: 'Stability, service, and achievement',
      icon: '🌍',
      orderIndex: 16,
      xpReward: 150,
      prerequisites: ['signs_intro'],
      lessons: [
         Lesson(
          id: 'earth_signs_reading',
          title: 'Reading: Prithvi Tattva',
          content: 'Taurus, Virgo, Capricorn...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'earth_signs_quiz_lesson',
          title: 'Quiz: Earth Signs',
          content: 'Check your grasp of the earthy triplicity.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'earth_signs_quiz',
        ),
      ],
      category: 'signs',
    ),
    LearningChapter(
      id: 'air_signs',
      title: 'Air Signs: Gemini, Libra, Aquarius',
      description: 'Communication, balance, and innovation',
      icon: '💨',
      orderIndex: 17,
      xpReward: 150,
      prerequisites: ['signs_intro'],
      lessons: [
         Lesson(
          id: 'air_signs_reading',
          title: 'Reading: Vayu Tattva',
          content: 'Gemini, Libra, Aquarius...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'air_signs_quiz_lesson',
          title: 'Quiz: Air Signs',
          content: 'Check your grasp of the airy triplicity.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'air_signs_quiz',
        ),
      ],
      category: 'signs',
    ),
    LearningChapter(
      id: 'water_signs',
      title: 'Water Signs: Cancer, Scorpio, Pisces',
      description: 'Emotion, depth, and transcendence',
      icon: '💧',
      orderIndex: 18,
      xpReward: 150,
      prerequisites: ['signs_intro'],
      lessons: [
         Lesson(
          id: 'water_signs_reading',
          title: 'Reading: Jala Tattva',
          content: 'Cancer, Scorpio, Pisces...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'water_signs_quiz_lesson',
          title: 'Quiz: Water Signs',
          content: 'Check your grasp of the watery triplicity.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'water_signs_quiz',
        ),
      ],
      category: 'signs',
    ),

    // NAKSHATRAS - Subconscious Drivers
    LearningChapter(
      id: 'nakshatras_intro',
      title: 'Introduction to Nakshatras',
      description: 'The 27 lunar mansions and their power',
      icon: '⭐',
      orderIndex: 19,
      xpReward: 150,
      prerequisites: ['signs_intro'],
      lessons: [
         Lesson(
          id: 'nakshatras_intro_reading',
          title: 'Reading: Lunar Mansions',
          content: 'The 27 Nakshatras rule the mind and karma...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'nakshatras_intro_quiz_lesson',
          title: 'Quiz: Nakshatra Basics',
          content: 'Foundation of Lunar Mansions.',
          xpReward: 100,
          type: LessonType.quiz,
          quizId: 'nakshatras_intro_quiz',
        ),
      ],
      category: 'nakshatras',
    ),
    LearningChapter(
      id: 'nakshatras_1_to_9',
      title: 'Nakshatras 1-9: Beginning the Journey',
      description: 'Ashwini to Ashlesha',
      icon: '🌙',
      orderIndex: 20,
      xpReward: 250,
      prerequisites: ['nakshatras_intro'],
      lessons: [
         Lesson(
          id: 'nakshatras_1_9_reading',
          title: 'Reading: The First Cycle',
          content: 'Ashwini to Ashlesha...',
          xpReward: 60,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'nakshatras_1_to_9_quiz_lesson',
          title: 'Quiz: Ashwini-Ashlesha',
          content: 'Journey through the first 9 stars.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'nakshatras_1_to_9_quiz',
        ),
      ],
      category: 'nakshatras',
    ),
    LearningChapter(
      id: 'nakshatras_10_to_18',
      title: 'Nakshatras 10-18: Middle Path',
      description: 'Magha to Jyeshtha',
      icon: '✨',
      orderIndex: 21,
      xpReward: 250,
      prerequisites: ['nakshatras_intro'],
      lessons: [
         Lesson(
          id: 'nakshatras_10_18_reading',
          title: 'Reading: The Middle Cycle',
          content: 'Magha to Jyeshtha...',
          xpReward: 60,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'nakshatras_10_to_18_quiz_lesson',
          title: 'Quiz: Magha-Jyeshtha',
          content: 'Journey through the middle 9 stars.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'nakshatras_10_to_18_quiz',
        ),
      ],
      category: 'nakshatras',
    ),
    LearningChapter(
      id: 'nakshatras_19_to_27',
      title: 'Nakshatras 19-27: Completion',
      description: 'Mula to Revati',
      icon: '🌠',
      orderIndex: 22,
      xpReward: 250,
      prerequisites: ['nakshatras_intro'],
      lessons: [
         Lesson(
          id: 'nakshatras_19_27_reading',
          title: 'Reading: The Final Cycle',
          content: 'Mula to Revati...',
          xpReward: 60,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'nakshatras_19_to_27_quiz_lesson',
          title: 'Quiz: Mula-Revati',
          content: 'Journey through the final 9 stars.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'nakshatras_19_to_27_quiz',
        ),
      ],
      category: 'nakshatras',
    ),

    // DASHA - Time Cycles
    LearningChapter(
      id: 'dasha_basics',
      title: 'Vimshottari Dasha Basics',
      description: 'Understand the 120-year cycle of life timing',
      icon: '⏳',
      orderIndex: 23,
      xpReward: 150,
      prerequisites: ['nakshatras_intro'],
      lessons: [
        Lesson(
          id: 'dasha_intro_reading',
          title: 'Introduction to Life Cycles',
          content: 'The concept of Vimshottari Dasha...',
          xpReward: 50,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'dasha_basics_quiz_lesson',
          title: 'Quiz: Dasha Fundamentals',
          content: 'Test your understanding of the 120-year cycle.',
          xpReward: 100,
          type: LessonType.quiz,
          quizId: 'dasha_basics_quiz',
        ),
      ],
      category: 'dasha',
    ),
    LearningChapter(
      id: 'mahadasha_antardasha',
      title: 'Mahadasha & Antardasha',
      description: 'Main cycles and their subdivisions',
      icon: '🔄',
      orderIndex: 24,
      xpReward: 200,
      prerequisites: ['dasha_basics'],
      lessons: [
        Lesson(
          id: 'md_ad_calculation',
          title: 'MD/AD Calculation',
          content: 'How the cycles are subdivided...',
          xpReward: 70,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'md_ad_quiz_lesson',
          title: 'Quiz: Cycles & Sub-cycles',
          content: 'Challenge yourself on planetary periods.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'md_ad_quiz',
        ),
      ],
      category: 'dasha',
    ),
    LearningChapter(
      id: 'dasha_lagna_advanced',
      title: 'Dasha Lagna (Advanced)',
      description: 'The temporary ascendant and house analysis',
      icon: '🎯',
      orderIndex: 25,
      xpReward: 250,
      prerequisites: ['mahadasha_antardasha'],
      lessons: [
        Lesson(
          id: 'dasha_lagna_concept',
          title: 'The Temporary Ascendant',
          content: 'Analyzing life areas from the Dasha lord...',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'dasha_lagna_quiz_lesson',
          title: 'Quiz: Dasha Lagna Mastery',
          content: 'Prove your advanced predictive knowledge.',
          xpReward: 200,
          type: LessonType.quiz,
          quizId: 'dasha_lagna_quiz',
        ),
      ],
      category: 'dasha',
    ),

    // CHART ANALYSIS - Practical Application
    LearningChapter(
      id: 'chart_reading_basics',
      title: 'Chart Reading Fundamentals',
      description: 'How to analyze a birth chart step-by-step',
      icon: '📊',
      orderIndex: 26,
      xpReward: 200,
      prerequisites: ['houses_9_to_12', 'signs_intro'],
      lessons: [
         Lesson(
          id: 'pac_reading',
          title: 'Reading: PAC Analysis',
          content: 'Position, Aspect, and Conjunction...',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'chart_reading_basics_quiz_lesson',
          title: 'Quiz: Chart Analysis',
          content: 'Test your chart reading foundation.',
          xpReward: 200,
          type: LessonType.quiz,
          quizId: 'chart_reading_basics_quiz',
        ),
      ],
      category: 'analysis',
    ),
    LearningChapter(
      id: 'planet_house_combinations',
      title: 'Planet-House Combinations',
      description: 'Interpret planetary placements',
      icon: '🔗',
      orderIndex: 27,
      xpReward: 300,
      prerequisites: ['chart_reading_basics'],
      lessons: [
         Lesson(
          id: 'combinations_reading',
          title: 'Reading: Yogas',
          content: 'When planets combine, they form Yogas...',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'planet_house_combinations_quiz_lesson',
          title: 'Quiz: Yogas',
          content: 'Interpret planetary interactions.',
          xpReward: 200,
          type: LessonType.quiz,
          quizId: 'planet_house_combinations_quiz',
        ),
      ],
      category: 'analysis',
    ),
    LearningChapter(
      id: 'asking_questions',
      title: 'Asking the Right Questions',
      description: 'Career, marriage, wealth, health analysis',
      icon: '❓',
      orderIndex: 28,
      xpReward: 250,
      prerequisites: ['chart_reading_basics'],
      lessons: [
         Lesson(
          id: 'analysis_reading',
          title: 'Reading: Specific Topics',
          content: 'How to look for career, marriage, etc...',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'asking_questions_quiz_lesson',
          title: 'Quiz: Focused Analysis',
          content: 'Apply your knowledge to life areas.',
          xpReward: 200,
          type: LessonType.quiz,
          quizId: 'asking_questions_quiz',
        ),
      ],
      category: 'analysis',
    ),
    LearningChapter(
      id: 'remedies_practical',
      title: 'Practical Remedies & Actions',
      description: 'Behavioral changes for planetary strength',
      icon: '🎯',
      orderIndex: 29,
      xpReward: 200,
      prerequisites: ['planet_house_combinations'],
      lessons: [
         Lesson(
          id: 'remedies_reading',
          title: 'Reading: Upayas',
          content: 'Practices to balance planetary energies...',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'remedies_practical_quiz_lesson',
          title: 'Quiz: Remedies',
          content: 'Understanding corrective measures.',
          xpReward: 200,
          type: LessonType.quiz,
          quizId: 'remedies_practical_quiz',
        ),
      ],
      category: 'analysis',
    ),

    // DIAGNOSTIC - Weakness Indicators
    LearningChapter(
      id: 'planet_weakness',
      title: 'Signs of Weak Planets',
      description: 'Identify when planetary energy is blocked or weak',
      icon: '⚠️',
      orderIndex: 30,
      xpReward: 200,
      prerequisites: ['remedies_practical'],
      lessons: [
        Lesson(
          id: 'planet_weakness_reading',
          title: 'Reading: Recognizing Weak Planets',
          content: '''A planet is weak when it cannot deliver its natural significations.

☀️ WEAK SUN shows as: Lack of confidence, fear of visibility, strained relationship with authority, low vitality, weak sense of purpose.
→ Core insight: A weak Sun doesn't mean lack of talent — it means identity is not integrated.

🌙 WEAK MOON shows as: Emotional instability, anxiety, attachment issues, poor memory, fear of change.
→ Core insight: A weak Moon shows emotional processing issues, not weakness of character.

♂️ WEAK MARS shows as: Low physical drive, avoidance of confrontation, suppressed anger, fear of taking risks.
→ Core insight: Weak Mars shows blocked assertive energy, not lack of ambition.

☿ WEAK MERCURY shows as: Difficulty articulating thoughts, confusion, nervousness in communication, scattered thinking.
→ Core insight: Weak Mercury shows poor signal clarity, not low intelligence.

♃ WEAK JUPITER shows as: Loss of faith, poor guidance, narrow worldview, difficulty with ethics.
→ Core insight: Weak Jupiter indicates misalignment with wisdom, not lack of intelligence.

♀️ WEAK VENUS shows as: Relationship dissatisfaction, difficulty experiencing joy, poor self-worth, creative blocks.
→ Core insight: Weak Venus reflects distorted value systems, not lack of love.

♄ WEAK SATURN shows as: Fear of responsibility, procrastination, difficulty with routines, feeling overwhelmed.
→ Core insight: Weak Saturn causes collapse under pressure, not lack of ability.

☊ WEAK RAHU shows as: Lack of ambition, resistance to change, missed opportunities, fear of public exposure.
→ Core insight: Weak Rahu shows blocked evolution, not purity.

☋ WEAK KETU shows as: Spiritual confusion, feeling disconnected, difficulty trusting intuition, escapism.
→ Core insight: Weak Ketu creates confusion, not enlightenment.

🔑 MASTER RULE: A planet is weak when its energy cannot be expressed consciously, constructively, and consistently. Weakness ≠ bad fate. Weakness = area requiring conscious development.''',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'planet_weakness_quiz_lesson',
          title: 'Quiz: Diagnosing Weak Planets',
          content: 'Test your ability to identify planetary weakness patterns.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'planet_weakness_quiz',
        ),
      ],
      category: 'diagnostic',
    ),
    LearningChapter(
      id: 'house_weakness',
      title: 'Signs of Weak Houses',
      description: 'Recognize when life areas struggle to manifest',
      icon: '🏚️',
      orderIndex: 31,
      xpReward: 200,
      prerequisites: ['planet_weakness'],
      lessons: [
        Lesson(
          id: 'house_weakness_reading',
          title: 'Reading: Recognizing Weak Houses',
          content: '''A house is weak when its life themes cause fear, avoidance, or repeated struggle.

🏠 1st House Weak: Unstable identity, low confidence, health issues without diagnosis, feeling "lost".
→ Key: The 1st house affects everything, because all houses flow through it.

🏠 2nd House Weak: Financial instability, harsh speech, strained family, low self-worth.
→ Key: Disturbs both money and self-valuation.

🏠 3rd House Weak: Lack of initiative, fear of risks, communication hesitation, sibling issues.
→ Key: Effort exists but courage collapses.

🏠 4th House Weak: Lack of inner peace, emotional restlessness, unstable home, difficulty relaxing.
→ Key: Affects mental peace, not just property.

🏠 5th House Weak: Creative blocks, fear of self-expression, poor decision-making, loss of curiosity.
→ Key: Dims joy and confidence in one's mind.

🏠 6th House Weak: Recurrent health problems, difficulty handling stress, workplace conflicts.
→ Key: Makes small problems feel overwhelming.

🏠 7th House Weak: Relationship dissatisfaction, trust issues, delayed marriage, fear of commitment.
→ Key: Reflects imbalance in one-to-one energy.

🏠 8th House Weak: Fear of change, anxiety about losses, emotional instability, trust issues.
→ Key: Causes fear of the unknown, not just misfortune.

🏠 9th House Weak: Loss of faith, poor guidance, luck not supporting effort, philosophical confusion.
→ Key: Blocks grace and guidance, not effort.

🏠 10th House Weak: Career instability, lack of recognition, fear of responsibility, feeling stuck.
→ Key: Affects karma execution, not talent.

🏠 11th House Weak: Difficulty achieving goals, income instability, weak networks, social isolation.
→ Key: Delays rewards, not effort.

🏠 12th House Weak: Excessive expenses, sleep issues, mental exhaustion, escapism, fear of solitude.
→ Key: Creates unconscious leakage of energy.

🔑 MASTER RULE: A house is judged by its lord first, not by occupancy. A house becomes strong when its responsibilities are faced consciously.''',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'house_weakness_quiz_lesson',
          title: 'Quiz: Diagnosing Weak Houses',
          content: 'Test your ability to identify house weakness patterns.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'house_weakness_quiz',
        ),
      ],
      category: 'diagnostic',
    ),
    LearningChapter(
      id: 'sign_weakness',
      title: 'Signs of Weak Zodiac Signs',
      description: 'Identify when sign energy is blocked or distorted',
      icon: '♈⚠️',
      orderIndex: 32,
      xpReward: 200,
      prerequisites: ['house_weakness'],
      lessons: [
        Lesson(
          id: 'sign_weakness_reading',
          title: 'Reading: Recognizing Weak Signs',
          content: '''A zodiac sign is weak when its core energy is expressed through fear or imbalance.

♈ WEAK ARIES: Difficulty initiating, fear of taking first step, procrastination, lack of assertiveness.
→ Core insight: Blocked momentum, not laziness.

♉ WEAK TAURUS: Financial insecurity, difficulty with routines, fear of change, attachment anxiety.
→ Core insight: Fear-based attachment, not simplicity.

♊ WEAK GEMINI: Confusion expressing ideas, mental restlessness, learning anxiety, scattered thinking.
→ Core insight: Noise without signal.

♋ WEAK CANCER: Emotional insecurity, fear of abandonment, mood instability, difficulty with boundaries.
→ Core insight: Unprotected emotions.

♌ WEAK LEO: Low self-esteem, fear of visibility, over-dependence on validation, suppressed creativity.
→ Core insight: Dimmed inner fire, not lack of talent.

♍ WEAK VIRGO: Over-critical thinking, anxiety over details, perfection paralysis, excessive worry.
→ Core insight: Analysis without confidence.

♎ WEAK LIBRA: Decision difficulty, people-pleasing, fear of conflict, suppressed personal needs.
→ Core insight: Peace at the cost of self.

♏ WEAK SCORPIO: Fear of emotional intensity, trust issues, difficulty letting go, resistance to change.
→ Core insight: Blocked transformation.

♐ WEAK SAGITTARIUS: Loss of optimism, lack of long-term vision, cynicism, difficulty committing to ideals.
→ Core insight: Directionless freedom.

♑ WEAK CAPRICORN: Fear of responsibility, procrastination despite ambition, poor time management, burnout.
→ Core insight: Ambition without structure.

♒ WEAK AQUARIUS: Emotional detachment without clarity, feeling alienated, difficulty integrating into groups.
→ Core insight: Detachment without vision.

♓ WEAK PISCES: Escapism, difficulty maintaining boundaries, victim mentality, spiritual confusion.
→ Core insight: Sensitivity without grounding.

🔑 MASTER RULE: A sign becomes weak when its core quality is lived through fear or avoidance instead of conscious expression.''',
          xpReward: 80,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'sign_weakness_quiz_lesson',
          title: 'Quiz: Diagnosing Weak Signs',
          content: 'Test your ability to identify sign weakness patterns.',
          xpReward: 150,
          type: LessonType.quiz,
          quizId: 'sign_weakness_quiz',
        ),
      ],
      category: 'diagnostic',
    ),
    LearningChapter(
      id: 'strengthening_practices',
      title: 'Strengthening Planets, Houses & Signs',
      description: 'Behavioral and lifestyle remedies for weakness',
      icon: '💪',
      orderIndex: 33,
      xpReward: 250,
      prerequisites: ['sign_weakness'],
      lessons: [
        Lesson(
          id: 'strengthening_reading',
          title: 'Reading: Conscious Remedies',
          content: '''The most powerful remedy is living the planet's principle consciously.

🔑 CORE RULE: A planet is strengthened most when you live its principles, not through rituals alone.

☀️ STRENGTHEN SUN: Wake early, take responsibility, maintain self-respect, speak truth, respect authority.

🌙 STRENGTHEN MOON: Stable routines, emotional awareness, time in nature, care for mother, practice gratitude.

♂️ STRENGTHEN MARS: Physical exercise, take initiative, practice saying "no", finish what you start.

☿ STRENGTHEN MERCURY: Clear communication, learn continuously, simplify thoughts, read daily.

♃ STRENGTHEN JUPITER: Respect teachers, study philosophy, practice generosity, keep promises.

♀️ STRENGTHEN VENUS: Self-care, balanced relationships, enjoy beauty, express affection honestly.

♄ STRENGTHEN SATURN: Consistent routines, accept responsibility, patience during delays, serve honestly.

☊ STRENGTHEN RAHU: Embrace change, learn new skills, step outside comfort zone, channel ambition.

☋ STRENGTHEN KETU: Practice meditation, let go of attachments, trust intuition, accept uncertainty.

FOR HOUSES: Strengthen by consciously engaging with that life area instead of avoiding it.

FOR SIGNS: Strengthen by expressing the sign's core quality with confidence and balance.

🌟 MASTER INSIGHT: "Weak does not mean bad. Weak means conscious effort is required."''',
          xpReward: 100,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'strengthening_quiz_lesson',
          title: 'Quiz: Remedies & Strengthening',
          content: 'Test your grasp of conscious strengthening practices.',
          xpReward: 200,
          type: LessonType.quiz,
          quizId: 'strengthening_quiz',
        ),
      ],
      category: 'diagnostic',
    ),

    LearningChapter(
      id: 'mastery_integration',
      title: 'Integration & Mastery',
      description: 'Synthesize all knowledge for self-awareness',
      icon: '🏆',
      orderIndex: 34,
      xpReward: 500,
      prerequisites: ['strengthening_practices'],
      lessons: [
         Lesson(
          id: 'final_reading',
          title: 'Reading: Integration',
          content: 'Viewing the chart as a whole...',
          xpReward: 100,
          type: LessonType.reading,
        ),
        Lesson(
          id: 'mastery_integration_quiz_lesson',
          title: 'Quiz: Ultimate Mastery',
          content: 'The final test of your Jyotish journey.',
          xpReward: 500,
          type: LessonType.quiz,
          quizId: 'mastery_integration_quiz',
        ),
      ],
      category: 'analysis',
    ),
  ];

  static LearningChapter? getChapterById(String id) {
    try {
      return chapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<LearningChapter> getChaptersByCategory(String category) {
    return chapters.where((c) => c.category == category).toList();
  }

  static List<LearningChapter> getUnlockedChapters(Map<String, ChapterProgress> progress) {
    return chapters.where((chapter) {
      if (chapter.prerequisites.isEmpty) return true;
      return chapter.prerequisites.every((prereq) {
        final prereqProgress = progress[prereq];
        return prereqProgress != null && prereqProgress.isCompleted;
      });
    }).toList();
  }
}

/// Achievement definitions
class Achievements {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first chapter',
      icon: '👣',
      xpReward: 50,
      type: AchievementType.chaptersCompleted,
      targetValue: 1,
    ),
    Achievement(
      id: 'planet_explorer',
      title: 'Planet Explorer',
      description: 'Learn about all 9 planets',
      icon: '🪐',
      xpReward: 200,
      type: AchievementType.planetsLearned,
      targetValue: 9,
    ),
    Achievement(
      id: 'house_master',
      title: 'House Master',
      description: 'Complete all house chapters',
      icon: '🏠',
      xpReward: 200,
      type: AchievementType.housesLearned,
      targetValue: 12,
    ),
    Achievement(
      id: 'sign_sage',
      title: 'Sign Sage',
      description: 'Master all 12 zodiac signs',
      icon: '♈',
      xpReward: 200,
      type: AchievementType.signsLearned,
      targetValue: 12,
    ),
    Achievement(
      id: 'nakshatra_adept',
      title: 'Nakshatra Adept',
      description: 'Study all 27 nakshatras',
      icon: '⭐',
      xpReward: 300,
      type: AchievementType.nakshatrasLearned,
      targetValue: 27,
    ),
    Achievement(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day learning streak',
      icon: '🔥',
      xpReward: 100,
      type: AchievementType.daysStreak,
      targetValue: 7,
    ),
    Achievement(
      id: 'dedicated_student',
      title: 'Dedicated Student',
      description: '30-day learning streak',
      icon: '📚',
      xpReward: 500,
      type: AchievementType.daysStreak,
      targetValue: 30,
    ),
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach Level 5',
      icon: '⭐',
      xpReward: 100,
      type: AchievementType.levelReached,
      targetValue: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Astrology Enthusiast',
      description: 'Reach Level 10',
      icon: '🌟',
      xpReward: 250,
      type: AchievementType.levelReached,
      targetValue: 10,
    ),
    Achievement(
      id: 'level_20',
      title: 'Vedic Scholar',
      description: 'Reach Level 20',
      icon: '✨',
      xpReward: 500,
      type: AchievementType.levelReached,
      targetValue: 20,
    ),
    Achievement(
      id: 'completionist',
      title: 'Completionist',
      description: 'Complete all chapters',
      icon: '🏆',
      xpReward: 1000,
      type: AchievementType.chaptersCompleted,
      targetValue: 30,
    ),
  ];
}
