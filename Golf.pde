//3px = 2yds
color fillVal = color(255,5,5);
color strokeVal = color(255,5,5);
int menu = 0;
PImage menuScreen;
PImage options;
PImage end;
int opt = 0;

int swingStage = 0; //Power stage, Accuracy Stage, Nothing
int swingRange = 15; //Area swingCursor travels within
int swingRangeR;
int swingRangeY = 30;
float swingCursor; //Moves, allows player to determine Power and Accuracy to hit ball
float clubSpd; //Speed at which swingCursor moves
float Power = swingRange+150; //Power user stops slider at
float PowerMult; //Calculates power percentage based on Power slide (above)
float Accuracy = swingRange+190;

float ballPosx; //Location in x
float ballPosy; //Location in y
float ballDia = 8; //Diameter of ball
float dBx = 0; //Speed of Ball x direction
float dBy = 0; //Speed of Ball y direction
float newx; //Where the ball will be after hit in x
float newy; //Where the ball will be after hit in y
int ballGo = 0; //Used to change variables, make ball move
int strokes = 0; //Spacebar, draw swingcursor
int strokesTotal = 0;
int[] stroke = new int[10];

float currentx; //Current x position
float currenty; //Current y position
float exponent = 4; //Used in function to determine ball curve
float step = 0.01;
float pct =  0.0;

float increment = rnd(3.14/24); //Amount aim angle changes
float angle = 12 * increment; //Starting aim angle
float distPix; //x distance based on angle
float distPiy; //y distance based on angle

int club = 8; //Club in use, changes with Up & Down keys
String clubName;
int clubChange = 0; //Looks through clubs only if 0. So clubSpd is only assigned when club changed.
int maxDist; //Max distance club can hit ball

int hole = 1; //Current hole
int start = 2; //Determines whether to place ball at teebox
float lie = 1;
PImage show;
PImage ref;
PImage green;
int gr = 1; //Current green
int putt = 0; //Green view or Fairway view


void setup() {
  size(900, 700);
  smooth(32);
  menuScreen = loadImage("Menu.png");
  options = loadImage("Options.png");
  end = loadImage("End.png");
}

void draw() {
    if (opt == 1) {
      image(options, 0, 0);
    }
    else if (menu == 0) {
      image(menuScreen, 0, 0);
    }
    else if (menu == 2) {
      image(end, 0, 0);
      // Prints Scorecard
      int j = 244;
      stroke[9] = strokesTotal;
      for (int i = 0; i < 10; i++) {
        textSize(20);
        fill (63, 73, 204);
        text(stroke[i], 525, j);
        j = j + 28;
      }     
    }
    else {
    course();
    
    //Draws swingRange
    swingRangeR = swingRange + 190;
    while (swingRange <= swingRangeR) {
      if (swingRangeR == swingRange + 150 || swingRangeR == swingRange + 190) {
        stroke(255, 100, 0);
        rect(swingRangeR, swingRangeY + 2.5, 1, 5);
      }
      else if (swingRangeR == swingRange + 160 || swingRangeR == swingRange + 180) {
        stroke(255, 255, 0);
        rect(swingRangeR, swingRangeY + 1.25, 1, 7.5);
      }
      else if (swingRangeR == swingRange + 70 || swingRangeR == swingRange + 80) {
        stroke(255, 255, 0);
        rect(swingRangeR, swingRangeY, 1, 10);
      }
      else {
        stroke(0, 0, 0);
        rect(swingRangeR, swingRangeY, 1, 10);
      }
      swingRangeR = swingRangeR - 10;
    }  
    
    // Draws aim line
    if (dBx == 0 && dBy == 0) {
      if (clubChange == 0) {
        clubs();
      }
      aim();
    }
   
    
    //Draws Ball
    if (club == 1 || club == 0) {
      putting();
    }
    else {
    ball();
    }
    
    //Draws swingCursor
    stroke(strokeVal);
    fill(fillVal);
    rect(swingCursor, swingRangeY-5, 2, 20);
    
    //Moves cursor based on stage of swing
    if (swingStage == 1) {
      if (swingCursor < swingRange || swingCursor > swingRange+150) {
        clubSpd = -clubSpd;
      }
      swingCursor = swingCursor + clubSpd;
    }
    else if (swingStage == 2) {
      clubSpd = abs(clubSpd);
      swingCursor = swingCursor + clubSpd;
      if (swingCursor >= swingRange+190) {
        swingCursor = swingRange + 190;
        swingStage = 0;
        Accuracy = swingRange+191;
        ballGo = 1;
        strokes++;
        strokesTotal++;
      }
    }
    else if (swingStage == 0) {
      if (dBx == 0 && dBy == 0) {
        swingCursor = swingRange+150;
      }
      else {
        swingCursor = Accuracy;
      }
    }
    
    // Prints to Scorecard
    int j = 449;
    stroke[9] = strokesTotal;
    for (int i = 0; i < 10; i++) {
      textSize(10);
      fill (0, 0, 0);
      text(stroke[i], 122, j);
      j = j + 15;
    }
    
    textSize(30);
    fill (0, 0, 0);
    text(hole, 90, 192);
    textSize(20);
    fill(255, 0, 0);
    text(clubName, 85, 325);
    text(strokes, 110, 355);
    println("Power: " + Power + " Accuracy: " + Accuracy);
    println("Angle: " + angle);
    println(strokesTotal);
    frameRate(60);
    println(frameRate);
  }
}


