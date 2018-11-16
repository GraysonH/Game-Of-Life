Program idea based on "https://www.youtube.com/watch?v=iiEQg-SHY1g&t=28s"

Rules to Conway's Game of Life:
1. Any live cell with fewer than two live neighbors dies, as if caused by under-population.
 2. Any live cell with two or three live neighbors lives on to the next generation.
 3. Any live cell with more than three live neighbors dies, as if by overcrowding.
 4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

The idea is to allow the user to draw any design within the grid that is shown upon opening the application. Then when ENTER is hit it will begin to grow. Each new iteration, based on the rules of Conway's Game of Life, will be added on top of the last. This will give the appearance of a structure growing from the base layer. It is limited to 50 layers.

User Interaction:
The user can draw and delete squares on the first screen with the grid. Draw by clicking on an empty square and dragging the mouse. Erase by clicking on a filled square and dragging the mouse.
During the drawing phase the user can right click and drag to copy a certain drawing or design. By pressing 'p' the user can paste the design that was previously copied. While pasting the user can use the arrow keys to rotate and flip the copied design. SPACE will clear the board.

If 'r' is pressed while viewing the 3D structure the user will return to the drawing board.

If 'm' is pressed while viewing the 3D structure the program will output an OBJ file containing the 3D structure. This can be used for 3D printing.
