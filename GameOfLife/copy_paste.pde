int[][] copy;

int startX = -1, startY = -1, endX = -1, endY = -1;
boolean finished = false;
void selectCopy() {
  if (startX == -1 && startY == -1) {
    startX = int(map(mouseX, 0, width, 0, numX));
    startX = constrain(startX, 0, numX-1);
    startY = int(map(mouseY, 0, height, 0, numY));
    startY = constrain(startY, 0, numY-1);
  }

  endX = int(map(mouseX, 0, width, 0, numX));
  endX = constrain(endX, 0, numX-1);
  endY = int(map(mouseY, 0, height, 0, numY));
  endY = constrain(endY, 0, numY-1);

  endX++;
  endY++;

  if (finished) {
    top = true;
    left = true;

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

    copy = new int[endX-startX][endY-startY];
    for (int j = startY; j < endY; j++) {
      for (int i = startX; i < endX; i++) {
        copy[i-startX][j-startY] = cells[i][j];
      }
    }
    finished = false;
  }
}

boolean pasting = false;
void paste(int x, int y) {
  int xCell = int(map(x, 0, width, 0, numX));
  xCell = constrain(xCell, 0, numX-1);
  int yCell = int(map(y, 0, height, 0, numY));
  yCell = constrain(yCell, 0, numY-1);

  if (copy.length == 0) 
    return;

  int copyHeight = copy[0].length;
  int copyWidth = copy.length;

  if (top && left) {
    if (copyHeight > numY-yCell) {
      copyHeight = numY-yCell;
    }
    if (copyWidth > numX-xCell) {
      copyWidth = numX-xCell;
    }

    for (int j = 0; j < copyHeight; j++) {
      for (int i = 0; i < copyWidth; i++) {
        if (cells[xCell+i][yCell+j] != 1)
          cells[xCell+i][yCell+j] = copy[i][j];
      }
    }
  } else if (top && !left) {
    if (copyHeight > numY-yCell) {
      copyHeight = numY-yCell;
    }
    if (copyWidth > xCell+1) {
      copyWidth -= copyWidth-xCell-1;
    }

    for (int j = 0; j < copyHeight; j++) {
      for (int i = copy.length-copyWidth; i < copy.length; i++) {
        if (cells[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j] != 1)
          cells[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j] = copy[i][j];
      }
    }
  } else if (!top && !left) {
    if (copyHeight > yCell+1) {
      copyHeight -= copyHeight-yCell-1;
    }
    if (copyWidth > xCell+1) {
      copyWidth -= copyWidth-xCell-1;
    }

    for (int j = copy[0].length-copyHeight; j < copy[0].length; j++) {
      for (int i = copy.length-copyWidth; i < copy.length; i++) {
        if (cells[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j-copyHeight+1-(copy[0].length-copyHeight)] != 1)
          cells[xCell-copyWidth+i+1-(copy.length-copyWidth)][yCell+j-copyHeight+1-(copy[0].length-copyHeight)] = copy[i][j];
      }
    }
  } else {
    if (copyHeight > yCell+1) {
      copyHeight -= copyHeight-yCell-1;
    }
    if (copyWidth > numX-xCell) {
      copyWidth = numX-xCell;
    }

    for (int j = copy[0].length-copyHeight; j < copy[0].length; j++) {
      for (int i = 0; i < copyWidth; i++) {
        if (cells[xCell+i][yCell+j-copyHeight+1-(copy[0].length-copyHeight)] != 1)
          cells[xCell+i][yCell+j-copyHeight+1-(copy[0].length-copyHeight)] = copy[i][j];
      }
    }
  }
}

