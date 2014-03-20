/* Sub class - by Al Biles
 Handles all sub behaviors and interactions with other objects
 */
class Sub
{
  float xLoc;              // Location of center of sub
  float yLoc;
  float dx = 0;            // Deviation per frame
  float dy = 0;
  float buoyancy = -0.05;  // Sub wants to float
  float drag = 0.025;      // Water exerts drag
  float xBoost = 0.15;     // Per frame increment in deviations
  float yBoost = 0.15;
  float maxX = 4.0;        // Max deviation per frame
  float maxY = 4.0;
  float subWidth = 269;    // Total sub dimensions
  float subHeight = 167;
  float hullLeft = -135;   // Hull left/right edge from center
  float hullRight = 134;
  float hullTop = -19;     // Hull top/bottom from center
  float hullBot = 84;
  float conLeft = -12;     // Conning tower left/right from center
  float conRight = 66;
  float conTop = -83;      // Conning tower top/bottom from center
  float conBot = -18;
  int subState = 0;        // 0 Normal, 1 Zapping, 2 Sinking, 3 Sunk
  int electroN = 0;        // Frame counter for zapping sequence
  int curFrm = 0;          // Current fram in animation
  float bForce = 8000.0;   // Blast Force of an exploding mine
  Arm arm;                 // Grappling arm to grab mines
  float careful = 1.5;     // Motion threshold for disarming mine
  //boolean gameOver;      // true when game over, global defined in main

  Sub()
  {
    xLoc = width/2.0;           // Start sub in center of window
    yLoc = height/2.0;
    arm = new Arm(xLoc, yLoc);  // Create arm relative to sub center
  }

  boolean eelTouch(Eel e1)      // true if e1 overlaps sub
  {
    if (subState > 0 || e1.grounded() || e1.zapping())  // Don't overdo it
      return false;
    else
    {
      return e1.touch(xLoc+hullLeft, yLoc+hullTop) ||
        e1.touch(xLoc+hullLeft/2, yLoc+hullTop) ||
        e1.touch(xLoc+hullRight, yLoc+hullTop) ||
        e1.touch(xLoc+hullLeft, yLoc+hullBot) ||
        e1.touch(xLoc+hullLeft/2, yLoc+hullBot) ||
        e1.touch(xLoc, yLoc+hullBot) ||
        e1.touch(xLoc+hullRight/2, yLoc+hullBot) ||
        e1.touch(xLoc+hullRight, yLoc+hullBot) ||
        e1.touch(xLoc+conLeft, yLoc+conTop) ||
        e1.touch(xLoc+conLeft, yLoc+conBot) ||
        e1.touch(xLoc+conRight, yLoc+conTop) ||
        e1.touch(xLoc+conRight, yLoc+conBot);
    }
  }

  // Called when zapped by an eel
  void zap()
  {
    if (subState < 2)  // Only if we're not sinking or sunk
    {
      subState = 1;    // Transition to zapping state
      electroN = 20;   // set up frame timer for zapping sequence
      sc.zapped();
    }
  }

  boolean mineTouch(Mine m1)  // true if m1 overlaps sub
  {
    if (! m1.active())  // Not if mine is inactive
        return false;
    else
    {
      return m1.touch(xLoc+hullLeft, yLoc+hullTop) ||
        m1.touch(xLoc+hullLeft, yLoc) ||
        m1.touch(xLoc+hullLeft, yLoc+hullBot) ||
        m1.touch(xLoc+hullLeft/2, yLoc+hullTop) ||
        m1.touch(xLoc+hullLeft/2, yLoc+hullBot) ||
        m1.touch(xLoc+hullRight, yLoc+hullTop) ||
        m1.touch(xLoc+hullRight, yLoc) ||
        m1.touch(xLoc+hullRight, yLoc+hullBot) ||
        m1.touch(xLoc+hullRight/2, yLoc+hullBot) ||
        m1.touch(xLoc, yLoc+hullBot) ||
        m1.touch(xLoc+conLeft, yLoc+conTop) ||
        m1.touch(xLoc+conLeft, yLoc+conBot) ||
        m1.touch(xLoc+conRight, yLoc+conTop) ||
        m1.touch(xLoc+conRight, yLoc+conBot);
    }
  }

  boolean careful()  // Returns true if current speed slow enough
  {
    return dist (0, 0, dx, dy) < careful;
  }

  // Called when a mine blows up, sub is blasted away from explosion
  // with "force" bForce, mitigated by Distance ^ 1.5 power instead of
  // distance squared (real physics) to make the effect more playable.
  // bDSq is distance ^ 2.5 power to include converting the distance
  // from blast in each direction to get a unit vector component
  // before doing the actual blast effect.
  void blast(float x, float y)
  {
    if (subState < 3)  // Only if we're not sunk
    {
      float bDist = dist(xLoc, yLoc, x, y);      // Distance from blast
      float bDSq = bDist * bDist * sqrt(bDist);  // Distance ^ 2.5 power
      dx = bForce * (xLoc - x) / bDSq;           // Add x vector to dx
      dx = constrain(dx, -maxX, maxX);
      dy = bForce * (yLoc - y) / bDSq;           // Add y vector to dy
      dy = constrain(dy, -maxY, maxY);
      sc.blastDamage(bDist);                     // Figure damage to sub
    }
  }