void keyPressed() {
  if (menu == 0) {
    Menu();
    Options();
  }
  else {
    //Space lets player determine Power and Accuracy, only allowed when ball not moving
    SpaceBar();
    //Lets player aim, only allowed when ball not moving
    RightLeft();
    //Allows player to select club, ball cannot be moving
    UpDown();
    Options();
  }
}

// Determines when/how ball moves, draws ball
void ball() {
  fill(255, 255, 255);
  stroke(0, 0, 0);
  
  PowerMult = ((swingRange + 150 - Power) / 150) * lie;
  
  if (ballGo == 1) {
    dBx = 1;
    dBy = 1;
    newx = newx + (distPix * PowerMult) - ballPosx;
    newy = newy - (distPiy * PowerMult) - ballPosy;
    ballGo = 2;
    accuracy();
  }
  else if (ballGo == 2) {
    if (pct < 1.0) {
      pct += step;
      currentx = ballPosx + (pct * newx);
      currenty = ballPosy + (pow(pct, exponent) * newy);
    }
    else {
      dBx = 0;
      dBy = 0;
    }
    if (dBx == 0 && dBy == 0) {
      fillVal = color(255, 5, 5);
      strokeVal = color(255, 5, 5);
      ballPosx = currentx;
      ballPosy = currenty;
      ballGo = 0;
    }
    if (club == 0 || club == 1) {
      ellipse(currentx, currenty, ballDia, ballDia);
    }
    else if (pct >= .4 && pct <= .6) {
      ellipse(currentx, currenty, 2 * ballDia, 2 * ballDia);
    }      
    else if ((pct > .1 && pct <.4) || (pct > .6 && pct < .8)) {
    ellipse(currentx, currenty, 1.5 * ballDia, 1.5 * ballDia);
    }
    else {
      ellipse(currentx, currenty, ballDia, ballDia);
    }
  }
  else {
    ellipse(ballPosx, ballPosy, ballDia, ballDia);
  }
}

// Draws aim line
void aim() {
  fill(255, 255, 0);
  stroke(255, 255, 0);
  distPix = maxDist * cos(angle);
  distPiy = maxDist * sin(angle);
  
  line(ballPosx, ballPosy, ballPosx + distPix, ballPosy - distPiy);
  rect(ballPosx + distPix - 2, ballPosy - distPiy - 2, 4, 4); 
}

