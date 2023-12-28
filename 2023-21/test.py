maze = [line.strip() for line in open("2023-21\input.txt").readlines()]
height = len(maze)
width = len(maze[0])


def get_reachable_plots(moves, startpoint):
    queue = {startpoint}
    new_queue = set()
    for _ in range(moves):
        new_queue = set()
        while queue:
            c_y, c_x = queue.pop()
            neighbors = {
                (n_y, n_x)
                for m_y, m_x in [(1, 0), (0, 1), (-1, 0), (0, -1)]
                if 0 <= (n_y := c_y + m_y) < height
                and 0 <= (n_x := c_x + m_x) < width
                and maze[n_y][n_x] != "#"
            }
            new_queue |= neighbors
        queue = new_queue
    return new_queue

print(len(get_reachable_plots(64,(65,65))))
full_square_X = len(get_reachable_plots(101, (65, 65)))
full_square_O = len(get_reachable_plots(100, (65, 65)))
diamond_X = len(get_reachable_plots(65, (65, 65)))
diamond_O = len(get_reachable_plots(64, (65, 65)))


total_steps = 26501365
full_jumps = 26501365 // 131
length = (full_jumps - 1) * 2 + 1
inner_squares = length**2 // 2 + 1
odd_jumps = full_jumps - 1 | 1
o_squares = (odd_jumps * (odd_jumps + 2) // 4 + 1) * 4
even_jumps = full_jumps + 1 & -2
x_squares = (even_jumps * (even_jumps - 2) // 4) * 4 + 1


full_plot_count = (
    x_squares * full_square_X
    + o_squares * full_square_O
    + 2 * full_square_X
    + 2 * diamond_X
    + (full_square_O - diamond_O) * full_jumps
    + (4 * full_square_X - ((full_square_X - diamond_X))) * (full_jumps - 1)
    - full_jumps
)

print(full_plot_count)