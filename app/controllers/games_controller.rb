require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10)
  end

  def score
    @word = params[:word]
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @grid = params[:grid].split(',')
    @score = new_game(@word, @grid, @start_time, @end_time)[:score].to_i
    @message = new_game(@word, @grid, @start_time, @end_time)[:message]
  end

  private

  def generate_grid(grid_size)
    letters = []
    grid_size.times do
      letters << ('A'..'Z').to_a.sample
    end

    letters
  end

  def result(length, time)
    length - time / 100_000
  end

  def message(score)
    puts score
    if score < 3
      'Low Score, Try Again'
    elsif score >= 3 && score < 7
      'Medium score, good try!'
    else
      'Well Done! Top Points!'
    end
  end

  def new_game(attempt, grid, start_time, end_time)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}")
    list = JSON.parse(response.read)
    if attempt.upcase.chars & grid == attempt.upcase.chars
      your_score = result(attempt.length, end_time - start_time)
      { time: end_time - start_time, score: result(attempt.length, end_time - start_time) + 1, message: message(your_score) }
    elsif list['found'] == false
      { time: end_time - start_time, score: 0, message: "sorry but '#{attempt}' does not seem to be a valid word" }
    elsif attempt.upcase.chars & grid != attempt.upcase.chars
      { time: end_time - start_time, score: 0, message: "sorry but '#{attempt}' can't be built out of #{grid.join(', ')}" }
    end
  end
end