  // Called when sub health goes negative (sinking)
  void sinking()
  {
    if (subState < 2)
    {
      subState = 2;
      electroN = 0;
      buoyancy = abs(buoyancy);  // Sub wants to sink
      arm.sinking(xLoc, yLoc, dx, dy);
      aud.safePlay(aud.sinkingSnd);
      gameState = 2;
    }
  }

  boolean sunk()
  {
    return subState > 2;
  }

  void fireTorp(Torpedo t1)
  {
    t1.fire(xLoc, yLoc);
  }

  // Primary move method depends on sub state
  void move()
  {
    if (subState == 0)       // Normal running
      normalMove();
    else if (subState == 1)  // Sub being zapped
      zapMove();
    else if (subState == 2)  // Sub sinking
      sinkingMove();
    else
    {
      sc.youSank();
      gameState = 3;         // subState 3 - sub sunk, game over
    }
  }

  void zapMove()
  {
    if (electroN > 0)
      electroN--;            // Still zapping
    else
      subState = 0;          // Done zapping, go back to Normal state

    baseMove();
    arm.move(xLoc, yLoc);    // Move arm with the sub
  }

  void sinkingMove()
  {
    baseMove();
    arm.sinkingMove();

    // Once sub and arm sink well below bottom window border, game over
    if (yLoc > height + 200 && arm.yLoc > height + 200)
      subState = 3;          // Sunk => Game over
  }

  void normalMove() 
  {
    if (downPressed)         // Handle DOWN arrow
    {
      dy = dy + yBoost;      // Boost down to overcome buoyancy
      aud.safePlay(aud.diveSnd, xLoc);
    }
    if (leftPressed)         // Handle LEFT arrow
    {
      if (! rightPressed)    // Can only go one way
      {
        dx = dx - xBoost;    // \/ Animate propeller
        curFrm = (curFrm == 0 ? gr.nSubFrms-1 : ((curFrm - 1) % gr.nSubFrms));
        aud.safePlay(aud.reverseSnd, xLoc);
      }
    }
    else if (rightPressed)   // Handle RIGHT arrow
    {
      dx = dx + xBoost;
      curFrm = (curFrm + 1) % gr.nSubFrms;  // Animate propeller
      aud.safePlay(aud.forwardSnd, xLoc);
    }

    baseMove();
    arm.move(xLoc, yLoc);    // Move arm with the sub
  }

  // Does sub base move with no (or after) user control
  void baseMove()
  {
    dy += buoyancy;                       // Always bouyant
    dy = constrain (dy, -maxY, maxY);     // Not too fast
    yLoc = yLoc + dy;

    dx = dx + (dx > 0 ? -drag : (dx < 0 ? drag : 0)); // Always a drag
    dx = constrain (dx, -maxX, maxX);
    xLoc = xLoc + dx;
  }

  void display()
  {
    if (subState == 0)                       // Normal state
    {
      image (gr.subFrm[curFrm], xLoc, yLoc); // Normal display
      arm.display(0);                        // Display arm
      //point (arm.xGrab(), arm.yGrab());    // Grab point for disarming

      // Give audio clues to location if sub is too far off the window
      if (xLoc < -200)
        aud.tooFarLeft();
      else if (xLoc > width+200)
        aud.tooFarRight();
      if (yLoc < -200)
        aud.tooFarUp();
      else if (yLoc > height+200)
        aud.tooFarDown();
    }
    else if (subState == 1)               // Sub Being zapped
    {
      if (electroN % 2 == 0)              // Make it flash by alternating
      {
        image (gr.zapSubFrm[curFrm], xLoc, yLoc); // Zap display
        arm.display(electroN);            // Display arm
        //point (arm.xGrab(), arm.yGrab()); // Grab point for disarming
      }
      else
      {
        image (gr.subFrm[curFrm], xLoc, yLoc); // Normal display
        arm.display(electroN);                 // Display arm
        //point (arm.xGrab(), arm.yGrab());    // Grab point for disarming
      }
    }
    else if (subState == 2)                 // Sub sinking
    {
      if (arm.yLoc > height+200 && sub.yLoc > height+200)
        subState = 3;                       // Sub is sunk
      else
      {
        image (gr.sinkImage, xLoc, yLoc);   // Sunk image is grayscale
        arm.display(0);                     // Display arm
        //point (arm.xGrab(), arm.yGrab());   // Grab point for disarming
      }
    }
    // else subState == 3, sunk state, show nothing
  }
}

