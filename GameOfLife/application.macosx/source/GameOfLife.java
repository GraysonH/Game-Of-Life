import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.File; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GameOfLife extends PApplet {

/*
 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
 2. Any live cell with two or three live neighbours lives on to the next generation.
 3. Any live cell with more than three live neighbours dies, as if by overcrowding.
 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
 */




int cellSize = 10;
int probability = 0;

int[][] cells;
int[][] nextTick;

int numY, numX;

PFont f;

boolean setup = false;
boolean gettingProb = true;
boolean clear = false;
boolean pause = false;

PrintWriter output;

public void setup() {
  size(1000, 700);
  frameRate(30);
  strokeWeight(1);

  smooth();

  f = createFont("LCD_Solid.ttf", 30);
  textFont(f);

  numX = width/cellSize;
  numY = height/cellSize;

  cells = new int[numX][numY];
  nextTick = new int[numX][numY];
}

int tickToggle = 0;
public void draw() {

  if (setup)
    setCells();

  if (gettingProb) {
    displayMain();
    displayInput();
  } else {
    if (!pause) {
      displayCells();
      if (tickToggle%6==0) {
        nextTick();
        tickToggle = 0;
      }
      tickToggle++;
    } else {
      displayCells();
      if (saving) {
        saveScreen();
      } else if (loading) {
        loadScreen();
      } else if (pasting) {
        pushMatrix();
        translate(mouseX, mouseY);
        showPaste();
        popMatrix();
      }
    }

    if (clear) {
      for (int i = 0; i < numX; i++) {
        for (int j = 0; j < numY; j++) {
          cells[i][j] = 0;
          nextTick[i][j] = 0;
        }
      }
      clear = false;
    }

    if (startX != -1 && startY != -1) {
      stroke(255);
      fill(230, 75);
      pushMatrix();
      rectMode(CORNER);
      translate(startX*cellSize, startY*cellSize);
      rect(0, 0, (endX-startX)*cellSize, (endY-startY)*cellSize);
      popMatrix();
    }
  }
}

public void setCells() {
  //init cells and nextTick
  for (int i = 0; i < numX; i++) {
    for (int j = 0; j < numY; j++) {
      cells[i][j] = ((int)random(0, 100) < probability) ? 1:0;
      nextTick[i][j] = 0;
    }
  }
  if (probability == 0)
    pause = true;
  setup = false;
}

public void displayMain() {
  background(0);
  textAlign(CENTER);
  fill(color(12, 242, 10));

  textSize(50);
  text("The Game of Life", width/2, height/4);

  textSize(30);
  text("Probability of Life:", width/2, height/2);

  textSize(10);
  textAlign(LEFT);
  text("Original Game of Life was developed by John Conway in 1970.", 
  textWidth("O"), height-textAscent());
}

String input = "";
int cursorToggle = 0;

public void displayInput() {
  textAlign(CENTER);
  textSize(30);
  text("%", width/2+textWidth("."), height/2+60);

  if (cursorToggle < frameRate/2) {
    float x = width/2;
    float dy = 15;
    stroke(color(12, 242, 10));
    line(x, height/2-dy+45, x, height/2+dy+45);
  }
  cursorToggle++;
  if (cursorToggle >= frameRate)
    cursorToggle = 0;

  textAlign(RIGHT);
  text(input, width/2, height/2+60);
}

public void displayCells() {
  background(0);
  stroke(50);
  rectMode(CORNER);
  for (int i = 0; i < numX; i++) {
    for (int j = 0; j < numY; j++) {
      fill((cells[i][j] == 1)?color(12, 242, 10):color(0));
      rect(i*cellSize, j*cellSize, cellSize, cellSize);
    }
  }
}

public void nextTick() {
  for (int i = 0; i < numX; i++) {
    for (int j = 0; j < numY; j++) {
      int n = numNeighbors(i, j);
      if (cells[i][j] == 1) {
        if (n < 2) 
          nextTick[i][j] = 0;
        else if (n == 2|| n == 3)
          nextTick[i][j] = 1;
        else
          nextTick[i][j] = 0;
      } else {
        if (n == 3)
          nextTick[i][j] = 1;
      }
    }
  }

  //copy nextTick[][] to cells[][]
  for (int i = 0; i < numX; i++) {
    for (int j = 0; j < numY; j++) {
      cells[i][j] = nextTick[i][j];
    }
  }
}

public int numNeighbors(int x, int y) {
  int toReturn = 0;

  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j<=y+1; j++) {
      if (i==x && j==y)
        continue;
      else if (i < 0 || i >= numX)
        continue;
      else if (j < 0 || j >= numY)
        continue;
      else if (cells[i][j] == 1)
        toReturn++;
      else 
        continue;
    }
  }

  return toReturn;
}