// Clubs, Each has different distance/speed
void clubs() {
  //Putter
  if (club == 0) {
    clubSpd = 1;
    maxDist = 75;
    clubName = "Putter(Short)";
    if (putt == 1) {
      maxDist = 150;
    }
  }
  if (club == 1) {
    clubSpd = 1.5;
    maxDist = 75;
    clubName = "Putter(Long)";
    if (putt == 1) {
      maxDist = 300;
    }
  }
  //Wedge -  100yds
  if (club == 2) {
    clubSpd = 1.5;
    maxDist = 150;
    clubName = "Wedge";
    if (putt == 1) {
      maxDist = 400;
    }
  } 
  //9 Iron -  130yds
  if (club == 3) {
    clubSpd = 1.8;
    maxDist = 195;
    clubName = "9 Iron";
  }
  //7 Iron -  150yds
  if (club == 4) {
    clubSpd = 2;
    maxDist = 225;
    clubName = "7 Iron";
  } 
  //5 Iron -  170yds
  if (club == 5) {
    clubSpd = 2.5;
    maxDist = 255;
    clubName = "5 Iron";
  }
  //5 Wood - 200yds
  if (club == 6) {
    clubSpd = 3;
    maxDist = 300;
    clubName = "5 Wood";
  }  
  //3 Wood - 220yds
  if (club == 7) {
    clubSpd = 4;
    maxDist = 330;
    clubName = "3 Wood";
  }
  //Driver - 250yds
  if (club == 8) {
    clubSpd = 6;
    maxDist = 375;
    clubName = "Driver";
  }
  clubChange = 1;
}

// Draws course, determines what to do at ball position
void course() {
  // Finds teebox and places ball there at hole start
  if (start == 2) {
    loadCourse();
    loadGreen();
    int x, y;
    for (x = 225; x <= 900; x++) {
      for (y = 0; y <= 700; y++) {
        if (ref.get(x, y) == color(255,255,255)) {
          ballPosx = x;
          ballPosy = y;
          currentx = x;
          currenty = y;
          lie = 1;
        }
      }
    }
    start = 0;
  }
  
  int intx = int(currentx);
  int inty = int(currenty);
  if (putt == 1) {
    image(green, 0, 0);
    ref = green;
  }
  else {
  image(show, 0, 0);
  }
  
  if (dBy == 0 && dBx == 0) {
    // Changes to next hole when ball in cup
    if (ref.get(intx, inty) == color(255,127,39)) { /* 2, MODIFIED */
      putt = 0;
      hole++;
      gr++;
      start = 2;
      club = 8;
    }
    // Green
    if (ref.get(intx, inty) == color(237,28,36)) {
      lie = 1;
      if (putt == 0) {
        relocate();
        club = 0;
      }
      putt = 1;
    }
    // Fairway
    if (ref.get(intx, inty) == color(34,177,76)) {
      lie = 1;
    }
    // Rough
    if (ref.get(intx, inty) == color(0,85,0)) {
      lie = .9;
      if (club >= 4) {
        lie = .7;
      }
    }
    // Sand
    if (ref.get(intx, inty) == color(255,242,0)) {
      lie = .5;
      if (club == 2) {
        lie = .9;
      }
    }  
  }

  if ((ballGo == 2) && (pct >= .9 && pct < .99)) {
    // Gives penalty for going in water, resets ball to last pos
    if (ref.get(intx, inty) == color(63,72,204)) {
      strokes++;
      strokesTotal++;
      currentx = ballPosx;
      currenty = ballPosy;
      pct = 1.1;
    }
    // Gives penalty for going OB, resets ball to last pos
    if (ref.get(intx, inty) == color(0,0,0)) {
      strokes++;
      strokesTotal++;
      currentx = ballPosx;
      currenty = ballPosy;
      pct = 1.1;
    }     
  }
  // Trees
  if ((ballGo == 2) && ((pct > .1 && pct < .3) || pct > .7)) {
    if (ref.get(intx, inty) == color(163,73,164)) {
      pct = 1.1;
    }
  }
  
}
   
//Rounds number to get consistent values
float rnd(float number) {
  return (float)(round((number*pow(10, 2))))/pow(10, 2); /* 1, MODIFIED */
}

