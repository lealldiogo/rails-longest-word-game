require 'open-uri'
require 'json'

class WordsGameController < ApplicationController
  def game
    @grid_game = generate_grid(9).join(" ")
  end

  def score
    @attempt = params[:attempt]
    @grid_score = params[:grid].split(" ")
    @start_time = params[:start_time].to_f
    @end_time = Time.now.to_f
    @score_hash = run_game(@attempt, @grid_score, @start_time, @end_time)
  end

#-----------------longest_word-------------------

  def generate_grid(grid_size)
    range = ("A".."Z").to_a
    array = []
    grid_size.times { array << range.sample }
    return array
  end

  def word_in_grid?(word, grid)
    w_hist = Hash.new(0)
    grid_hist = Hash.new(0)
    word.split("").each { |letter| w_hist[letter.upcase] += 1 }
    grid.each { |letter| grid_hist[letter.upcase] += 1 }
    match_test = true
    w_hist.each { |letter, freq| match_test = false if freq > grid_hist[letter] }
    return match_test
  end


  def run_game(attempt, grid, start_time, end_time)
    url = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20170121T150946Z.0178f82303469bc1.70d51c8d5444860a585e74d26dd87559975fc021&text=<#{attempt}>&lang=en-fr"
    elapsed_time = (end_time - start_time).round(5)
    json_doc = open(url).read
    output_hash = JSON.parse(json_doc)
    translated_word = output_hash["text"][0].gsub(/(<|>)/, "")
    if translated_word != attempt
      if word_in_grid?(attempt, grid)
        points = (100 * attempt.size / elapsed_time).round(2)
        msg = "well done"
      else
        msg = "not in the grid"
        points = 0
      end
    else
      msg = "not an english word"
      points = 0
      translated_word = nil
    end
    return { time: elapsed_time, translation: translated_word, score: points, message: msg }
  end
end