int[][] copy;

int startX = -1, startY = -1, endX = -1, endY = -1;
boolean finished = false;
public void selectCopy() {
  if (startX == -1 && startY == -1) {
    startX = PApplet.parseInt(map(mouseX, 0, width, 0, numX));
    startX = constrain(startX, 0, numX-1);
    startY = PApplet.parseInt(map(mouseY, 0, height, 0, numY));
    startY = constrain(startY, 0, numY-1);
  }

  endX = PApplet.parseInt(map(mouseX, 0, width, 0, numX));
  endX = constrain(endX, 0, numX-1);
  endY = PApplet.parseInt(map(mouseY, 0, height, 0, numY));
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
public void paste(int x, int y) {
  int xCell = PApplet.parseInt(map(x, 0, width, 0, numX));
  xCell = constrain(xCell, 0, numX-1);
  int yCell = PApplet.parseInt(map(y, 0, height, 0, numY));
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
public void showPaste() {
  int xCell = PApplet.parseInt(map(mouseX, 0, width, 0, numX));
  xCell = constrain(xCell, 0, numX-1);
  int yCell = PApplet.parseInt(map(mouseY, 0, height, 0, numY));
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

public void rotateCCW() {
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

public void rotateCW() {
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

public void flip() {
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
public void saveScreen() {
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
public void loadScreen() {

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
        fill(color(0xff009D11));
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


char[] badKeys = {
  33, 34, 35, 36, 37, 38, 40, 41, 42, 43, 
  47, 58, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
  89, 90, 92, 94, 95, 96, 123, 124, 125
};

public void keyReleased() { 
  if (gettingProb) {
    if (keyCode == ENTER || keyCode == RETURN) {
      if (input.equals(""))
        return;
      probability = Integer.parseInt(input);
      setup = true;
      gettingProb = false;
    }

    if (key >= '0' && key <= '9') {
      input+=key;
      if (Integer.parseInt(input) > 100)
        input = input.substring(0, input.length()-1);
    }
    if (keyCode == DELETE || keyCode == BACKSPACE)
      input = input.substring(0, input.length()-1);
  } else if (!typing) {

    if (key == 'R' || key == 'r') {
      setCells();
    }

    if (key == 'C' || key == 'c') {
      clear = true;
      pause = true;
    }

    if (key == 'P' || key == 'p') {
      pasting = true;
    }

    if (key == 'n' || key == 'N') {
      gettingProb = true;
      pause = false;
    }

    if (key == 's' || key == 'S') {
      pause = true;
      saving = true;
      typing = true;
      return;
    }

    if (key == 'l' || key == 'L') {
      pause = true;
      loading = true;
      typing = true;
      return;
    }

    if (key == ' ') {
      pause = !pause;
      pasting = false;
      loading = false;
      saving = false;
      typing = false;
    }

    if (pasting) {
      if (key == 27) {
        pasting = false;
      }

      if (keyCode == LEFT) {
        if (top && left) {
          top = false;
        } else if (top && !left) {
          left = true;
        } else if (!top && !left) {
          top = true;
        } else {
          left = false;
        }
        rotateCCW();
      }
      if (keyCode == RIGHT) {
        if (top && left) {
          left = false;
        } else if (top && !left) {
          top = false;
        } else if (!top && !left) {
          left = true;
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
  }

  //showall
  if (showall && key == 27) {
    showall = false;
    loading = true;
    cursor(ARROW);
    filename = "";
  } else if (typing) {
    if (key == 27) {
      typing = false;
      saving = false;
      loading = false;
      filename = "filename";
      return;
    }
    if (filename.equals("filename"))
      filename = "";

    if (key == ENTER) {
      typing = false;
    } else if (key == BACKSPACE && filename.length() > 0) {
      filename = filename.substring(0, filename.length() - 1);
    } else {
      if (Arrays.binarySearch(badKeys, key) >= 0)
        return;
      filename += key;
    }
  }
}

int px, py;
boolean draw = true;
boolean dragged = false;
public void mouseDragged() {
  dragged = true;
  if (!pause)
    return;

  if (mouseButton == RIGHT) {
    finished = false;
    selectCopy();
    return;
  }

  if (!pasting) {
    int xCell = PApplet.parseInt(map(mouseX, 0, width, 0, numX));
    xCell = constrain(xCell, 0, numX-1);
    int yCell = PApplet.parseInt(map(mouseY, 0, height, 0, numY));
    yCell = constrain(yCell, 0, numY-1);

    if (px != xCell || py != yCell) {
      cells[xCell][yCell] = (draw)?1:0;
      nextTick[xCell][yCell] = (draw)?1:0;
    }
    px = xCell;
    py = yCell;
  }
}

public void mouseMoved() {
  int xCell = PApplet.parseInt(map(mouseX, 0, width, 0, numX));
  xCell = constrain(xCell, 0, numX-1);
  int yCell = PApplet.parseInt(map(mouseY, 0, height, 0, numY));
  yCell = constrain(yCell, 0, numY-1);

  draw = (cells[xCell][yCell] == 0)?true:false;
}

public void mouseReleased() {
  if (!pause)
    return;

  finished = true;
  if (startX != -1 && startY != -1 && endX != -1 && endY != -1) {
    selectCopy();
  }

  if (mouseButton == LEFT && !pasting) {
    if (!dragged) {
      int xCell = PApplet.parseInt(map(mouseX, 0, width, 0, numX));
      xCell = constrain(xCell, 0, numX-1);
      int yCell = PApplet.parseInt(map(mouseY, 0, height, 0, numY));
      yCell = constrain(yCell, 0, numY-1);

      cells[xCell][yCell] = (cells[xCell][yCell]==0)?1:0;
    } else {
      dragged = false;
    }
  }

  if (mouseButton == LEFT && showall && mouseLocation != -1) {
    filename = filenames[mouseLocation];
    showall = false;
    typing = false;
    cursor(ARROW);
  } else if (mouseButton == RIGHT && showall && mouseLocation != -1) {
    filename = filenames[mouseLocation];
    String homeDir = System.getProperty("user.home");
    String folder = ".gol";
    filename = filename.replace(".txt", "");
    String path = homeDir+"/"+folder+"/"+filename+".txt";

    File f = new File(path);
    if (f.exists())
      f.delete();

    filename = "filename";
    longestName = "";
    File[] tempNames = new File(homeDir+"/"+folder).listFiles();
    filenames = new String[tempNames.length];
    for (int i = 0; i < tempNames.length; i++) {
      filenames[i] = tempNames[i].getName().replace(".txt", "");
      if (filenames[i].length() > longestName.length()) 
        longestName = filenames[i];
    }
  }

  if (mouseButton == LEFT && pasting) {
    paste(mouseX, mouseY);
  }

  startX = -1;
  startY = -1;
  endX = -1;
  endY = -1;
}

public void keyPressed() {
  if (key == 27)
    key = 0;
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "GameOfLife" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
