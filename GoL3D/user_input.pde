//needed for userinput
boolean start = false;

boolean drawing = false;
void mousePressed() {
  if (!start) {
    int xCell = int(map(mouseX, 0, width, 0, gridSize));
    xCell = constrain(xCell, 0, gridSize-1);
    int yCell = int(map(mouseY, 0, height, 0, gridSize));
    yCell = constrain(yCell, 0, gridSize-1);

    if (iterations[xCell][yCell][0] == false) {
      drawing = true;
    } else {
      drawing = false;
    }
  }
}

void mouseReleased() {
  if (start)
    return;

  finished = true;
  if (startX != -1 && startY != -1 && endX != -1 && endY != -1) {
    selectCopy();
  }

  if (mouseButton == LEFT && pasting) {
    paste(mouseX, mouseY);
  }

  startX = -1;
  startY = -1;
  endX = -1;
  endY = -1;
}

void mouseDragged() {
  if (mouseButton == RIGHT && !pasting) {
    finished = false;
    selectCopy();
    return;
  }

  if (!start && !pasting) {
    int xCell = int(map(mouseX, 0, width, 0, gridSize));
    xCell = constrain(xCell, 0, gridSize-1);
    int yCell = int(map(mouseY, 0, height, 0, gridSize));
    yCell = constrain(yCell, 0, gridSize-1);

    if (drawing) {
      iterations[xCell][yCell][0] = true;
    } else {
      iterations[xCell][yCell][0] = false;
    }
  }
}

boolean left = false;
boolean right = false;
boolean up = false;
boolean down = false;
void keyPressed() {
  if (start) {
    if (keyCode == LEFT) {
      left = true;
    } else if (keyCode == RIGHT) {
      right = true;
    } else if (keyCode == UP) {
      up = true;
    } else if (keyCode == DOWN) {
      down = true;
    }
  }

  if (key == 27)
    key = 0;
}

void keyReleased() {
  if (!start) {
    if (keyCode == ENTER && !pasting) {
      z = findCenter(0);
      start = true;
    }

    if (key == ' ') {
      for (int i = 0; i < iterations.length; i++) {
        for (int j = 0; j < iterations[0].length; j++) {
          iterations[i][j][0] = false;
        }
      }
    }

    if (key == 'p' || key == 'P') {
      pasting = true;
    }

    if (pasting) {
      if (key == 27) {
        pasting = false;
      }

      if (keyCode == LEFT) {
        if (top && lefty) {
          top = false;
        } else if (top && !lefty) {
          lefty = true;
        } else if (!top && !lefty) {
          top = true;
        } else {
          lefty = false;
        }
        rotateCCW();
      }
      if (keyCode == RIGHT) {
        if (top && lefty) {
          lefty = false;
        } else if (top && !lefty) {
          top = false;
        } else if (!top && !lefty) {
          lefty = true;
        } else {
          top = true;
        }
        rotateCW();
      }
      if (keyCode == UP) {
        top = !top;
        flip();
      }
      if (keyCode == DOWN) {
        top = !top;
        flip();
      }
    }
  } else {
    if (key == 'm' || key == 'M') {
      record = true;
    }

    if (key == 'r' || key == 'R') {
      reset();
    }

    if (keyCode == LEFT) {
      left = false;
    } else if (keyCode == RIGHT) {
      right = false;
    } else if (keyCode == UP) {
      up = false;
    } else if (keyCode == DOWN) {
      down = false;
    }
  }
}

void reset() {
  start = false;
  counter = 0;
  clearCells();
  thetaX = 0;
  thetaY = 0;
  thetaZ = 0;
  record = false;
}