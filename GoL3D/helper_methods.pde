void clearCells() {
  for (int i = 0; i < iterations.length; i++) {
    for (int j = 0; j < iterations[0].length; j++) {
      for (int k = 1; k < iterations[0][0].length; k++) {
        iterations[i][j][k] = false;
      }
    }
  }
}

int counter = 0;
void calculateNextLayer() {
  for (int i = 0; i < iterations.length; i++) {
    for (int j = 0; j < iterations[0].length; j++) {
      int n = numNeighbors(i, j, counter);
      if (iterations[i][j][counter] == true) {
        if (n < 2) 
          iterations[i][j][counter+1] = false;
        else if (n == 2|| n == 3)
          iterations[i][j][counter+1] = true;
        else
          iterations[i][j][counter+1] = false;
      } else {
        if (n == 3)
          iterations[i][j][counter+1] = true;
      }
    }
  }
  counter++;
}

int numNeighbors(int x, int y, int z) {
  int toReturn = 0;

  for (int i = x-1; i <= x+1; i++) {
    for (int j = y-1; j<=y+1; j++) {
      if (i==x && j==y)
        continue;
      else if (i < 0 || i >= iterations.length)
        continue;
      else if (j < 0 || j >= iterations[0].length)
        continue;
      else if (iterations[i][j][z] == true)
        toReturn++;
      else 
      continue;
    }
  }

  return toReturn;
}

int[] findCenter(int zLayer) {
  // this will return a float[] that contains x and y coordiantes
  int[] center = new int[2];

  //find the averaged center of the drawing.
  //two for loops to average the x and y booleans on the bottom layer.
  int xtotal = 0;
  int ytotal = 0;
  int numtotal = 0;
  for (int i = 0; i < iterations.length; i++) {
    for (int j = 0; j < iterations[0].length; j++) {
      if (iterations[i][j][zLayer]) {
        xtotal += i;
        ytotal += j;
        numtotal++;
      }
    }
  }

  center[0] = int((xtotal/numtotal));
  center[1] = int((ytotal/numtotal));

  return center;
}