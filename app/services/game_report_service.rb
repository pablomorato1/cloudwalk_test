class GameReportService
  def initialize(params = {})
    @log_file = params[:log_file].split("\n") if params[:log_file].present?
    @games_list = {}
    @processed_games_list = {}
  end

  def process
    split_games_from_array

    @games_list.each do |game_counter, game_lines|
      @processed_games_list[:"#{game_counter}"] = process_game(game_lines)
    end

    @processed_games_list
  end

  def game_format
    {
      "total_kills": 0,
      "players": [],
      "kills": {
      }
    }
  end

  private

  def split_games_from_array
    game_array = []
    game_counter = 1
    @log_file.each do |line|
      game_array.push(line)
      if line.include? 'ShutdownGame'
        @games_list[:"game_#{game_counter}"] = game_array
        game_array = []
        game_counter += 1
      end
    end
  end

  def process_game(game_lines)
    game = {}
    total_kills = 0
    players = []
    kills = {}
    kills_by_means = {}
    kills["<world>"] ||= 0

    game_lines.each do |line|
      line_splitted = split_line(line)
      if line.include?('ClientUserinfoChanged:')
        player_name = extract_player_name(line_splitted)
        players << player_name unless players.include?(player_name)
        kills[player_name] ||= 0
      elsif line.include?('Kill:')
        total_kills += 1
        killer, victim, weapon = extract_kill_info(line_splitted)

        kills_by_means[weapon] ||= 0

        kills_by_means[weapon] += 1
        kills[killer] += 1
        kills[victim] -= 1 if killer == '<world>'
      end
    end

    game['total_kills'] = total_kills
    game['players'] = players
    game['kills'] = kills
    game['kills_by_means'] = kills_by_means

    game
  end

  def extract_player_name(line)
    line[4]
  end

  def extract_kill_info(line)
    [line[5], line[7], line.last]
  end

  def split_line(line)
    line.gsub('\\', " ").split(" ")
  end
end
