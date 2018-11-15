/*
 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
 2. Any live cell with two or three live neighbours lives on to the next generation.
 3. Any live cell with more than three live neighbours dies, as if by overcrowding.
 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
 */

import java.io.File;
import java.util.Arrays;

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

void setup() {
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
void draw() {

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

void setCells() {
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

void displayMain() {
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

void displayInput() {
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

void displayCells() {
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

void nextTick() {
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

int numNeighbors(int x, int y) {
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

