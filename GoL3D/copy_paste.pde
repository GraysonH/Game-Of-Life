//fill this in with the methods from the other game of life project.

boolean[][] copy;

int startX = -1, startY = -1, endX = -1, endY = -1;
boolean finished = false;
void selectCopy() {
  if (startX == -1 && startY == -1) {
    startX = int(map(mouseX, 0, width, 0, iterations.length));
    startX = constrain(startX, 0, iterations.length-1);
    startY = int(map(mouseY, 0, height, 0, iterations[0].length));
    startY = constrain(startY, 0, iterations[0].length-1);
  }

  endX = int(map(mouseX, 0, width, 0, iterations.length));
  endX = constrain(endX, 0, iterations.length-1);
  endY = int(map(mouseY, 0, height, 0, iterations[0].length));
  endY = constrain(endY, 0, iterations[0].length-1);

  endX++;
  endY++;

  if (finished) {
    top = true;
    lefty = true;

    if (endY < startY) {
      int temp = endY;
      endY = startY;
      startY = temp;
    }
    if (endX < startX) {
      int temp = endX;
      endX = startX;
      startX = temp;
    }

    copy = new boolean[endX-startX][endY-startY];
    for (int j = startY; j < endY; j++) {
      for (int i = startX; i < endX; i++) {
        copy[i-startX][j-startY] = iterations[i][j][0];
      }
    }
    finished = false;
  }
}

boolean pasting = false;
void paste(int x, int y) {
  int xCell = int(map(x, 0, width, 0, iterations.length));
  xCell = constrain(xCell, 0, iterations.length-1);
  int yCell = int(map(y, 0, height, 0, iterations[0].length));
  yCell = constrain(yCell, 0, iterations[0].length-1);

  if (copy.length == 0) 
    return;

  int copyHeight = copy[0].length;
  int copyWidth = copy.length;

  if (top && lefty) {
    if (copyHeight > iterations[0].length-yCell) {
      copyHeight = iterations[0].length-yCell;
    }
    if (copyWidth > iterations.length-xCell) {
      copyWidth = iterations.length-xCell;
    }

    for (int j = 0; j < copyHeight; j++) {
      for (int i = 0; i < copyWidth; i++) {
        if (!iterations[xCell+i][yCell+j][0])
          iterations[xCell+i][yCell+j][0] = copy[i][j];
      }
    }
  } else if (top && !lefty) {
    if (copyHeight > iterations[0].length-yCell) {
      copyHeight = iterations[0].length-yCell;
    }
    if (copyWidth > xCell+1) {
      copyWidth -= copyWidth-xCell-1;
    }

    for (int j = 0; j < copyHeight; j++) {
      for (int i = copy.length-copyWidth; i < copy.length; i++) {
        if (!iterations[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j][0])
          iterations[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j][0] = copy[i][j];
      }
    }
  } else if (!top && !lefty) {
    if (copyHeight > yCell+1) {
      copyHeight -= copyHeight-yCell-1;
    }
    if (copyWidth > xCell+1) {
      copyWidth -= copyWidth-xCell-1;
    }

    for (int j = copy[0].length-copyHeight; j < copy[0].length; j++) {
      for (int i = copy.length-copyWidth; i < copy.length; i++) {
        if (!iterations[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j-copyHeight+1-(copy[0].length-copyHeight)][0])
          iterations[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j-copyHeight+1-(copy[0].length-copyHeight)][0] = copy[i][j];
      }
    }
  } else {
    if (copyHeight > yCell+1) {
      copyHeight -= copyHeight-yCell-1;
    }
    if (copyWidth > iterations.length-xCell) {
      copyWidth = iterations.length-xCell;
    }

    for (int j = copy[0].length-copyHeight; j < copy[0].length; j++) {
      for (int i = 0; i < copyWidth; i++) {
        if (!iterations[xCell+i][yCell+j-copyHeight+1-(copy[0].length-copyHeight)][0])
          iterations[xCell+i][yCell+j-copyHeight+1-(copy[0].length-copyHeight)][0] = copy[i][j];
      }
    }
  }
}

