require 'HTTParty'
require 'Nokogiri'
require_relative 'movie_genres.rb'

class Genre

  def initialize(genre)
    @genre = genre
    @movies = []
  end
  def fetch_movies
    page = HTTParty.get("http://www.imdb.com/genre/#{@genre}")
    parse_page = Nokogiri::HTML(page)
    parse_page.css('table.results tr .title a').each do |item|
      title = item.content
      link = item.first[1]
      if link.include?("title") and title != "X"
          @movies.push(Movie.new(title, link))
      end
    end
  end
  def show_movie_list
      @movies[0..4].each do |x|
        puts x.title
      end
  end
  def shuffle_movies
      @movies.each do |a|
        puts a.shuffle[0]
      end
  end
end

class Movie
  attr_accessor :title, :link

  def initialize(title, link)
    @title = title
    @link = link
    @actor_names = []
  end
  def fetch_movie_info
    page = Nokogiri::HTML(open("http://www.imdb.com/title/tt5013056/"))
    page.css('.summary_text').each do |y|
      puts y.content
    end
  end
  def fetch_actor_in_movie
    page = Nokogiri::HTML(open("http://www.imdb.com/title/tt0816692/"))
    page.css('.itemprop').each do |z|
      name = z.content
      @actor_names.push(Actor.new(name))
    end
  end
  def show_actors_in_movie
    puts @actor_names[5..7]
  end
end

class Actor
  attr_accessor :name

  def initialize(name)
    @name = name
    @known_for = []
  end
  def get_actor_bio
    page = Nokogiri::HTML(open("http://www.imdb.com/name/nm7887725/?ref_=tt_ov_st_sm"))
    page.css('.name-trivia-bio-text').each do |item|
      puts item.content
    end
  end
  def get_actor_other_movies
    page = Nokogiri::HTML(open("http://www.imdb.com/name/nm7887725/?ref_=tt_ov_st_sm"))
    page.css('.knownfor-ellipsis').each do |item|
      title = item.content
      link = item.first[1]
      if link.include?("title") and title != "X"
          @known_for.push(title, link)
      end
    end
  end
  def show_actor_other_movies
    puts @known_for
  end
end

def welcome_prompt
    puts "Welcome to WhatMovie, let me help you choose a movie to watch."
    print "Press enter to continue"
    @continue = gets.chomp
end

def welcome_menu
  puts "Type 1 to select via genre"
  puts "Type 2 to let WhatMovie select five for you at random"
  puts "Type 9 at any stage to come back to the main menu"
  @answer = gets.chomp.to_i
end

def show_genres
  puts $genres
  puts "Please select from one of the above genres!"
  @input_genre = gets.chomp
end


welcome_prompt
if @continue == ""
  welcome_menu
  if @answer == 1
    show_genres
    choose_movie = Genre.new(@input_genre)
    choose_movie.fetch_movies
    choose_movie.show_movie_list
  elsif @answer == 2
    @genre = $genres.shuffle[0]
    choose_movie = Genre.new(@genre)
    choose_movie.fetch_movies
    choose_movie.show_movie_list
  else
    welcome_menu
  end
end