//Options
void Options() {
  if (dBx == 0 && dBy == 0) {
    if (key == '0') {
      if (opt == 0) {
        opt = 1;
      }
      else {
        opt = 0;
      }
    }
  }
}
    
//Menu commands
void Menu() {
  if (key == '1') {
    menu = 1;
  }
}

//What to do if Space is pressed
void SpaceBar() {
  if (key == ' ') {
    if (menu == 2) {
      menu = 0;
      hole = 1;
      gr = 1;
      start = 2;
      strokesTotal = 0;
      for (int i = 0; i < 10; i++) {
        stroke[i] = 0;
      }
    }
    else if (dBx == 0 && dBy == 0) {
      if (swingStage == 0) {
        swingCursor = swingRange+150;
        fillVal = color(255, 5, 5);
        strokeVal = color(255, 5, 5);
        newx = ballPosx;
        newy = ballPosy;
        swingStage = 1;
      }
      else if (swingStage == 1) {
        Power = swingCursor;
        fillVal = color(5, 5, 255);
        strokeVal = color(5, 5, 255);
        if (club == 0 || club == 1) {
          Accuracy = 170;
          swingStage = 0;
          ballGo = 1;
          strokes++;
          strokesTotal++;
        }
        else {
          swingStage = 2;
        }
      }
      else if (swingStage == 2) {
        Accuracy = swingCursor;
        swingStage = 0;
        ballGo = 1;
        strokes++;
        strokesTotal++;
      }
    }
  }
}

//What happens if Right or Left key pressed
void RightLeft() {
  //Only allowed if ball not moving and have not chose Power yet
  if (dBx == 0 && dBy == 0 && swingStage != 2) {
    //What to do at 2pi/0.
    float zero = 0.0;
    for (int i = 0; i < 47; i++) {
      zero = zero + increment;
    }
    //Right & Left keys allow player to aim
    if (keyCode == RIGHT) {
      if (angle == 0) {
        angle = zero;
      }
      else if (swingStage == 1) {
        swingStage = 0;
      }
      else {
        angle = angle - (increment); 
      }
    }
    if (keyCode == LEFT) {
      if (angle == zero) {
        angle = 0.0;
      }
      else if (swingStage == 1) {
        swingStage = 0;
      }
      else {
        angle = angle + (increment); 
      }
    }
  }

}

//What happens if Up or Down key pressed
void UpDown() {
  int clubNum;
  int clubLow = 2;
  //Only can have driver on tee
  if (ref.get((int)currentx, (int)currenty) == color(255,255,255)) {
    clubNum = 8;
  }
  else {
    clubNum = 7;
    if (club == 8) {
      club = 7;
    }
  }
  //Only allowed if ball not moving and have not chose Power yet
  if (dBx == 0 && dBy == 0 && swingStage != 2) {
    if (putt == 1) {
      clubNum = 2;
      clubLow = 0;
    }
    if (keyCode == UP) {
      if (swingStage == 1) {
        swingStage = 0;
      }
      else if (club < clubNum) {
        club++;
      }
    }
    if (keyCode == DOWN) {
      if (swingStage == 1) {
        swingStage = 0;
      }
      else if (club > clubLow) {
        club--;
      }
    }
    clubChange = 0;
  }
}

