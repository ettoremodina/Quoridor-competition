import numpy as np
import random
from Quoridor_main import *

def find_zero(matrix):
    rows, cols = matrix.shape
    for i in range(rows):
        for j in range(cols):
            if matrix[i, j] == 0:
                return (i, j)
    return None


def rand_ai(game):
    player = game.players[game.current_player]
    valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
    return random.choice(list(valid_dirs.keys()))




def target_ai(game):
    player = game.players[game.current_player]
    opponent = game.players[2 - game.current_player]
    valid_dirs = valid_directions(game, player.row, player.col, game.current_player)
    distance_matrix = calculate_distance_matrix(game, game.current_player)

    if game.current_player == 1:
        target_row = 1
    else:
        target_row = BOARD_SIZE

    cur_pos = Cell(*find_zero(distance_matrix))
    cpos_value = distance_matrix[cur_pos.row, cur_pos.col]
    assert cpos_value == 0

    target_pos = Cell(target_row, np.argmin(np.where(distance_matrix[target_row, :] == -1, np.inf, distance_matrix[target_row, :])))
    tpos_value = np.min(np.where(distance_matrix[target_row, :] == -1, np.inf, distance_matrix[target_row, :]))

    iter = 0
    while tpos_value > 0 and iter < 30:
        valid_dirs_loop = valid_directions(
            game, matrix_to_board(target_pos.row), matrix_to_board(target_pos.col), game.current_player
        )
        for i, w in valid_dirs_loop.items():
            v = [w[0], w[1]]
            if target_pos.row + v[0] == board_to_matrix(opponent.row) and target_pos.col + v[1] == board_to_matrix(opponent.col):
                v[0] *= 2
                v[1] *= 2
            if distance_matrix[target_pos.row + v[0], target_pos.col + v[1]] == tpos_value - 1:
                target_pos.row += v[0]
                target_pos.col += v[1]
                tpos_value -= 1
                if tpos_value == 0:
                    return opposite_dir(i)
                break
        iter += 1

    return random.choice(list(valid_dirs.keys()))


ais_functions = [rand_ai, target_ai]
ais = ["rand AI", "target AI"]
