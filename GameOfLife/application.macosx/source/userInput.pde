
char[] badKeys = {
  33, 34, 35, 36, 37, 38, 40, 41, 42, 43, 
  47, 58, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
  89, 90, 92, 94, 95, 96, 123, 124, 125
};

void keyReleased() { 
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
void mouseDragged() {
  dragged = true;
  if (!pause)
    return;

  if (mouseButton == RIGHT) {
    finished = false;
    selectCopy();
    return;
  }

  if (!pasting) {
    int xCell = int(map(mouseX, 0, width, 0, numX));
    xCell = constrain(xCell, 0, numX-1);
    int yCell = int(map(mouseY, 0, height, 0, numY));
    yCell = constrain(yCell, 0, numY-1);

    if (px != xCell || py != yCell) {
      cells[xCell][yCell] = (draw)?1:0;
      nextTick[xCell][yCell] = (draw)?1:0;
    }
    px = xCell;
    py = yCell;
  }
}

void mouseMoved() {
  int xCell = int(map(mouseX, 0, width, 0, numX));
  xCell = constrain(xCell, 0, numX-1);
  int yCell = int(map(mouseY, 0, height, 0, numY));
  yCell = constrain(yCell, 0, numY-1);

  draw = (cells[xCell][yCell] == 0)?true:false;
}

void mouseReleased() {
  if (!pause)
    return;

  finished = true;
  if (startX != -1 && startY != -1 && endX != -1 && endY != -1) {
    selectCopy();
  }

  if (mouseButton == LEFT && !pasting) {
    if (!dragged) {
      int xCell = int(map(mouseX, 0, width, 0, numX));
      xCell = constrain(xCell, 0, numX-1);
      int yCell = int(map(mouseY, 0, height, 0, numY));
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

void keyPressed() {
  if (key == 27)
    key = 0;
}

