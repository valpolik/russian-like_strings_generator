LETTERS_FREQ = {
  1072 => 801,  # а
  1073 => 159,  # б
  1074 => 454,  # в
  1075 => 170,  # г
  1076 => 298,  # д
  1077 => 749,  # е
  1105 => 100,  # ё
  1078 => 94,   # ж
  1079 => 165,  # з
  1080 => 735,  # и
  1081 => 121,  # й
  1082 => 349,  # к
  1083 => 440,  # л
  1084 => 321,  # м
  1085 => 670,  # н
  1086 => 1097, # о
  1087 => 281,  # п
  1088 => 473,  # р
  1089 => 547,  # с
  1090 => 626,  # т
  1091 => 262,  # у
  1092 => 26,   # ф
  1093 => 97,   # х
  1094 => 48,   # ц
  1095 => 144,  # ч
  1096 => 73,   # ш
  1097 => 36,   # щ
  1098 => 4,    # ъ
  1099 => 190,  # ы
  1100 => 174,  # ь
  1101 => 32,   # э
  1102 => 64,   # ю
  1103 => 201   # я
}.freeze


ONE_LETTER_WORDS_FREQ = {
  1080 => 358, # аявоуикс. Удельный вес букв.
  1074 => 314,
  1103 => 127,
  1089 => 113,
  1072 => 82,
  1082 => 54,
  1091 => 43,
  1086 => 34
}.freeze


VOWELS = [
  1072, 
  1077, 
  1080,
  1086,
  1091,
  1099,
  1101,
  1102,
  1103,
  1105
]


CONSONANTS = [
  1073, 
  1074, 
  1075, 
  1076, 
  1078, 
  1079, 
  1081,
  1082, 
  1083, 
  1084, 
  1085, 
  1087, 
  1088, 
  1089, 
  1090, 
  1092, 
  1093, 
  1094, 
  1095, 
  1096, 
  1097
]


def provide_distribution(hash)
  sample_array = []
  hash.each_key do |k|
    hash[k].times do
      sample_array << k
    end
  end
  sample_array.freeze
  sample_array
end


def select_letters(arr)
  LETTERS_FREQ.select{|k,v| arr.any?(k)}
end


ONE_LETTER_WORDS_PROBABILITY_ARRAY = provide_distribution(ONE_LETTER_WORDS_FREQ)
VOWELS_PROBABILITY_ARRAY     = provide_distribution(select_letters(VOWELS))
CONSONANTS_PROBABILITY_ARRAY = provide_distribution(select_letters(CONSONANTS))










def rl_str_gen    # Russian-like string generator
  words_gen(plan_words).map{|a| a << 32}.flatten[0..-2].pack("U*")
end


def base_string
  x = [*1040..1103, 1105, 1025]
  arr = Array.new( rand(3..250) ) {x.sample}

  index = rand(1..15)

  while index < arr.size
    arr[index] = 32
    index += rand(2..16)
  end

  arr.pack("U*")
end


def plan_words
  arr = Array.new(rand(2..15)) {{}}

  arr.each do |el|
    # case rand(10)
    case rand(20)
    when 0
      el[:case] = :acronym
    when 1, 2
      el[:case] = :capital
    else
      el[:case] = :downcase
    end

    if el[:case] != :acronym
      el[:multi_syllable] = rand(5) == 0 ? false : true
    end

    if el[:multi_syllable] == true
      el[:dash] = rand(20) == 0 ? true : false
    elsif el[:multi_syllable] == false
      if rand(2) == 0
        el[:one_letter] = true
        el[:case]       = :downcase
      else
        el[:one_letter] = false
      end
    end
  end
end


def words_gen(arr)
  # Получает массив с хэшами, где описаны свойства будущих слов. 
  # Согласно этим условиям, создаем производный массив, где каждый элемент 
  # является массивом с интеджерами, который в будущем станет словом.
  arr.map { |el|
    case el[:case]
    when :acronym
      make_acronym
    when :downcase
      make_common_word(el)
    when :capital
      digital_capitalize( make_common_word(el) )
    end
  }
end


def make_acronym
  letters = [*1040..1048, *1050..1065, *1069..1071, 1025]
  Array.new( rand(2..5) ) { letters.sample }
end


def digital_capitalize(arr)
  if arr[0] == 1105
    arr[0] = 1025
  elsif arr[0] > 1071
    arr[0] -= 32
  end

  arr
end


def make_common_word(hash)
  if hash[:multi_syllable]
    word = generate_multi_syllable_word
  elsif hash[:one_letter]
    word = [ONE_LETTER_WORDS_PROBABILITY_ARRAY.sample]
  else
    word = generate_single_syllable_word
  end

  word = add_dash(word) if hash[:dash]
  word
end


def generate_single_syllable_word
  length = rand(20) < 15 ? rand(2..4) : rand(5..6)
  vowel  = VOWELS_PROBABILITY_ARRAY.sample # vowels
  word   = Array.new(length)
  
  case length
  when 2
    word[rand(2)] = vowel
  when 3, 4
    word[rand(1..2)] = vowel
  when 5, 6
    word[-2] = vowel
  end

  word.map!{|el| el ? el : CONSONANTS_PROBABILITY_ARRAY.sample}
  finalize_word(word)
end


def finalize_word(word)
  word = check_same_consonants(word)
  word = manage_i_short(word)
  occasionally_add_softening_sign(word)  
end


def check_same_consonants(arr)
  arr
end


def occasionally_add_softening_sign(arr)
  arr
end


def manage_i_short(arr)
  arr
end


def add_dash(arr)
  return arr if arr.size < 5 || arr.size > 14
  vowel_indexes = []
  
  arr.each_with_index do |el, i|
    vowel_indexes << i if VOWELS.any?(el)
  end

  dash_zone_borders = 
    [
     vowel_indexes[0] == 0 ? 2 : vowel_indexes[0] + 1, 
     vowel_indexes[-1] == (arr.size-1) ? vowel_indexes[-1]-1 : vowel_indexes[-1]
    ]
  (dash_zone_borders[0]..dash_zone_borders[1])
  .map{|i|
    next if arr[i] == 1100

  }
  arr
end


def generate_multi_syllable_word
  generate_single_syllable_word + generate_single_syllable_word
end


def get_no_insert_range(arr)
  no_insert = []
  consonants = 0
  arr.each_with_index do |el, i|
    VOWELS.any?(el) ? consonants = 0 : consonants += 1
    no_insert << ((i-3)..(i+1)) if consonants == 4
  end
  no_insert
end