// Determines how much ball drifts left/right due to inaccuracy
void accuracy() {
  float a = 0, b = 0;
  int i;
  for (i = 0; i < 24; i++) {
    a = a + increment;
  }
  for (i = 0; i < 36; i++) {
    b = b + increment;
  }
  pct = 0.0;
  if (Accuracy >= swingRange + 190 || Accuracy <= swingRange + 150) {
    dBx = 0;
    dBy = 0;
    pct = 2.0;
    newx = ballPosx;
    newy = ballPosy;
  }
  else if (club == 0 || club == 1) {
    exponent = 1;
  }
  else if (angle == 0.0 || angle == a) {
    if (Accuracy > swingRange + 150 && Accuracy < swingRange + 160) {
      exponent = 2;
      newy = newy + distPix * .3;
    }
    else if (Accuracy > swingRange + 180 && Accuracy < swingRange + 190) {
      exponent = 2;
      newy = newy - distPix * .3;
    }
    else if (Accuracy >= swingRange + 160 && Accuracy < swingRange + 169) {
      exponent = 2;
      newy = newy + distPix * .15;
    }
    else if (Accuracy > swingRange + 171 && Accuracy <= swingRange + 180) {
      exponent = 2;
      newy = newy - distPix * .15;
    }
    else {
      exponent = 1;
    }
  }
  else if (angle == 12 * increment || angle == b) {
    if (Accuracy > swingRange + 150 && Accuracy < swingRange + 160) {
      exponent = .5;
      newx = newx + distPiy * .3;
    }
    else if (Accuracy > swingRange + 180 && Accuracy < swingRange + 190) {
      exponent = .5;
      newx = newx - distPiy * .3;
    }
    else if (Accuracy >= swingRange + 160 && Accuracy < swingRange + 169) {
      exponent = .5;
      newx = newx + distPiy * .15;
    }
    else if (Accuracy > swingRange + 171 && Accuracy <= swingRange + 180) {
      exponent = .5;
      newx = newx - distPiy * .15;
    }
    else {
      exponent = 1;
    }
  }
  else if ((angle > 0.0 && angle <  12 * increment) || (angle > a && angle <  b)) {
    if (Accuracy > swingRange + 150 && Accuracy < swingRange + 160) {
      exponent = .5;
      newy = newy + distPiy * .3;
    }
    else if (Accuracy > swingRange + 180 && Accuracy < swingRange + 190) {
      exponent = 2;
      newx = newx - distPix * .3;
    }
    else if (Accuracy >= swingRange + 160 && Accuracy < swingRange + 169) {
      exponent = .5;
      newy = newy + distPiy * .15;
    }
    else if (Accuracy > swingRange + 171 && Accuracy <= swingRange + 180) {
      exponent = .5;
      newx = newx - distPix * .15;
    }
    else {
      exponent = 1;
    }
  }
  else if ((angle > 12 * increment && angle <  a) || (angle > b && angle < 6.28)) {
    if (Accuracy > swingRange + 150 && Accuracy < swingRange + 160) {
      exponent = 2;
      newx = newx - distPix * .3;
    }
    else if (Accuracy > swingRange + 180 && Accuracy < swingRange + 190) {
      exponent = .5;
      newy = newy + distPiy * .3;
    }
    else if (Accuracy >= swingRange + 160 && Accuracy < swingRange + 169) {
      exponent = .5;
      newx = newx - distPix * .15;
    }
    else if (Accuracy > swingRange + 171 && Accuracy <= swingRange + 180) {
      exponent = .5;
      newy = newy + distPiy * .15;
    }
    else {
      exponent = 1;
    }
  }
  else {
    exponent = 1;
  }
}

//Green is 4x larger
void relocate() {
  int x, y;
  int x1 = (int)ballPosx;
  int y1 = (int)ballPosy;
  for (x = (int)ballPosx; x <= 900; x++) {
    if (ref.get(x, y1) == color(185,122,87)) {
      x = (x - (int)ballPosx) * 4;
      ballPosx = 900 - x;
      currentx = 900 - x;
      break;
    }
  }
  for (y = (int)ballPosy; y <= 700; y++) {
    if (ref.get(x1, y) == color(255,174,201)) {
      y = (y - (int)ballPosy) * 4;
      ballPosy = 700 - y;
      currenty = 700 - y;
      break;
    }
  }
}

