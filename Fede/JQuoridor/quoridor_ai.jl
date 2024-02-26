
##############
##   AIs    ######################################################
##############
function rand_ai(game::Game)
    return string(rand(keys(DIRECTIONS)))
end

function smart_ai(game::Game)
    distance_matrix = calculate_distance_matrix(game, game.current_player)
    if game.current_player==1 
        target_row = 1

        cur_pos = [game.players[game.current_player].row,game.players[game.current_player].col]
        target_pos = [target_row,argmin(replace(distance_matrix[target_row,:],-1=>+Inf64))]

        cur_pos[2]==target_pos[2] && is_valid_dir(game,'w') && return "w"
        cur_pos[2]< target_pos[2] && is_valid_dir(game,'d') && return "d"
        cur_pos[2]>=target_pos[2] && is_valid_dir(game,'a') && return "a"
        return "s"
    else 
        target_row = BOARD_SIZE

        cur_pos = [game.players[game.current_player].row,game.players[game.current_player].col]
        target_pos = [target_row,argmin(replace(distance_matrix[target_row,:],-1=>+Inf64))]

        cur_pos[2]==target_pos[2] && is_valid_dir(game,'s') && return "s"
        cur_pos[2]< target_pos[2] && is_valid_dir(game,'d') && return "d"
        cur_pos[2]>=target_pos[2] && is_valid_dir(game,'a') && return "a"
        return "w"
    end
end
##################
##   end AIs    ######################################################
##################

ais_functions = [rand_ai,smart_ai]