boolean top = true, left = true;
void showPaste() {
  int xCell = int(map(mouseX, 0, width, 0, numX));
  xCell = constrain(xCell, 0, numX-1);
  int yCell = int(map(mouseY, 0, height, 0, numY));
  yCell = constrain(yCell, 0, numY-1);

  int copyWidth = copy.length;
  int copyHeight = copy[0].length;

  stroke(50);
  rectMode(CORNER);
  fill(230, 75);

  if (top && left) {
    rect(-cellSize*1/2, -cellSize*1/2, copyWidth*cellSize, copyHeight*cellSize);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        fill((copy[i][j] == 1)?color(12, 242, 10):color(0, 75));
        if ((copy[i][j] == 1)) {
          stroke(50);
        } else {
          noStroke();
        }
        rect(i*cellSize-cellSize*1/2, j*cellSize-cellSize*1/2, cellSize, cellSize);
      }
    }
  } else if (top && !left) {
    rect(-copyWidth*cellSize+cellSize*1/2, -cellSize*1/2, copyWidth*cellSize, copyHeight*cellSize);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        fill((copy[i][j] == 1)?color(12, 242, 10):color(0, 75));
        if ((copy[i][j] == 1)) {
          stroke(50);
        } else {
          noStroke();
        }
        rect(-copyWidth*cellSize+i*cellSize+cellSize*1/2, j*cellSize-cellSize*1/2, cellSize, cellSize);
      }
    }
  } else if (!top && !left) {
    rect(-copyWidth*cellSize+cellSize*1/2, -copyHeight*cellSize+cellSize*1/2, 
    copyWidth*cellSize, copyHeight*cellSize);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        fill((copy[i][j] == 1)?color(12, 242, 10):color(0, 75));
        if ((copy[i][j] == 1)) {
          stroke(50);
        } else {
          noStroke();
        }
        rect(-copyWidth*cellSize+i*cellSize+cellSize*1/2, -copyHeight*cellSize+j*cellSize+cellSize*1/2, 
        cellSize, cellSize);
      }
    }
  } else {
    rect(-cellSize*1/2, -copyHeight*cellSize+cellSize*1/2, 
    copyWidth*cellSize, copyHeight*cellSize);

    for (int i = 0; i < copyWidth; i++) {
      for (int j = 0; j < copyHeight; j++) {
        fill((copy[i][j] == 1)?color(12, 242, 10):color(0, 75));
        if ((copy[i][j] == 1)) {
          stroke(50);
        } else {
          noStroke();
        }
        rect(i*cellSize-cellSize*1/2, -copyHeight*cellSize+j*cellSize+cellSize*1/2, 
        cellSize, cellSize);
      }
    }
  }
}

void rotateCCW() {
  // reverse each row
  for (int i = 0; i < copy.length/2; i++) {
    int[] t = copy[i];
    copy[i] = copy[copy.length-1-i];
    copy[copy.length-1-i] = t;
  }
  //  transpose
  int[][] temp = new int[copy[0].length][copy.length];
  for (int j = 0; j < copy[0].length; j++) {
    for (int i = 0; i < copy.length; i++) {
      temp[j][i] = copy[i][j];
    }
  }
  copy = temp;
}

void rotateCW() {
  // transpose
  int[][] temp = new int[copy[0].length][copy.length];
  for (int j = 0; j < copy[0].length; j++) {
    for (int i = 0; i < copy.length; i++) {
      temp[j][i] = copy[i][j];
    }
  }
  copy = temp;
  // reverse each row
  for (int i = 0; i < copy.length/2; i++) {
    int[] t = copy[i];
    copy[i] = copy[copy.length-1-i];
    copy[copy.length-1-i] = t;
  }
}

void flip() {
  int[][] temp = new int[copy.length][copy[0].length];
  for (int j = 0; j < copy[0].length; j++) {
    for (int i = 0; i < copy.length; i++) {
      temp[i][copy[0].length-1-j] = copy[i][j];
    }
  }
  copy = temp;
}

