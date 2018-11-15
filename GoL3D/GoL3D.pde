// for recording purposes //<>// //<>//
import nervoussystem.obj.*;
boolean record = false;

//needed for iterations
int gridSize = 80;
int layers = 50;
int spacing = 10;
// x, y, z
boolean[][][] iterations = new boolean[gridSize][gridSize][layers];

float thetaX, thetaY, thetaZ;
float rspeed = 1.5;
int growthRate = 6; //higher = slower. lower = faster. growthSpeed = number of frames skipped before next layer is added.
//this is the averaged center of the drawing. Will be the z-axis for rotations.
int[] z = {0, 0};

void setup() {
  size(800, 800, P3D);
  frameRate(60);
  background(0);

  thetaX = 0;
  thetaY = 0;
  thetaZ = 0;
}

int skipper = 0;
void draw() {
  background(0);
  if (start) {
    pushMatrix();
    //rotations
    if (left)
      thetaZ -= radians(rspeed);
    if (right)
      thetaZ += radians(rspeed);
    if (up)
      thetaX -= radians(rspeed);
    if (down)
      thetaX += radians(rspeed);

    // I need to find the middle of the drawing part and then translate to that location.
    int xoffset = int(iterations.length/2-z[0]);
    int yoffset = int(iterations[0].length/2-z[1]);
    translate((z[0]+xoffset)*spacing, (z[1]+yoffset)*spacing, 0);
    rotateX(thetaX);
    rotateY(thetaY);
    rotateZ(thetaZ);

    for (int i = 0; i < iterations.length; i++) {
      for (int j = 0; j < iterations[0].length; j++) {
        for (int k = 0; k < iterations[0][0].length; k++) {
          if (iterations[i][j][k]) {
            pushMatrix();
            //something is wrong here and I need to fix it.
            int newI = int(map(i, 0, iterations.length, -iterations.length/2, iterations.length/2-1));
            int newJ = int(map(j, 0, iterations[0].length, -iterations[0].length/2, iterations[0].length/2-1));
            //translate(i*spacing+spacing/2, j*spacing+spacing/2, k*spacing); //first attempt.
            //translate(newI*spacing+spacing/2, newJ*spacing+spacing/2, k*spacing); //second attempt.
            translate((newI+xoffset)*spacing+spacing/2, (newJ+yoffset)*spacing+spacing/2, k*spacing-(layers/2)*spacing); //final attempt. success.
            stroke(100);
            fill(#FCB80A);
            box(spacing);
            popMatrix();
          }
        }
      }
    }

    popMatrix();

    //when 'm' is pressed and the iterations have finished, it will save the .obj file
    if (record) {
      beginRecord("nervoussystem.obj.OBJExport", 
        "GoL3D_"+year()+"-"+month()+"-"+day()+"_"+hour()+minute()+second()+".obj");
      background(0);
      //recreate the object outside of translations.
      for (int i = 0; i < iterations.length; i++) {
        for (int j = 0; j < iterations[0].length; j++) {
          for (int k = 0; k < iterations[0][0].length; k++) {
            if (iterations[i][j][k]) {
              pushMatrix();
              translate(i*spacing+spacing/2, j*spacing+spacing/2, k*spacing+spacing*2);
              stroke(100);
              fill(#FCB80A);
              //NOTE: I add 3 to the spacing to create a sure bond between each cube for printing.
              box(spacing+3);
              popMatrix();
            }
          }
        }
      }

      endRecord();
      background(0);
      record = false;
    }

    //iteratation. skipper works with the growthRate to limit how fast the iterations occur
    skipper++;
    if (counter < layers-1 && skipper%growthRate == 0) {
      skipper = 0;
      calculateNextLayer();
    }
  } else {
    //here is where you need to draw the base level. 
    //This will be updated according to user input
    background(100);
    for (int i = 0; i < iterations.length; i++) {
      for (int j = 0; j < iterations[0].length; j++) {
        noStroke();
        fill(iterations[i][j][0]?color(#FCB80A):color(0));
        rect(i*spacing, j*spacing, spacing-1, spacing-1);
      }
    }

    if (pasting) {
      pushMatrix();
      translate(mouseX, mouseY);
      showPaste();
      popMatrix();
    }

    if (startX != -1 && startY != -1) {
      stroke(255);
      fill(230, 75);
      pushMatrix();
      rectMode(CORNER);
      translate(startX*spacing, startY*spacing);
      rect(0, 0, (endX-startX)*spacing, (endY-startY)*spacing);
      popMatrix();
    }
  }
}