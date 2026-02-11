import '../models/gamification_models.dart';

class QuizData {
  static const Map<String, Quiz> quizzes = {
    // Dasha Basics Quiz
    'dasha_basics_quiz': Quiz(
      id: 'dasha_basics_quiz',
      title: 'Vimshottari Dasha Basics',
      description: 'Test your knowledge of the 120-year cycle',
      xpReward: 100,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is the total duration of the Vimshottari Dasha cycle?',
          options: [
            QuizOption(id: 'a', text: '100 years', isCorrect: false),
            QuizOption(id: 'b', text: '120 years', isCorrect: true),
            QuizOption(id: 'c', text: '108 years', isCorrect: false),
            QuizOption(id: 'd', text: 'Lifetime', isCorrect: false),
          ],
          explanation: 'The full Vimshottari cycle is 120 years, representing the full potential human lifespan in Vedic astrology.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which factor determines your starting Dasha at birth?',
          options: [
            QuizOption(id: 'a', text: 'Sun Nakshatra', isCorrect: false),
            QuizOption(id: 'b', text: 'Ascendant (Lagna) Nakshatra', isCorrect: false),
            QuizOption(id: 'c', text: 'Moon\'s Nakshatra', isCorrect: true),
            QuizOption(id: 'd', text: 'Lagna Lord Nakshatra', isCorrect: false),
          ],
          explanation: 'The starting Dasha is calculated based on the exact degree of the Moon within its Nakshatra at the time of birth.',
        ),
        QuizQuestion(
          id: 'q3',
          text: 'How many planets are involved in the Dasha system?',
          options: [
            QuizOption(id: 'a', text: '7', isCorrect: false),
            QuizOption(id: 'b', text: '9 (including Rahu/Ketu)', isCorrect: true),
            QuizOption(id: 'c', text: '12', isCorrect: false),
            QuizOption(id: 'd', text: '5', isCorrect: false),
          ],
          explanation: 'The system uses the 9 grahas: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, and Ketu.',
        ),
      ],
    ),

    // Mahadasha & Antardasha Quiz
    'md_ad_quiz': Quiz(
      id: 'md_ad_quiz',
      title: 'Cycles Within Cycles',
      description: 'Master the relationship between Major and Minor periods',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is a "Mahadasha"?',
          options: [
            QuizOption(id: 'a', text: 'A minor daily period', isCorrect: false),
            QuizOption(id: 'b', text: 'The major planetary period', isCorrect: true),
            QuizOption(id: 'c', text: 'A period of bad luck', isCorrect: false),
            QuizOption(id: 'd', text: 'The yearly transit', isCorrect: false),
          ],
          explanation: 'Mahadasha is the "Great Period" or major cycle which sets the overall themes for that chapter of your life.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which planet has the longest Mahadasha period?',
          options: [
            QuizOption(id: 'a', text: 'Saturn (19 years)', isCorrect: false),
            QuizOption(id: 'b', text: 'Venus (20 years)', isCorrect: true),
            QuizOption(id: 'c', text: 'Rahu (18 years)', isCorrect: false),
            QuizOption(id: 'd', text: 'Jupiter (16 years)', isCorrect: false),
          ],
          explanation: 'Venus has the longest duration of 20 years, followed by Saturn with 19 years.',
        ),
        QuizQuestion(
          id: 'q3',
          text: 'What is the "Antardasha"?',
          options: [
            QuizOption(id: 'a', text: 'The sub-period within a Mahadasha', isCorrect: true),
            QuizOption(id: 'b', text: 'The period before birth', isCorrect: false),
            QuizOption(id: 'c', text: 'An alternative Dasha system', isCorrect: false),
            QuizOption(id: 'd', text: 'A transit chart', isCorrect: false),
          ],
          explanation: 'Antardasha is the sub-period that brings specific events and flavor to the broader Mahadasha theme.',
        ),
      ],
    ),

    // Dasha Lagna Quiz
    'dasha_lagna_quiz': Quiz(
      id: 'dasha_lagna_quiz',
      title: 'Dasha Lagna Mastery',
      description: 'Advanced check: Understanding temporary ascendants',
      xpReward: 200,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What becomes the "Dasha Lagna" (Temporary Ascendant)?',
          options: [
            QuizOption(id: 'a', text: 'The house of the Moon', isCorrect: false),
            QuizOption(id: 'b', text: 'The house where the Mahadasha Lord is placed', isCorrect: true),
            QuizOption(id: 'c', text: 'The 10th house', isCorrect: false),
            QuizOption(id: 'd', text: 'The current transit ascendant', isCorrect: false),
          ],
          explanation: 'For the duration of a Mahadasha, the house occupied by its ruling planet acts as a temporary Ascendant (Dasha Lagna).',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Why is Dasha Lagna important?',
          options: [
            QuizOption(id: 'a', text: 'It predicts exact dates', isCorrect: false),
            QuizOption(id: 'b', text: 'It replaces the Birth Chart permanently', isCorrect: false),
            QuizOption(id: 'c', text: 'It shows the focus and perspective of the current period', isCorrect: true),
            QuizOption(id: 'd', text: 'It determines your career only', isCorrect: false),
          ],
          explanation: 'Dasha Lagna shifts your chart\'s perspective, showing which life areas (houses) become the primary focus during that period.',
        ),
        QuizQuestion(
          id: 'q3',
          text: 'If MD Lord is in the 10th house (Career), what becomes the focus?',
          options: [
            QuizOption(id: 'a', text: 'Home and Mother', isCorrect: false),
            QuizOption(id: 'b', text: 'Career, status, and public action', isCorrect: true),
            QuizOption(id: 'c', text: 'Spirituality and loss', isCorrect: false),
            QuizOption(id: 'd', text: 'Siblings', isCorrect: false),
          ],
          explanation: 'Since the MD Lord is in the 10th, career and public status themes become central, effectively leading the chart for that time.',
        ),
      ],
    ),
    
    // ==========================================
    // PLANET QUIZZES
    // ==========================================
    
    'planets_intro_quiz': Quiz(
      id: 'planets_intro_quiz',
      title: 'Planetary Basics',
      description: 'Test your knowledge of the 9 Grahas.',
      xpReward: 100,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What does "Graha" primarily mean in Vedic Astrology?',
          options: [
            QuizOption(id: 'a', text: 'Planet', isCorrect: false),
            QuizOption(id: 'b', text: 'Seizer or Grasper', isCorrect: true),
            QuizOption(id: 'c', text: 'Star', isCorrect: false),
            QuizOption(id: 'd', text: 'God', isCorrect: false),
          ],
          explanation: 'While we call them planets, "Graha" means "to seize" or "grasp," indicating how they take hold of our karma.',
        ),
        QuizQuestion(
           id: 'q2',
           text: 'How many main Grahas are used in Vedic Astrology?',
           options: [
             QuizOption(id: 'a', text: '7', isCorrect: false),
             QuizOption(id: 'b', text: '9', isCorrect: true),
             QuizOption(id: 'c', text: '10', isCorrect: false),
             QuizOption(id: 'd', text: '12', isCorrect: false),
           ],
           explanation: 'There are 9 Grahas (Navagrahas): Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, and Ketu.',
        ),
      ],
    ),
    
    'sun_quiz': Quiz(
      id: 'sun_quiz',
      title: 'The Sun (Surya)',
      description: 'Understanding the King of Planets.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What does the Sun represent in a chart?',
          options: [
            QuizOption(id: 'a', text: 'Emotions', isCorrect: false),
            QuizOption(id: 'b', text: 'Soul and Ego', isCorrect: true),
            QuizOption(id: 'c', text: 'Communication', isCorrect: false),
            QuizOption(id: 'd', text: 'Discipline', isCorrect: false),
          ],
          explanation: 'The Sun (Surya) represents the Soul (Atman), Ego, Vitality, and Father.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which sign does the Sun rule?',
          options: [
            QuizOption(id: 'a', text: 'Aries', isCorrect: false),
            QuizOption(id: 'b', text: 'Leo', isCorrect: true),
            QuizOption(id: 'c', text: 'Sagittarius', isCorrect: false),
            QuizOption(id: 'd', text: 'Cancer', isCorrect: false),
          ],
          explanation: 'The Sun is the ruler of Leo (Simha).',
        ),
      ],
    ),

    'moon_quiz': Quiz(
      id: 'moon_quiz',
      title: 'The Moon (Chandra)',
      description: 'Understanding the Queen of Planets.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is the primary signification of the Moon?',
          options: [
            QuizOption(id: 'a', text: 'Mind and Emotions', isCorrect: true),
            QuizOption(id: 'b', text: 'Physical Strength', isCorrect: false),
            QuizOption(id: 'c', text: 'Career', isCorrect: false),
            QuizOption(id: 'd', text: 'Spirituality', isCorrect: false),
          ],
          explanation: 'The Moon (Chandra) rules the Mind (Manas), Emotions, and Comfort.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which sign is the Moon\'s own sign?',
          options: [
            QuizOption(id: 'a', text: 'Taurus', isCorrect: false),
            QuizOption(id: 'b', text: 'Cancer', isCorrect: true),
            QuizOption(id: 'c', text: 'Pisces', isCorrect: false),
            QuizOption(id: 'd', text: 'Gemini', isCorrect: false),
          ],
          explanation: 'The Moon rules Cancer (Karka).',
        ),
      ],
    ),
    
    'mars_quiz': Quiz(
      id: 'mars_quiz',
      title: 'Mars (Mangal)',
      description: 'The General of the Planetary Army.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What quality does Mars represent?',
          options: [
            QuizOption(id: 'a', text: 'Wisdom', isCorrect: false),
            QuizOption(id: 'b', text: 'Courage and Action', isCorrect: true),
            QuizOption(id: 'c', text: 'Laziness', isCorrect: false),
            QuizOption(id: 'd', text: 'Beauty', isCorrect: false),
          ],
          explanation: 'Mars (Mangal) represents Energy, Action, Courage, and Aggression.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which signs does Mars rule?',
          options: [
            QuizOption(id: 'a', text: 'Aries and Scorpio', isCorrect: true),
            QuizOption(id: 'b', text: 'Taurus and Libra', isCorrect: false),
            QuizOption(id: 'c', text: 'Gemini and Virgo', isCorrect: false),
            QuizOption(id: 'd', text: 'Sagittarius and Pisces', isCorrect: false),
          ],
          explanation: 'Mars rules both Aries (Mesha) and Scorpio (Vrishchika).',
        ),
      ],
    ),

    'mercury_quiz': Quiz(
      id: 'mercury_quiz',
      title: 'Mercury (Budha)',
      description: 'The Prince of Communication.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Mercury is the karaka (significator) for what?',
          options: [
            QuizOption(id: 'a', text: 'Land and Property', isCorrect: false),
            QuizOption(id: 'b', text: 'Intelligence and Speech', isCorrect: true),
            QuizOption(id: 'c', text: 'Spiritual Liberation', isCorrect: false),
            QuizOption(id: 'd', text: 'Longevity', isCorrect: false),
          ],
          explanation: 'Mercury (Budha) signifies Intellect (Buddhi), Speech (Vak), and Communication.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which signs are owned by Mercury?',
          options: [
            QuizOption(id: 'a', text: 'Cancer and Leo', isCorrect: false),
            QuizOption(id: 'b', text: 'Gemini and Virgo', isCorrect: true),
            QuizOption(id: 'c', text: 'Capricorn and Aquarius', isCorrect: false),
            QuizOption(id: 'd', text: 'Libra and Taurus', isCorrect: false),
          ],
          explanation: 'Mercury rules Gemini (Mithuna) and Virgo (Kanya).',
        ),
      ],
    ),

    'jupiter_quiz': Quiz(
      id: 'jupiter_quiz',
      title: 'Jupiter (Brihaspati)',
      description: 'The Guru and Planet of Expansion.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Jupiter is known as the glorious planet of...',
          options: [
            QuizOption(id: 'a', text: 'Restriction', isCorrect: false),
            QuizOption(id: 'b', text: 'Wisdom and Luck', isCorrect: true),
            QuizOption(id: 'c', text: 'Passion', isCorrect: false),
            QuizOption(id: 'd', text: 'Illusion', isCorrect: false),
          ],
          explanation: 'Jupiter (Guru) represents Wisdom, Expansion, Optimism, and Dharma.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which signs are ruled by Jupiter?',
          options: [
            QuizOption(id: 'a', text: 'Sagittarius and Pisces', isCorrect: true),
            QuizOption(id: 'b', text: 'Aries and Leo', isCorrect: false),
            QuizOption(id: 'c', text: 'Virgo and Gemini', isCorrect: false),
            QuizOption(id: 'd', text: 'Taurus and Libra', isCorrect: false),
          ],
          explanation: 'Jupiter rules Sagittarius (Dhanu) and Pisces (Meena).',
        ),
      ],
    ),

    'venus_quiz': Quiz(
      id: 'venus_quiz',
      title: 'Venus (Shukra)',
      description: 'Love, Beauty, and Luxury.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What does Venus signify?',
          options: [
            QuizOption(id: 'a', text: 'War and Conflict', isCorrect: false),
            QuizOption(id: 'b', text: 'Relationships and Luxury', isCorrect: true),
            QuizOption(id: 'c', text: 'Hard Work', isCorrect: false),
            QuizOption(id: 'd', text: 'Detachment', isCorrect: false),
          ],
          explanation: 'Venus (Shukra) is the planet of Love, Relationships, Vehicles, and Luxury.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which pair of signs does Venus rule?',
          options: [
            QuizOption(id: 'a', text: 'Aries and Scorpio', isCorrect: false),
            QuizOption(id: 'b', text: 'Taurus and Libra', isCorrect: true),
            QuizOption(id: 'c', text: 'Cancer and Leo', isCorrect: false),
            QuizOption(id: 'd', text: 'Gemini and Virgo', isCorrect: false),
          ],
          explanation: 'Venus rules Taurus (Vrishabha) and Libra (Tula).',
        ),
      ],
    ),

    'saturn_quiz': Quiz(
      id: 'saturn_quiz',
      title: 'Saturn (Shani)',
      description: 'The Taskmaster and Lord of Karma.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is Saturn\'s primary role?',
          options: [
            QuizOption(id: 'a', text: 'To bring quick happiness', isCorrect: false),
            QuizOption(id: 'b', text: 'To teach through delayed results and discipline', isCorrect: true),
            QuizOption(id: 'c', text: 'To enhance communication', isCorrect: false),
            QuizOption(id: 'd', text: 'To cause confusion', isCorrect: false),
          ],
          explanation: 'Saturn (Shani) represents Discipline, Time, Delay, and the fruits of hard work (Karma).',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which signs are governed by Saturn?',
          options: [
            QuizOption(id: 'a', text: 'Capricorn and Aquarius', isCorrect: true),
            QuizOption(id: 'b', text: 'Sagittarius and Pisces', isCorrect: false),
            QuizOption(id: 'c', text: 'Aries and Scorpio', isCorrect: false),
            QuizOption(id: 'd', text: 'Leo and Cancer', isCorrect: false),
          ],
          explanation: 'Saturn rules Capricorn (Makara) and Aquarius (Kumbha).',
        ),
      ],
    ),

    'rahu_ketu_quiz': Quiz(
      id: 'rahu_ketu_quiz',
      title: 'Rahu & Ketu',
      description: 'The Shadow Nodes of the Moon.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is Rahu known for?',
          options: [
            QuizOption(id: 'a', text: 'Detachment and Spirituality', isCorrect: false),
            QuizOption(id: 'b', text: 'Obsession and Material Desire', isCorrect: true),
            QuizOption(id: 'c', text: 'Harmony and Balance', isCorrect: false),
            QuizOption(id: 'd', text: 'Discipline', isCorrect: false),
          ],
          explanation: 'Rahu represents Obsession, Innovation, Foreign things, and insatiable Desire.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'What does Ketu represent?',
          options: [
            QuizOption(id: 'a', text: 'Expansion', isCorrect: false),
            QuizOption(id: 'b', text: 'Liberation (Moksha) and Detachment', isCorrect: true),
            QuizOption(id: 'c', text: 'Communication', isCorrect: false),
            QuizOption(id: 'd', text: 'Luxury', isCorrect: false),
          ],
          explanation: 'Ketu represents Detachment, Past Life Karma, and Spiritual Liberation (Moksha).',
        ),
      ],
    ),
    // ==========================================
    // HOUSE QUIZZES
    // ==========================================
    
    'houses_intro_quiz': Quiz(
      id: 'houses_intro_quiz',
      title: 'The 12 Houses',
      description: 'Understanding the Bhavas.',
      xpReward: 100,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What does a "House" (Bhava) represented in a chart?',
          options: [
            QuizOption(id: 'a', text: 'A specific area of life', isCorrect: true),
            QuizOption(id: 'b', text: 'A planet\'s strength', isCorrect: false),
            QuizOption(id: 'c', text: 'A future prediction', isCorrect: false),
            QuizOption(id: 'd', text: 'A personality trait', isCorrect: false),
          ],
          explanation: 'Houses (Bhavas) represent specific fields of action or areas of life where planetary energies play out.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which house is considered the most important cornerstones (Kendra)?',
          options: [
            QuizOption(id: 'a', text: '1, 4, 7, 10', isCorrect: true),
            QuizOption(id: 'b', text: '2, 5, 8, 11', isCorrect: false),
            QuizOption(id: 'c', text: '3, 6, 9, 12', isCorrect: false),
            QuizOption(id: 'd', text: '1, 5, 9', isCorrect: false),
          ],
          explanation: 'The Kendra houses (1, 4, 7, 10) are the pillars of the chart, representing the core structure of life.',
        ),
      ],
    ),

    'houses_1_to_4_quiz': Quiz(
      id: 'houses_1_to_4_quiz',
      title: 'Houses 1-4: The Foundation',
      description: 'Self, Wealth, Courage, and Home.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'The 1st House (Ascendant) represents...',
          options: [
            QuizOption(id: 'a', text: 'Wealth and Family', isCorrect: false),
            QuizOption(id: 'b', text: 'Self, Body, and Personality', isCorrect: true),
            QuizOption(id: 'c', text: 'Career', isCorrect: false),
            QuizOption(id: 'd', text: 'Losses', isCorrect: false),
          ],
          explanation: 'The 1st House is the Tanu Bhava, representing the self, physical body, and general orientation to life.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'What is the primary signification of the 4th House?',
          options: [
            QuizOption(id: 'a', text: 'Siblings and Courage', isCorrect: false),
            QuizOption(id: 'b', text: 'Home, Mother, and Happiness', isCorrect: true),
            QuizOption(id: 'c', text: 'Enemies', isCorrect: false),
            QuizOption(id: 'd', text: 'Marriage', isCorrect: false),
          ],
          explanation: 'The 4th House rules the Home, Mother (Matru Bhava), inner peace, and vehicles.',
        ),
      ],
    ),

    'houses_5_to_8_quiz': Quiz(
      id: 'houses_5_to_8_quiz',
      title: 'Houses 5-8: Creation & Transformation',
      description: 'Creativity, Struggle, Relationships, and Mystery.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'The 5th House is arguably the most auspicious house for...',
          options: [
            QuizOption(id: 'a', text: 'Health Problems', isCorrect: false),
            QuizOption(id: 'b', text: 'Creativity, Children, and Good Karma', isCorrect: true),
            QuizOption(id: 'c', text: 'Foreign Travel', isCorrect: false),
            QuizOption(id: 'd', text: 'Career Success', isCorrect: false),
          ],
          explanation: 'The 5th House (Putra Bhava) governs Creativity, Children, Romance, and Past Life Merit (Purva Punya).',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'What makes the 8th House challenging?',
          options: [
            QuizOption(id: 'a', text: 'It deals with transformation, death, and sudden events', isCorrect: true),
            QuizOption(id: 'b', text: 'It rules expenses', isCorrect: false),
            QuizOption(id: 'c', text: 'It rules career', isCorrect: false),
            QuizOption(id: 'd', text: 'It rules friends', isCorrect: false),
          ],
          explanation: 'The 8th House is the house of Mystery, Transformation, Longevity, and Sudden Ups/Downs.',
        ),
      ],
    ),

    'houses_9_to_12_quiz': Quiz(
      id: 'houses_9_to_12_quiz',
      title: 'Houses 9-12: The Higher Path',
      description: 'Dharma, Karma, Gains, and Moksha.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'The 9th House is the house of...',
          options: [
            QuizOption(id: 'a', text: 'Gains and Income', isCorrect: false),
            QuizOption(id: 'b', text: 'Dharma, Wisdom, and Fortune', isCorrect: true),
            QuizOption(id: 'c', text: 'Debts', isCorrect: false),
            QuizOption(id: 'd', text: 'Short Travels', isCorrect: false),
          ],
          explanation: 'The 9th House (Bhagya Bhava) represents Luck, Dharma, Higher Wisdom, Guru, and Father.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'What does the 12th House signify?',
          options: [
            QuizOption(id: 'a', text: 'Career Peak', isCorrect: false),
            QuizOption(id: 'b', text: 'Losses, Isolation, and Liberation (Moksha)', isCorrect: true),
            QuizOption(id: 'c', text: 'Marriage', isCorrect: false),
            QuizOption(id: 'd', text: 'Children', isCorrect: false),
          ],
          explanation: 'The 12th House rules Losses, Foreign Lands, Sleep, Subconscious, and Spiritual Liberation.',
        ),
      ],
    ),
    // ==========================================
    // SIGN QUIZZES
    // ==========================================
    
    'signs_intro_quiz': Quiz(
      id: 'signs_intro_quiz',
      title: 'Zodiac Signs Basics',
      description: 'Understanding the Rashis.',
      xpReward: 100,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What does a "Rashi" (Sign) represent?',
          options: [
            QuizOption(id: 'a', text: 'The "how" or style of expression', isCorrect: true),
            QuizOption(id: 'b', text: 'The "where" or area of life', isCorrect: false),
            QuizOption(id: 'c', text: 'The "what" or energy source', isCorrect: false),
            QuizOption(id: 'd', text: 'The timing of events', isCorrect: false),
          ],
          explanation: 'While Planets are the energy ("what") and Houses are the setting ("where"), Signs describe the style or quality ("how") of expression.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'How are signs classified by element?',
          options: [
            QuizOption(id: 'a', text: 'Red, Blue, Green, Yellow', isCorrect: false),
            QuizOption(id: 'b', text: 'Fire, Earth, Air, Water', isCorrect: true),
            QuizOption(id: 'c', text: 'Cardinal, Fixed, Mutable', isCorrect: false),
            QuizOption(id: 'd', text: 'Male, Female, Neutral', isCorrect: false),
          ],
          explanation: 'The 12 signs are divided into 4 elements: Fire (Agni), Earth (Prithvi), Air (Vayu), and Water (Jala).',
        ),
      ],
    ),
    
    'fire_signs_quiz': Quiz(
      id: 'fire_signs_quiz',
      title: 'Fire Signs',
      description: 'Aries, Leo, Sagittarius.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Which trait is most associated with Fire signs?',
          options: [
            QuizOption(id: 'a', text: 'Emotional depth', isCorrect: false),
            QuizOption(id: 'b', text: 'Stability and practicality', isCorrect: false),
            QuizOption(id: 'c', text: 'Inspiration, action, and energy', isCorrect: true),
            QuizOption(id: 'd', text: 'Intellectual analysis', isCorrect: false),
          ],
          explanation: 'Fire signs represent the spark of life: energy, willpower, courage, and inspiration.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Leo is ruled by which planet?',
          options: [
            QuizOption(id: 'a', text: 'Mars', isCorrect: false),
            QuizOption(id: 'b', text: 'Jupiter', isCorrect: false),
            QuizOption(id: 'c', text: 'The Sun', isCorrect: true),
            QuizOption(id: 'd', text: 'Saturn', isCorrect: false),
          ],
          explanation: 'Leo (Simha) is ruled by the Sun, reflecting royalty, leadership, and vitality.',
        ),
      ],
    ),
    
    'earth_signs_quiz': Quiz(
      id: 'earth_signs_quiz',
      title: 'Earth Signs',
      description: 'Taurus, Virgo, Capricorn.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is the focus of Earth signs?',
          options: [
            QuizOption(id: 'a', text: 'Ideas and concepts', isCorrect: false),
            QuizOption(id: 'b', text: 'Material reality and structure', isCorrect: true),
            QuizOption(id: 'c', text: 'Feelings and moods', isCorrect: false),
            QuizOption(id: 'd', text: 'Impulsive action', isCorrect: false),
          ],
          explanation: 'Earth signs focus on building, sustaining, and managing material resources and practical duties.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which Earth sign is mutable (adaptable)?',
          options: [
            QuizOption(id: 'a', text: 'Taurus', isCorrect: false),
            QuizOption(id: 'b', text: 'Virgo', isCorrect: true),
            QuizOption(id: 'c', text: 'Capricorn', isCorrect: false),
            QuizOption(id: 'd', text: 'None', isCorrect: false),
          ],
          explanation: 'Virgo is a mutable earth sign, signifying flexibility in service and detail-oriented work.',
        ),
      ],
    ),
    
    'air_signs_quiz': Quiz(
      id: 'air_signs_quiz',
      title: 'Air Signs',
      description: 'Gemini, Libra, Aquarius.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Air signs primarily value...',
          options: [
            QuizOption(id: 'a', text: 'Communication and relationships', isCorrect: true),
            QuizOption(id: 'b', text: 'Security and money', isCorrect: false),
            QuizOption(id: 'c', text: 'Power and dominance', isCorrect: false),
            QuizOption(id: 'd', text: 'Privacy and solitude', isCorrect: false),
          ],
          explanation: 'Air signs are social and intellectual, prioritizing ideas, exchange of information, and social connections.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Libra represents which quality?',
          options: [
            QuizOption(id: 'a', text: 'Rebellion', isCorrect: false),
            QuizOption(id: 'b', text: 'Balance and Diplomacy', isCorrect: true),
            QuizOption(id: 'c', text: 'Duality', isCorrect: false),
            QuizOption(id: 'd', text: 'Transformation', isCorrect: false),
          ],
          explanation: 'Libra, symbolized by the Scales, seeks balance, harmony, and justice in relationships.',
        ),
      ],
    ),
    
    'water_signs_quiz': Quiz(
      id: 'water_signs_quiz',
      title: 'Water Signs',
      description: 'Cancer, Scorpio, Pisces.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Water signs operate primarily through...',
          options: [
            QuizOption(id: 'a', text: 'Logic and Reason', isCorrect: false),
            QuizOption(id: 'b', text: 'Emotion and Intuition', isCorrect: true),
            QuizOption(id: 'c', text: 'Action and Will', isCorrect: false),
            QuizOption(id: 'd', text: 'Practicality', isCorrect: false),
          ],
          explanation: 'Water signs are deeply emotional, intuitive, receptive, and often psychic.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Scorpio is ruled by...',
          options: [
            QuizOption(id: 'a', text: 'The Moon', isCorrect: false),
            QuizOption(id: 'b', text: 'Mars (and Ketu)', isCorrect: true),
            QuizOption(id: 'c', text: 'Venus', isCorrect: false),
            QuizOption(id: 'd', text: 'Jupiter', isCorrect: false),
          ],
          explanation: 'Scorpio is traditionally ruled by Mars, sharing its intensity but in a fixed, watery (emotional) way.',
        ),
      ],
    ),

    // ==========================================
    // NAKSHATRA QUIZZES
    // ==========================================
    
    'nakshatras_intro_quiz': Quiz(
      id: 'nakshatras_intro_quiz',
      title: 'Nakshatra Basics',
      description: 'The 27 Lunar Mansions.',
      xpReward: 100,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'How many Nakshatras are there in the standard system?',
          options: [
            QuizOption(id: 'a', text: '12', isCorrect: false),
            QuizOption(id: 'b', text: '108', isCorrect: false),
            QuizOption(id: 'c', text: '27', isCorrect: true),
            QuizOption(id: 'd', text: '360', isCorrect: false),
          ],
          explanation: 'There are 27 Nakshatras, each measuring 13°20\'.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which planet rules the Vimshottari Dasha sequence starting with Ashwini?',
          options: [
            QuizOption(id: 'a', text: 'Mercury', isCorrect: false),
            QuizOption(id: 'b', text: 'Ketu', isCorrect: true),
            QuizOption(id: 'c', text: 'Venus', isCorrect: false),
            QuizOption(id: 'd', text: 'The Sun', isCorrect: false),
          ],
          explanation: 'Ashwini, Magha, and Mula are ruled by Ketu, which starts the Dasha cycle if the Moon is there.',
        ),
      ],
    ),
    
    'nakshatras_1_to_9_quiz': Quiz(
      id: 'nakshatras_1_to_9_quiz',
      title: 'Nakshatras 1-9',
      description: 'Ashwini to Ashlesha.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Which Nakshatra is known as the "Star of Transport"?',
          options: [
            QuizOption(id: 'a', text: 'Bharani', isCorrect: false),
            QuizOption(id: 'b', text: 'Ashwini', isCorrect: true),
            QuizOption(id: 'c', text: 'Krittika', isCorrect: false),
            QuizOption(id: 'd', text: 'Rohini', isCorrect: false),
          ],
          explanation: 'Ashwini acts quickly and is represented by a horse head, associated with transport and healing.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Rohini is ruled by which planet?',
          options: [
            QuizOption(id: 'a', text: 'The Sun', isCorrect: false),
            QuizOption(id: 'b', text: 'The Moon', isCorrect: true),
            QuizOption(id: 'c', text: 'Mars', isCorrect: false),
            QuizOption(id: 'd', text: 'Venus', isCorrect: false),
          ],
          explanation: 'Rohini is the Moon\'s favorite wife/star, representing beauty, creativity, and growth.',
        ),
      ],
    ),
    
    'nakshatras_10_to_18_quiz': Quiz(
      id: 'nakshatras_10_to_18_quiz',
      title: 'Nakshatras 10-18',
      description: 'Magha to Jyeshtha.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Magha Nakshatra is connected to...',
          options: [
            QuizOption(id: 'a', text: 'Friendship', isCorrect: false),
            QuizOption(id: 'b', text: 'Ancestors (Pitris) and Royal Authority', isCorrect: true),
            QuizOption(id: 'c', text: 'Learning', isCorrect: false),
            QuizOption(id: 'd', text: 'Arts', isCorrect: false),
          ],
          explanation: 'Magha represents the throne and connection to lineage/ancestors.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which Nakshatra symbol is "The Hand"?',
          options: [
            QuizOption(id: 'a', text: 'Hasta', isCorrect: true),
            QuizOption(id: 'b', text: 'Chitra', isCorrect: false),
            QuizOption(id: 'c', text: 'Swati', isCorrect: false),
            QuizOption(id: 'd', text: 'Vishakha', isCorrect: false),
          ],
          explanation: 'Hasta means "Hand" and signifies skill, craftsmanship, and grasping things.',
        ),
      ],
    ),
    
    'nakshatras_19_to_27_quiz': Quiz(
      id: 'nakshatras_19_to_27_quiz',
      title: 'Nakshatras 19-27',
      description: 'Mula to Revati.',
      xpReward: 150,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'Mula Nakshatra signifies...',
          options: [
            QuizOption(id: 'a', text: 'Softness', isCorrect: false),
            QuizOption(id: 'b', text: 'Roots and Destruction/Rebirth', isCorrect: true),
            QuizOption(id: 'c', text: 'Luxury', isCorrect: false),
            QuizOption(id: 'd', text: 'Diplomacy', isCorrect: false),
          ],
          explanation: 'Mula means "Root" and is ruled by Ketu, getting to the bottom of things, often through destruction.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Revati is the final Nakshatra, representing...',
          options: [
            QuizOption(id: 'a', text: 'Competition', isCorrect: false),
            QuizOption(id: 'b', text: 'Completion, Nourishment, and Protection', isCorrect: true),
            QuizOption(id: 'c', text: 'Anger', isCorrect: false),
            QuizOption(id: 'd', text: 'Start of a journey', isCorrect: false),
          ],
          explanation: 'Revati ("The Wealthy") ensures safe passage and nourishment at the end of the journey.',
        ),
      ],
    ),
    
    // ==========================================
    // ANALYSIS QUIZZES
    // ==========================================
    
    'chart_reading_basics_quiz': Quiz(
      id: 'chart_reading_basics_quiz',
      title: 'Chart Analysis Basics',
      description: 'The PAC-DARES method.',
      xpReward: 200,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is the "PAC" method?',
          options: [
            QuizOption(id: 'a', text: 'Planet, Aspect, Conjunction', isCorrect: false),
            QuizOption(id: 'b', text: 'Position, Aspect, Conjunction', isCorrect: true),
            QuizOption(id: 'c', text: 'Past, After, Current', isCorrect: false),
            QuizOption(id: 'd', text: 'Primary, Auxiliary, Conclusion', isCorrect: false),
          ],
          explanation: 'PAC stands for seeing a Planet\'s Position (Sign/House), Aspects receiving/giving, and Conjunctions.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Which house primarily shows "Dharma" (Purpose)?',
          options: [
            QuizOption(id: 'a', text: '1, 5, 9', isCorrect: true),
            QuizOption(id: 'b', text: '2, 6, 10', isCorrect: false),
            QuizOption(id: 'c', text: '3, 7, 11', isCorrect: false),
            QuizOption(id: 'd', text: '4, 8, 12', isCorrect: false),
          ],
          explanation: 'The fire houses (1, 5, 9) are the Dharma Trikona, showing purpose and righteous path.',
        ),
      ],
    ),
    
    'planet_house_combinations_quiz': Quiz(
      id: 'planet_house_combinations_quiz',
      title: 'Planetary Combinations',
      description: 'Interpreting placements.',
      xpReward: 200,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What happens when a house lord is in the 6th, 8th, or 12th house?',
          options: [
            QuizOption(id: 'a', text: 'It always gains strength', isCorrect: false),
            QuizOption(id: 'b', text: 'It usually faces struggle or loss (Dusthana)', isCorrect: true),
            QuizOption(id: 'c', text: 'It becomes a "Yogakaraka"', isCorrect: false),
            QuizOption(id: 'd', text: 'Nothing happens', isCorrect: false),
          ],
          explanation: 'Placement in Dusthana houses (6, 8, 12) generally brings challenges to the house the planet owns.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'What is a "Parivartana Yoga"?',
          options: [
            QuizOption(id: 'a', text: 'Two planets assume each other\'s signs', isCorrect: true),
            QuizOption(id: 'b', text: 'Two planets are combust', isCorrect: false),
            QuizOption(id: 'c', text: 'A planet is exalted', isCorrect: false),
            QuizOption(id: 'd', text: 'A planet is debilitated', isCorrect: false),
          ],
          explanation: 'Parivartana Yoga (Mutual Reception) occurs when Planet A is in Planet B\'s sign, and Planet B is in Planet A\'s sign, linking their energies strongly.',
        ),
      ],
    ),

    'asking_questions_quiz': Quiz(
      id: 'asking_questions_quiz',
      title: 'Focused Analysis',
      description: 'Career, Marriage, Wealth.',
      xpReward: 200,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'For career analysis, which house is primary?',
          options: [
            QuizOption(id: 'a', text: '4th House', isCorrect: false),
            QuizOption(id: 'b', text: '7th House', isCorrect: false),
            QuizOption(id: 'c', text: '10th House', isCorrect: true),
            QuizOption(id: 'd', text: '12th House', isCorrect: false),
          ],
          explanation: 'The 10th House (Karma Bhava) is the zenith of the chart and rules career, public status, and action.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'For marriage, check the...',
          options: [
            QuizOption(id: 'a', text: '7th House and Venus/Jupiter', isCorrect: true),
            QuizOption(id: 'b', text: '2nd House and Sun', isCorrect: false),
            QuizOption(id: 'c', text: '6th House and Mars', isCorrect: false),
            QuizOption(id: 'd', text: '9th House and Moon', isCorrect: false),
          ],
          explanation: 'The 7th House governs partnership, and Venus (for men) or Jupiter (for women) signifies the spouse.',
        ),
      ],
    ),

    'remedies_practical_quiz': Quiz(
      id: 'remedies_practical_quiz',
      title: 'Remedies (Upayas)',
      description: 'Corrective measures.',
      xpReward: 200,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'What is the best way to strengthen a weak benefic planet?',
          options: [
            QuizOption(id: 'a', text: 'Curse it', isCorrect: false),
            QuizOption(id: 'b', text: 'Gemstones, Mantras, or specific actions', isCorrect: true),
            QuizOption(id: 'c', text: 'Ignoring it', isCorrect: false),
            QuizOption(id: 'd', text: 'Eating more', isCorrect: false),
          ],
          explanation: 'Benefic planets can be strengthened through gemstones (if functional benefic), chanting mantras, or performing related charitable acts.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'Remedies for Saturn often involve...',
          options: [
            QuizOption(id: 'a', text: 'Talking loudly', isCorrect: false),
            QuizOption(id: 'b', text: 'Service, discipline, and helping the poor', isCorrect: true),
            QuizOption(id: 'c', text: 'Wearing gold', isCorrect: false),
            QuizOption(id: 'd', text: 'Eating rich foods', isCorrect: false),
          ],
          explanation: 'Saturn, the planet of service, is appeased by selfless service (Seva), discipline, and helping the less fortunate.',
        ),
      ],
    ),

    'mastery_integration_quiz': Quiz(
      id: 'mastery_integration_quiz',
      title: 'Ultimate Mastery',
      description: 'The final test.',
      xpReward: 500,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'The ultimate goal of Jyotish is...',
          options: [
            QuizOption(id: 'a', text: 'To become rich', isCorrect: false),
            QuizOption(id: 'b', text: 'To predict lottery numbers', isCorrect: false),
            QuizOption(id: 'c', text: 'Self-knowledge and living in harmony with cosmic time', isCorrect: true),
            QuizOption(id: 'd', text: 'To control others', isCorrect: false),
          ],
          explanation: 'Jyotish ("Eye of Light") exists to dispell darkness, granting self-knowledge and helping us navigate our karma with grace.',
        ),
        QuizQuestion(
          id: 'q2',
          text: 'In a chart, if the Ascendant Lord is strong...',
          options: [
            QuizOption(id: 'a', text: 'The person usually has strong health and direction', isCorrect: true),
            QuizOption(id: 'b', text: 'The person is always wealthy', isCorrect: false),
            QuizOption(id: 'c', text: 'The person has no enemies', isCorrect: false),
            QuizOption(id: 'd', text: 'The person is lazy', isCorrect: false),
          ],
          explanation: 'A strong Lagna Lord (Ascendant Lord) protects the entire chart, giving vitality, purpose, and the ability to overcome challenges.',
        ),
      ],
    ),
  };

  static Quiz? getQuiz(String id) => quizzes[id];
}