void loadGreen() {
  if (gr == 1) {
    green = loadImage("beg1g.png");
  }
  else if (gr == 2) {
    green = loadImage("beg2g.png");
  }
  else if (gr == 3) {
    green = loadImage("beg3g.png");
  }
  else if (gr == 4) {
    green = loadImage("beg4g.png");
  }
  else if (gr == 5) {
    green = loadImage("beg5g.png");
  }
  else if (gr == 6) {
    green = loadImage("beg6g.png");
  }
  else if (gr == 7) {
    green = loadImage("beg7g.png");
  }
  else if (gr == 8) {
    green = loadImage("beg8g.png");
  }
  else if (gr == 9) {
    green = loadImage("beg9g.png");
  }
  else if (gr == 10) {
    menu = 2;
  }
}

void loadCourse() {
  if (hole == 1) {
    ref = loadImage("beg1r.png");
    show = loadImage("beg1.png");
  }
  else if (hole == 2) {
    ref = loadImage("beg2r.png");
    show = loadImage("beg2.png");
    stroke[0] = strokes;
  }
  else if (hole == 3) {
    ref = loadImage("beg3r.png");
    show = loadImage("beg3.png");
    stroke[1] = strokes;
  }
  else if (hole == 4) {
    ref = loadImage("beg4r.png");
    show = loadImage("beg4.png");
    stroke[2] = strokes;
  }
  else if (hole == 5) {
    ref = loadImage("beg5r.png");
    show = loadImage("beg5.png");
    stroke[3] = strokes;
  }
  else if (hole == 6) {
    ref = loadImage("beg6r.png");
    show = loadImage("beg6.png");
    stroke[4] = strokes;
  }
  else if (hole == 7) {
    ref = loadImage("beg7r.png");
    show = loadImage("beg7.png");
    stroke[5] = strokes;
  }
  else if (hole == 8) {
    ref = loadImage("beg8r.png");
    show = loadImage("beg8.png");
    stroke[6] = strokes;
  }
  else if (hole == 9) {
    ref = loadImage("beg9r.png");
    show = loadImage("beg9.png");
    stroke[7] = strokes;
  }
  else if (hole == 10) {
    stroke[8] = strokes;
    menu = 2;
  }
  strokes = 0;
}


void putting() {
  fill(255, 255, 255);
  stroke(0, 0, 0);
  
  PowerMult = ((swingRange + 150 - Power) / 150) * lie;
  
  if (ballGo == 1) {
    dBx = 1;
    dBy = 1;
    newx = newx + (distPix * PowerMult) - ballPosx;
    newy = newy - (distPiy * PowerMult) - ballPosy;
    accuracy();
    ballGo = 2;
  }
  else if (ballGo == 2) {
    if (pct < 1.0) {
      pct += step;
      if (ref.get((int)currentx, (int)currenty) == color(136,0,21)) {
        newy = newy + 1;
        currentx = ballPosx + (pct * newx);
        currenty = ballPosy + (pow(pct, exponent) * newy);
      }
      else if (ref.get((int)currentx, (int)currenty) == color(255,66,95)) {
        newy = newy - 1;
        currentx = ballPosx + (pct * newx);
        currenty = ballPosy + (pow(pct, exponent) * newy);
      }
      else if (ref.get((int)currentx, (int)currenty) == color(189,0,29)) {
        newx = newx + 1;
        currentx = ballPosx + (pct * newx);
        currenty = ballPosy + (pow(pct, exponent) * newy);
      }
      else if (ref.get((int)currentx, (int)currenty) == color(255,155,170)) {
        newx = newx - 1;
        currentx = ballPosx + (pct * newx);
        currenty = ballPosy + (pow(pct, exponent) * newy);
      }
      else {
        currentx = ballPosx + (pct * newx);
        currenty = ballPosy + (pow(pct, 1) * newy);
      }
    }
    else {
      dBx = 0;
      dBy = 0;
    }
    if (dBx == 0 && dBy == 0) {
      fillVal = color(255, 5, 5);
      strokeVal = color(255, 5, 5);
      ballPosx = currentx;
      ballPosy = currenty;
      ballGo = 0;
    }
    ellipse(currentx, currenty, ballDia, ballDia);
  }
  else {
    ellipse(ballPosx, ballPosy, ballDia, ballDia);
  }
}