module Quoridor
# chat gpt created

export play

const EMPTY, PAWN, WALL = 0, 1, 2
const DIRECTIONS = Dict('w' => (-1, 0), 's' => (1, 0), 'a' => (0, -1), 'd' => (0, 1))
const BOARD_SIZE = 11
const MAX_WALLS = 10

mutable struct Player
    row::Int
    col::Int
    walls::Int
end

mutable struct Game
    board::Array{Int,2}
    players::Array{Player,1}
    current_player::Int
end

function Game()
    board = fill(EMPTY, BOARD_SIZE, BOARD_SIZE)
    players = [Player(BOARD_SIZE, ceil(Int, BOARD_SIZE / 2), MAX_WALLS),
               Player(1, ceil(Int, BOARD_SIZE / 2), MAX_WALLS)]
    return Game(board, players, 1)
end


function print_board(game::Game)
    PAD = 2
    print(" "^(PAD+1))
    for col in 1:BOARD_SIZE
        print("$(col%10==0 ? " " : col%10) ")
    end
    print("\n  ┌")
    print("──"^(BOARD_SIZE),"┐")
    print("\n")
    for row in 1:BOARD_SIZE
        print(row%10==0 ? " "^PAD : rpad(row%10,PAD) ,"│")
        for col in 1:BOARD_SIZE
            if all([(p.row == row) && (p.col == col) for p in game.players])
                # @show game.players[1]
                print("B ")
            elseif (game.players[1].row == row && game.players[1].col == col)
                print("1 ")
            elseif (game.players[2].row == row && game.players[2].col == col)
                print("2 ")
            elseif game.board[row, col] == WALL
                print("# ")
            else
                print(". ")
            end
        end
        println("│")
    end
    println(" "^PAD,"└","──"^BOARD_SIZE,"┘")
    println("Player 1 Walls: ", game.players[1].walls, " Player 2 Walls: ", game.players[2].walls)
end

function move_pawn(game::Game, direction::Char)
    dr, dc = DIRECTIONS[direction]
    player = game.players[game.current_player]
    new_row, new_col = player.row + dr, player.col + dc

    if new_row >= 1 && new_row <= BOARD_SIZE && new_col >= 1 && new_col <= BOARD_SIZE
        if game.board[new_row, new_col] == EMPTY
            player.row, player.col = new_row, new_col
            return 1
        else
            @info "Can't move there! there is a wall. Select a valid move."
            return 0
        end
    end
end

function place_wall(game::Game, row::Int, col::Int)
    if game.players[game.current_player].walls > 0
        if row >= 1 && row <= BOARD_SIZE && col >= 1 && col <= BOARD_SIZE && game.board[row, col] == EMPTY
            game.board[row, col] = WALL
            game.players[game.current_player].walls -= 1
            return 1
        else
            @info "Wrong coordinates. Select a valid move."
            return 0
        end
    end
end

function switch_player(game::Game)
    game.current_player = 3 - game.current_player
end

function play()
    game = Game()
    while true
        println("Current board:")
        print_board(game)
        println("Player ", game.current_player, "'s turn. Move (w/a/s/d) or place wall (e.g., 'wall 5 5'):")

        moved = 0
        while moved==0
            input = readline()
            if occursin("wall", input)
                args = split(input)
                # @show args
                row, col = parse(Int, args[2]), parse(Int, args[3])
                moved = place_wall(game, row, col)
            else
                moved = move_pawn(game, input[1])
            end
        end
        switch_player(game)

        # Add winning condition check here
        # If a player reaches the opposite side, they win.
    end
end

end # module

# To play, uncomment the next line and run this script
# Quoridor.play()