boolean top = true, lefty = true;
void showPaste() {
  int xCell = int(map(mouseX, 0, width, 0, iterations.length));
  xCell = constrain(xCell, 0, iterations.length-1);
  int yCell = int(map(mouseY, 0, height, 0, iterations[0].length));
  yCell = constrain(yCell, 0, iterations[0].length-1);

  int copyWidth = copy.length;
  int copyHeight = copy[0].length;

  stroke(100);
  rectMode(CORNER);
  fill(230, 75);

  if (top && lefty) {
    rect(-spacing*1/2, -spacing*1/2, copyWidth*spacing, copyHeight*spacing);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        if ((copy[i][j])) {
          stroke(100);
        } else {
          noStroke();
        }
        fill((copy[i][j])?color(#FCB80A):color(0, 75));
        rect(i*spacing-spacing*1/2, j*spacing-spacing*1/2, spacing, spacing);
      }
    }
  } else if (top && !lefty) {
    rect(-copyWidth*spacing+spacing*1/2, -spacing*1/2, copyWidth*spacing, copyHeight*spacing);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        if ((copy[i][j])) {
          stroke(100);
        } else {
          noStroke();
        }
        fill((copy[i][j])?color(#FCB80A):color(0, 75));
        rect(-copyWidth*spacing+i*spacing+spacing*1/2, j*spacing-spacing*1/2, spacing, spacing);
      }
    }
  } else if (!top && !lefty) {
    rect(-copyWidth*spacing+spacing*1/2, -copyHeight*spacing+spacing*1/2, 
      copyWidth*spacing, copyHeight*spacing);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        if ((copy[i][j])) {
          stroke(100);
        } else {
          noStroke();
        }
        fill((copy[i][j])?color(#FCB80A):color(0, 75));
        rect(-copyWidth*spacing+i*spacing+spacing*1/2, -copyHeight*spacing+j*spacing+spacing*1/2, 
          spacing, spacing);
      }
    }
  } else {
    rect(-spacing*1/2, -copyHeight*spacing+spacing*1/2, 
      copyWidth*spacing, copyHeight*spacing);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        if ((copy[i][j])) {
          stroke(100);
        } else {
          noStroke();
        }
        fill((copy[i][j])?color(#FCB80A):color(0, 75));
        rect(i*spacing-spacing*1/2, -copyHeight*spacing+j*spacing+spacing*1/2, 
          spacing, spacing);
      }
    }
  }
}

void rotateCCW() {
  // reverse each row
  for (int i = 0; i < copy.length/2; i++) {
    boolean[] t = copy[i];
    copy[i] = copy[copy.length-1-i];
    copy[copy.length-1-i] = t;
  }
  //  transpose
  boolean[][] temp = new boolean[copy[0].length][copy.length];
  for (int j = 0; j < copy[0].length; j++) {
    for (int i = 0; i < copy.length; i++) {
      temp[j][i] = copy[i][j];
    }
  }
  copy = temp;
}

void rotateCW() {
  // transpose
  boolean[][] temp = new boolean[copy[0].length][copy.length];
  for (int j = 0; j < copy[0].length; j++) {
    for (int i = 0; i < copy.length; i++) {
      temp[j][i] = copy[i][j];
    }
  }
  copy = temp;
  // reverse each row
  for (int i = 0; i < copy.length/2; i++) {
    boolean[] t = copy[i];
    copy[i] = copy[copy.length-1-i];
    copy[copy.length-1-i] = t;
  }
}

void flip() {
  boolean[][] temp = new boolean[copy.length][copy[0].length];
  for (int j = 0; j < copy[0].length; j++) {
    for (int i = 0; i < copy.length; i++) {
      temp[i][copy[0].length-1-j] = copy[i][j];
    }
  }
  copy = temp;
}