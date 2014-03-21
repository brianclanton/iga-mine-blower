/* Eel class - by Al Biles
 Handles Eel behaviors.
 Uses State machine to control animations.
 */
class Eel
{
  float xLoc;         // Center location
  float yLoc;
  float xDevL = -28;  // Left edge deviation of bounding box
  float xDevR = 38;   // Right edge deviation of bounding box
  float yDevU = -81;  // Up edge deviation of bounding box
  float yDevD = 63;   // Down edge deviation of bounding box
  
  int [] [] transTab = {  // Transition table
    {                     // eelSt 0: normal animation
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0, 14, 15, 16, 17, 18, 19, 20, 0, 0
    }
    , {                   // eelSt 1: zapping animation
      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 15, 16, 17, 18, 19, 20, 0, 0
    }
    , {                   // eelSt 2: grounded animation
      13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 15, 16, 17, 18, 19, 20, 21, 21
    }
  };
  int zapFrm = 13;        // Frame offset where zap animation starts
  int groundFrm = gr.nEelFrms - 1;  // Extra frame used when eel is grounded
  int curFrm = 0;
  int eelSt = 0;          // 0 => normal, 1 => zapping, 2 => grounded
  int sleepFrms = 600;    // Eel stays grounded this many draw() frames
  int wakeFrm = 0;
  int groundCtr = 0;

  Eel ()
  {
    randPlace();
    curFrm = int (random(0, zapFrm));  // Random normal frame
  }

  // Puts eel at random place not too close to sub or another eel
  void randPlace()
  {
    float newX;
    float newY;
    do
    {
      newX = random (200, width-50);    // Put it at random place
      newY = random (100, height-100);
    }  // Not too close to sub or to any existing eel
    while (dist (newX, newY, width/2.0, height/2.0) < 250 ||
      eelCluster(newX, newY));
    xLoc = newX;
    yLoc = newY;
  }

  // Returns true if eel at (x,y) would be too close to another eel
  boolean eelCluster (float x, float y)
  {
    for (int i = 0; i < nEels && eels[i] != null; i++)
      if (dist (x, y, eels[i].xLoc, eels[i].yLoc) < 160)
        return true;
    return false;
  }

  void move()              // Normal move for each draw() frame
  {
    curFrm = transTab[eelSt][curFrm];         // Look up next animation frame
    if (eelSt == 1 && curFrm == groundFrm-1)  // Do zap cycle only once
      eelSt = 0;                              // then return to normal animation
    else if (eelSt == 2 && frameCount >= wakeFrm) // No longer grounded
      eelSt = 0;
  }

  void zap()
  {
    if (eelSt == 0)        // Can only zap if in normal state
    {
      eelSt = 1;
      aud.triggerWhere(random(2) > 1 ? aud.zapSnd1 : aud.zapSnd2, xLoc);
    }
  }

  void ground()            // Start grounded sequence (eel inactive)
  {
    eelSt = 2;
    groundCtr = 32;
    wakeFrm = frameCount + sleepFrms;
    aud.triggerWhere(aud.groundSnd, xLoc);
    sc.grounded();
  }

  boolean grounded()
  {
    return eelSt == 2;
  }

  boolean zapping()
  {
    return eelSt == 1;
  }

  boolean touch (float x, float y)  // true if (x,y) inside eel
  {
    if (eelSt != 0)       // if grounded or zapping, can't touch
      return false;
    else
      return x > xLoc+xDevL && x < xLoc+xDevR &&
        y > yLoc+yDevU && y < yLoc+yDevD;
  }

  void display()
  {
    image (gr.eelFrms[curFrm], xLoc, yLoc);  // Always display eel
    if (eelSt == 2)           // If grounded...
    {
      if (groundCtr > 0)      // ...see if ground symbol still on
      {
        if (groundCtr % 2 == 0)
          flashGround();      // Flashes green ground symbol over eel
        groundCtr--;
      }
    }
  }

  void flashGround()          // Draws a green ground symbol
  {
    float xDev = 40;
    float yDev = 80;
    strokeWeight (10);
    stroke (75, 255, 150);
    line(xLoc, yLoc-77, xLoc, yLoc);
    line(xLoc-xDev, yLoc, xLoc+xDev, yLoc);
    line(xLoc-xDev*0.6, yLoc+yDev*0.4, xLoc+xDev*0.6, yLoc+yDev*0.4);
    line(xLoc-xDev*0.3, yLoc+yDev*0.8, xLoc+xDev*0.3, yLoc+yDev*0.8);
  }
}