boolean typing = false;
boolean saving = false;
String filename = "filename";
int w;
void saveScreen() {
  String s = "Enter a file name:";

  if (textWidth(s) > textWidth(filename)) {
    w = (int)textWidth(s)+10;
  } else {
    w = (int)textWidth(filename)+10;
  }

  fill(0);
  rectMode(CENTER);
  rect(width/2, height/2, w, textAscent()*3);

  textAlign(CENTER);
  fill(color(12, 242, 10));

  textSize(30);
  text(s, width/2, height/2);

  textSize(30);
  text(filename, width/2, height/2+textAscent()+5);

  if (!typing) {
    if (filename.compareTo("show all") == 0) {
      filename = "filename";
      typing = true;
    }
    String homeDir = System.getProperty("user.home");
    String folder = ".gol";
    filename = filename.replace(".txt", "");
    String path = homeDir+"/"+folder+"/"+filename+".txt";

    File f = new File(path);
    if (f.exists())
      f.delete();

    output = createWriter(path);
    for (int j = 0; j < numY; j++) {
      for (int i = 0; i < numX; i++) {
        output.print(cells[i][j]);
      }
      output.println();
    }
    output.flush();
    output.close();
    filename = "filename";
    saving = false;
  }
}

boolean loading = false;
boolean showall = false;
String[] filenames;
String longestName;
int mouseLocation = -1;
void loadScreen() {

  if (!showall) {
    String s = "Enter a file name to load:";

    if (textWidth(s) > textWidth(filename)) {
      w = (int)textWidth(s)+10;
    } else {
      w = (int)textWidth(filename)+10;
    }

    fill(0);
    rectMode(CENTER);
    rect(width/2, height/2, w, textAscent()*3);

    textAlign(CENTER);
    fill(color(12, 242, 10));

    textSize(30);
    text(s, width/2, height/2);

    textSize(30);
    text(filename, width/2, height/2+textAscent()+5);
  }

  if (showall) {
    textSize(30);
    // display rectangle 
    rectMode(CORNER);
    fill(0);
    strokeWeight(4);
    stroke(color(12, 242, 10));
    float yH = ((filenames.length*textAscent()+10)>height-5)?height-5:filenames.length*textAscent()+10;
    rect(1, 1, textWidth(longestName)+15, yH, 10);

    strokeWeight(1);
    for (int i = 0; i < filenames.length; i++) {
      textAlign(LEFT);
      if (mouseLocation == i) {
        fill(color(#009D11));
      } else {
        fill(color(12, 242, 10));
      }
      text(filenames[i], 10, i*textAscent()+30);
    }

    if (mouseLocation < filenames.length && mouseLocation != -1)
      cursor(HAND);
    else
      cursor(ARROW);

    if (mouseX < textWidth(longestName)+13 && mouseY < yH) {
      mouseLocation = (int)map(mouseY, 0, yH, 0, filenames.length);
      mouseLocation = (int)constrain(mouseLocation, 0, filenames.length);
    } else {
      mouseLocation = -1;
    }
  }

  if (!typing) {
    String homeDir = System.getProperty("user.home");
    String folder = ".gol";
    if (filename.compareTo("show all") == 0) {
      longestName = "";
      filename = "filename";
      typing = true;
      showall = true;
      File[] tempNames = new File(homeDir+"/"+folder).listFiles();
      filenames = new String[tempNames.length];
      for (int i = 0; i < tempNames.length; i++) {
        filenames[i] = tempNames[i].getName().replace(".txt", "");
        if (filenames[i].length() > longestName.length()) 
          longestName = filenames[i];
      }
      return;
    }
    filename = filename.replace(".txt", "");
    String path = homeDir+"/"+folder+"/"+filename+".txt";
    // check to see if the filename exists. if it doesnt get back into the loop
    File f = new File(path);
    if (!f.exists()) {
      typing = true;
      return;
    }

    for (int i = 0; i < numX; i++) {
      for (int j = 0; j < numY; j++) {
        cells[i][j] = 0;
        nextTick[i][j] = 0;
      }
    }

    String[] lines = loadStrings(path);
    for (int j = 0; j < lines.length; j++) {
      char[] ints = lines[j].toCharArray();
      for (int i = 0; i < ints.length; i++) {
        cells[i][j] = (ints[i] == 48)?0:1;
      }
    }

    filename = "filename";
    loading = false;
  }
}