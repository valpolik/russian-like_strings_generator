require 'rspec'
require_relative '../app/methods'


describe "get_no_insert_range" do
  it "Should correctly find 4 consonants in a row groups" do
    1000.times do
      word  = Array.new(12) { rand(1072..1103) }
      check = word.chunk { |el| VOWELS.any?(el) }
        .to_a
        .select { |el| el[1].size > 3 && el[0] == false }
        .map { |el| el[1][0..3] }
      test  = get_no_insert_range(word).map { |r| word[r][0, 4] }
      expect(test).to eq(check)
    end
  end
end


describe "Resulting sentence" do
  before(:all) do
    @string = rl_str_gen
  end

  it "should return a string" do
    expect(@string).to be_an_instance_of(String)
  end


  it "should contain only valid symbols" do
    expect( @string.match(/[^а-яё,\.:\-!\?\"; ]/i) ).to be_nil
  end


  it "should not be over 300 symbols" do
    expect(@string.size).to be <= 300
  end


  it "should contain from 2 to 15 words" do
    str = @string
    expect(str.size).to be <= 300
    expect(str.gsub("- ", "").match?(/\A *(?:[^ ]+ +){1,14}[^ ]+ *\z/) )
    .to be true
  end


  it "should not contain words over 15 letters" do
    words = @string.scan(/[а-яё]+(?:-[а-яё]+)?/i)
    expect( words.count{|el| el.size > 15} ).to eq(0)
  end


  it "should allow only particular marks after words within sentence" do
    within = @string.split.reject{|el| el == "-"}[0..-2]
    expect(within.reject{|el| el.match?(/[а-яё]\"?[,:;]?\z/i)}
                 .size)
                 .to eq(0)
  end  


  it "should allow only particular signs in the end of the sentence" do
    expect(@string.match? /.*[а-яё]+\"?(\.|!|\?|!\?|\.\.\.)\z/)
                     .to be true
  end    


  it "should not allow unwanted symbols inside words" do
    expect(@string.match /[а-яё\-][^а-яё \-]+[а-яё\-]/i).to be_nil
  end


  it "should not allow multiple punctuation marks" do
    expect(@string.match(/([^а-яё.]) *\1/i)).to be_nil
  end


  it "should exclude unwanted symbols before words" do
    expect(@string.match /(?<![а-яё])[^ \"а-яё]+\b[а-яё]/i).to be_nil
  end


  it "should correctly use quotation marks" do
    str = @string
    expect( str.scan(/\"/).size.even? ).to be true
    expect( str.scan(/\".+?\"/)
               .reject{|el| el.match? /\"[а-яё].+[а-яё]\"/i}
               .size ).to eq(0)
  end 


  it "should not allow words starting with ь, ъ, ы" do
    expect( @string.match(/\b[ьъы]/i) ).to be_nil
  end


  it "should not contain capital letters inside words if not an acronym" do
    words = @string.gsub(/[^а-яё ]/i, "").split
    words.each do |el|
      unless el.match?(/\A[А-ЯЁ]{2,}\z/)
        expect( el.match(/\A.+[А-ЯЁ]/) ).to be_nil
      end
    end
  end 


  it "should  allow acronyms only to 5 letters long" do
    acr = @string.gsub(/[^а-яё ]/i, "").scan(/[А-ЯЁ]{2,}/)
    expect(acr.count{|a| a.size > 5}).to eq(0)
  end


  it "should not allow one-letter words with a capital letter" do
    expect( @string.match(/ \"?[А-ЯЁ]\b/) ).to be_nil
  end


  it "should always have a vowel after й at the beginning of the word" do
    expect( @string.match(/\bй[^ео]/i) ).to be_nil
  end


  it "should allow only particular letters after й inside words" do
    expect( @string.match(/\Bй[ьъыёуиаэюжй]/i) ).to be_nil
  end


  it "should always be a vowel in 2- and 3-letter words" do
    @string
    .gsub(/[^а-яё ]/i, "")
    .split
    .select{|el| el.size == 2 || el.size == 3}
    .reject{|el| el.match?(/\A[А-ЯЁ]+\z/)}
    .each do |word|
      expect(word).to match(/[аоуэыияёюе]/i)
    end
  end


  it "should allow only particular one-letter words" do
    @string.scan(/\b[а-яё]\b/i).each do |word|
      expect(word).to match(/[аявоуикс]/i)
    end
  end


  it "should not allow more than 4 consonant letters in a row" do
    words = @string.gsub(/[^а-яё ]/i, "").split
    words.each do |el|
      unless el.match?(/\A[А-ЯЁ]{2,}\z/)
        expect( el.match(/[^аоуэыияёюе ]{5,}/i) ).to be_nil
      end
    end
  end


  it "should not allow more than 2 vowel letters in a row" do
    words = @string.gsub(/[^а-яё ]/i, "").split
    words.each do |el|
      unless el.match?(/\A[А-ЯЁ]{2,}\z/)
        expect( el.match(/[аоуэыияёюе]{3,}/i) ).to be_nil
      end
    end
  end   


  it "should not allow more than 2 same consonant letters in a row" do
    words = @string.gsub(/[^а-яё ]/i, "").split
    words.each do |el|
      unless el.match?(/\A[А-ЯЁ]{2,}\z/)
        expect( el.match(/([^аоуэыияёюе])\1\1/i) ).to be_nil
      end
    end
  end


  it "should start with capital letter" do
    expect(@string).to match(/\A\"?[А-ЯЁ]/)
  end


  it "should contain at least 40% vowels in multi-syllable word" do
    @string.gsub(/[^а-яё ]/i, " ")
    .split
    .select{|w| w.match?(/[аоуэыияёюе].*[аоуэыияёюе]/i)}
    .each do |el|
      unless el.match?(/\A[А-ЯЁ]{2,}\z/)
        found = el.scan(/[аоуэыияёюе]/i).size
        calc  = ( (el.size - el.scan(/[ъь]/i).size) * 0.4 ).to_i
        res   = found >= calc ? ">=#{calc} vowels" : "#{found} vowels"
        expect( [res, el] )
        .to eq( [">=#{calc} vowels", el] )
      end
    end
  end


  it "should contain 5 or less consonants in single-syllable words" do
    @string.gsub(/[^а-яё \-]/i, "")
    .split
    .reject{|w| w.match?(/\-|([аоуэыияёюе].*[аоуэыияёюе])/i) || 
      w.match?(/\A[А-ЯЁ]{2,}\z/)}
    .each do |word|
      expect(word.size).to be <= 6
    end
  end  


  it "should allow only я е ё ю after ъ" do
    expect( @string.gsub(/\b[А-ЯЁ]{2,}\b/,"").match /ъ[^яюеё]/i ).to be_nil
  end


  it "should not allow a vowel at the beginning of the word"\
   "in single-syllable words if they have 3 or more letter" do

    @string.gsub(/[^а-яё \-]/i, "")
    .split
    .reject{|w| w.match?(/\-|([аоуэыияёюе].*[аоуэыияёюе])/i) || 
      w.match?(/\A[А-ЯЁ]{2,}\z/) || 
      w.size < 3}
    .each do |word|
      expect(word).to match(/\A[^аоуэыияёюе]/i)
    end
  end


  it "should forbid Ь and Ъ in acronyms" do
    expect( @string.match(/(?=\b[А-ЯЁ]{2,}\b)\b[А-ЯЁ]*[ЪЬ][А-ЯЁ]*\b/) ).to be_nil
  end
end
