function find_zero(matrix::Matrix{Int})
    rows, cols = size(matrix)
    for i in 1:rows
        for j in 1:cols
            matrix[i, j] == 0  && return (i, j) 
        end
    end
    return nothing
end

##############
##   AIs    ######################################################
##############
function rand_ai(game::Game)
    player = game.players[game.current_player]
    valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
    return string(rand(keys(valid_dirs)))
end

function target_ai(game::Game)
    player = game.players[game.current_player]
    opponent = game.players[3-game.current_player]
    valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
    distance_matrix = calculate_distance_matrix(game, game.current_player)

    if game.current_player==1 
        target_row = 1

        cur_pos = [game.players[game.current_player].row,game.players[game.current_player].col]
        target_pos = [target_row,argmin(replace(distance_matrix[target_row,:],-1=>+Inf64))]

        'w' in keys(valid_dirs) && return "w"
        'q' in keys(valid_dirs) && return "q"
        'e' in keys(valid_dirs) && return "e"
        cur_pos[2]< target_pos[2] && 'd' in keys(valid_dirs) && return "d"
        cur_pos[2]>=target_pos[2] && 'a' in keys(valid_dirs) && return "a"
        return string(rand(keys(valid_dirs)))
    else 
        target_row = BOARD_SIZE

        cur_pos = Cell(find_zero(distance_matrix)...)
        # @show cur_pos
        cpos_value = distance_matrix[cur_pos.row,cur_pos.col]
        @assert cpos_value==0
        target_pos = Cell(target_row,argmin(replace(distance_matrix[target_row,:],-1=>+Inf64)))
        tpos_value = minimum(replace(distance_matrix[target_row,:],-1=>+Inf64))

        # best_move = collect(keys(valid_dirs))[1]

        iter = 0
        while tpos_value>0 && iter<30
            @show tpos_value
            valid_dirs_loop = valid_directions(game, matrix_to_board(target_pos.row), matrix_to_board(target_pos.col), 2)
            for (i,w) in valid_dirs_loop
                v = [w[1],w[2]] 
                @show opponent.row, opponent.col
                @show board_to_matrix(opponent.row), board_to_matrix(opponent.col)
                # @show distance_matrix[target_pos.row+v[1],target_pos.col+v[2]]
                if target_pos.row+v[1]==board_to_matrix(opponent.row) && target_pos.col+v[2]==board_to_matrix(opponent.col)
                    @info "Opponent update"
                    v[1] *= 2
                    v[2] *= 2
                end
                if distance_matrix[target_pos.row+v[1],target_pos.col+v[2]] == tpos_value-1
                    @info "treating direction $i -> good"
                    target_pos.row += v[1]
                    target_pos.col += v[2]
                    tpos_value = tpos_value-1
                    # @show tpos_value
                    if tpos_value==0
                        # @show string(opposite_dir(i))
                        return string(opposite_dir(i))
                    end
                    break
                else
                    @info "treating direction $i -> bad"
                end
            end
            iter+=1
        end

        # @show cur_pos
        # @show target_pos
        # @show tpos_value

        'x' in keys(valid_dirs) && return "x"
        'c' in keys(valid_dirs) && return "c"
        'z' in keys(valid_dirs) && return "z"
        cur_pos.col< target_pos.col && 'd' in keys(valid_dirs) && return "d"
        cur_pos.col>=target_pos.col && 'a' in keys(valid_dirs) && return "a"
        return string(rand(keys(valid_dirs)))
    end
end
##################
##   end AIs    ######################################################
##################

ais_functions = [rand_ai, target_ai]
ais = ["rand AI", "target AI"]

