# CLASSES
# 1. Game Class
#     -this plays the game and calls the other classes that are involved
#     - include a game_over class variable
#     - include welcome methods
#     - checks players guess against the result of the dictionary class
#     - class variables: guesses_left, dictionary_word, letters_guessed_right, letters_guessed_wrong (this is called when the game is loaded), hangman_status
# 2. player method or class? 
#     - this should allow the player to select a letter and give feedback
# 3. Dictionary Class
#     -dictionary class: randomly select a word. 
#     =the result of this will be the word that the player has to guess

# GAME LOGIC
# 1. Dictionary randomly chooses a word from a set of words
# 2. The player makes a one letter guess.
#     - if correct, the correct letter is displayed in the correct position
#     - if incorrect, 
#         *the letter is displayed in a list of incorrect letters 
#         *a part of the hangman is added
# 2. this repeats until game_over is true
#     *when the whole word has been guessed
#     OR
#     *the hangman is complete (number of guesses == 0)


#Dictionary Class
require 'yaml'

# adds 2 methods to the String class which can be used on any string. Use this for colouring outputs. Append output with .red or .green. 
class String
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def yellow;          "\e[33m#{self}\e[0m" end
end

class Dictionary

    #instance method that can be used when a new instance of the class Dictionary is called
    def word_maker
        @@dictionary = File.readlines 'dictionary.txt'
        loop do                                                                     
            @dictionary_word = @@dictionary[rand(@@dictionary.length)].gsub("\n", "").downcase                   #strips the whitespace and randomly selects a word from dictionary
            return @dictionary_word if @dictionary_word.length >= 5 && @dictionary_word.length <= 12             #prints the word if it is between 5 and 12 characters long and quits the loop       
        end
    end


end



class Player 
    def self.player_letter_guess                            #self because the method is called on the class itself
        loop do 

            puts "\nPlease enter a new guess (1 letter only)"
            print "=> "
            player_guess = gets.chomp.strip().downcase
            if player_guess == 'save--'
                return player_guess
            else return player_guess if Player.guess_valid?(player_guess)      #return guess if the valid check returns true
            end
        end
    end

    def self.guess_valid?(guess)
     (guess.empty? || guess =~ /\d/ || guess =~ /[a-zA-Z]{2,}/) ? false : true         #if the guess is empty tOR if the guess contains a digit then false OR if it contains more than 1 character
    end

end



class Game

    def initialize      
        @dictionary = Dictionary.new                           #instantiates the Dictionary class, methods can now be called on it, see word_display
        @guesses_remaining = 9
        @total_guesses = ""
        @colour_coded_total_guesses = ""
        display_instructions
        new_game_or_load
    end

    def save_game
        game_data = {                                               #name of the stuff that will be written to_yaml (line 100)
            guesses_remaining: @guesses_remaining,
            total_guesses: @total_guesses,
            game_over: @game_over,
            secret_word: @secret_word,
            secret_word_placeholder: @secret_word_placeholder,
            secret_word_array: @secret_word_array,
            colour_coded_total_guesses: @colour_coded_total_guesses
        }

        Dir.mkdir("saves") unless Dir.exists? "saves"

        puts "WARNING! Existing filename will be overwritten.".red
        puts "Enter new save filename"
        filename = gets.chomp
        File.open("saves/#{filename}.yml", "w") { |file| file.write(game_data.to_yaml) }    #File must be opened to be written to
    end

    def new_game_or_load
        loop do
            puts "Enter 1 for New Game"
            puts "Enter 2 to Load Game"

            @choice = gets.chomp

            break if @choice == '1' || @choice == '2'
        end

        @choice == '1' ? new_game : load_game
    end

    def new_game
        secret_word_maker
        secret_word_placeholder_maker
        play_game
    end

    def load_game 
        filename = nil
        loop do 
            print "Enter the filename you want to load: "
            filename = gets.chomp
            break if File.exists? "saves/#{filename}.yml"
        end

        game_data = YAML.load(File.read("saves/#{filename}.yml"))

        @guesses_remaining = game_data[:guesses_remaining]
        @total_guesses = game_data[:total_guesses]
        @game_over = game_data[:game_over]
        @secret_word = game_data[:secret_word]
        @secret_word_placeholder = game_data[:secret_word_placeholder]
        @secret_word_array = game_data[:secret_word_array]
        @colour_coded_total_guesses = game_data[:colour_coded_total_guesses]

        puts "\n-------------------------------------------------------"
        puts "You have #{@guesses_remaining} guesses remaining"
        puts "-------------------------------------------------------"
        puts "You have made these guesses: #{@colour_coded_total_guesses}"
        puts "-------------------------------------------------------"
        puts "Here is the secret word: #{@secret_word_placeholder.join(" ")}"
        puts "-------------------------------------------------------"
        play_game
    end


    def display_instructions
        puts "***************************************"
        puts "**** Welcome To The Hangman Game! *****"
        puts "***************************************"
        puts "======================================="
        puts "************ Instructions *************"
        puts "***************************************"
        puts "1. The objective of the game is to guess"
        puts "letters to a secret word. The secret word"
        puts "is represented by a series of horizontal"
        puts "lines indicating its length. "
        puts "For example:"
        puts "If the secret word it 'chess', then it will "
        puts "be displayed as:"
        puts "_ _ _ _ _ \n "
        puts "2. You are given 9 chances. For each incorrect"
        puts "guess, the chances will decrease by 1. For each correct"
        puts "guess, the part of the secret word are revealed"
        puts "For example: If your guess is 's' then the result"
        puts "of the guess will be:"
        puts "_ _ _ s s \n "
        puts "3. When you guessed all the correct letters to the secret word"
        puts "or when you are out of chances, the game over will be over."
        puts "4. Any time during the game, if you would like to save"
        puts "your progress and quit, type 'save--' without the quotes"
        puts
        puts
        puts "------------------------------------------------------------------"
        puts
        puts
    end

    #instance method that can be used when a new instance of the Game class is created
    def secret_word_maker                                        
        @secret_word = @dictionary.word_maker                        #applies the word_maker method defined in the dictionary class.        
    end

   def get_player_guess
    @guess = Player.player_letter_guess
   end

   def check_total_guesses_for_new_guess                        
    loop do                                                         #continues loop until break which occurs if a unique guess is made  
        if @total_guesses.include?(@guess)
            puts
            puts "You've already chosen that!".yellow
            get_player_guess
        else
        @total_guesses << @guess

        break
        end
    end
   end

   def secret_word_placeholder_maker                                  #for every letter in the secret word add a dashed line
    @secret_word_placeholder = []
    secret_word = secret_word_maker
    # puts @secret_word
    @secret_word_array = secret_word.strip().split('')
    @secret_word_array.each do |letter|
        @secret_word_placeholder << "_"
    end
    puts "Here is the secret word: #{@secret_word_placeholder.join(" ")}"
   end

   def compare_guess_to_secret_word
    #compare guess to each letter in the secret word, if the guess matches one, replace that position with the letter in the placeholder
    @secret_word_array.each_with_index do |letter, index|
        if letter == @guess
            @secret_word_placeholder[index] = @guess
            index_of_right_guess = @total_guesses.index(@guess)
            @colour_coded_total_guesses << @total_guesses[index_of_right_guess].green
        end
    end
    if @secret_word_array.none?(@guess)
        @guesses_remaining -= 1
        puts "You have 1 less guess! #{@guesses_remaining} guesses remaining.".red
        index_of_wrong_guess = @total_guesses.index(@guess)
        @colour_coded_total_guesses << @total_guesses[index_of_wrong_guess].red
    end
    puts puts
    puts 
    puts
    puts @secret_word_placeholder.join(" ")
    puts
    puts "Total guesses: #{@colour_coded_total_guesses}"
    puts
    puts 
    puts puts
   end

   def game_over
    if @secret_word_array.all? { |letter| @total_guesses.include?(letter) }                 #checks if secret word array contains everything in total guesses
        puts
        puts "-----------------------------------------------------------------------"
        puts "---- Congratulations! You've won with #{@guesses_remaining} guesses still remaining! ------".green
        puts "-----------------------------------------------------------------------"
        puts 
        true

    elsif @guesses_remaining == 0
        puts "?????????????????????????????????????????????????????????????????"
        puts "Whoops, looks like you're too dumb for this game. You've lost".red
        puts "???????????????????????????????????????????????????????????????????????????"
        true
    end
   end


   def play_game
    loop do

        get_player_guess
        
        if @guess == 'save--'
            save_game
            break
        end

        check_total_guesses_for_new_guess
        compare_guess_to_secret_word

        break if game_over
    end
   end
end

#new instance of the Game class is saved to the word variable
word = Game.new
#now the instance method of word_display can be called on that variable (because it is an instance of the Game class)
# word.display_secret_word

