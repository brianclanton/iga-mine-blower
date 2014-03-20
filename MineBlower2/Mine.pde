/* Mine class - by Al Biles
 Handles all stuff that happens to a Mine.
 A given mine can be reset MAX_RESET times.
 */
class Mine
{
  float xLoc = -100;          // Location of center
  float yLoc = -100;          // Initialize off screen
  int mineFrmN = 0;
  int expFrmN = 0;
  float radius = 50;
  int mineSt = 0;    // 0 active, 1 exploding, 2 disarmed, 3 dormant, 4 gone
  int inactiveTime;
  final int INACTIVE_MAX = 500;
  int fadeTime;
  final int FADE_MAX = 100;
  int nReset = MAX_RESET;     // MAX_RESET defined global in main

  Mine ()
  {
    randPlace(width/2.0, height/2.0);
    mineFrmN = int(random(0, gr.nMineFrms));
  }

  // Reset the mine so that it can reappear at a new place
  void reset()
  {
    randPlace(sub.xLoc, sub.yLoc);
    mineFrmN = int(random(0, gr.nMineFrms));
    mineSt = 0;
    expFrmN = 0;
    inactiveTime = 0;
    fadeTime = 0;
  }

  // Puts mine at random place not too close to sub or another eel
  void randPlace(float xAvoid, float yAvoid)  // Sub at (xAvoid,yAvoid)
  {
    float newX;
    float newY;
    do
    {
      newX = random (200, width-50);    // Put it at random place
      newY = random (100, height-100);
    }              // Not too close to sub or to any existing mine
    while (dist (newX, newY, xAvoid, yAvoid) < 250 ||
      mineCluster(newX, newY));
    xLoc = newX;
    yLoc = newY;
  }

  // Returns true if mine at (x,y) would be too close to another mine
  boolean mineCluster (float x, float y)
  {
    for (int i = 0; i < nMines && mines[i] != null; i++)
      if (dist (x, y, mines[i].mineX(), mines[i].mineY()) < 100)
        return true;
    return false;
  }

  // Returns true if (x,y) inside the Mine
  boolean touch(float x, float y)
  {
    if (mineSt > 0)                     // Can only touch if mine active
      return false;
    else
      return dist(x, y, xLoc, yLoc) < radius;  // Assume a round mine
  }

  boolean active()         // Some getters
  {
    return mineSt == 0;
  }

  boolean inactive()
  {
    return mineSt > 1;     // Fading away or truly inactive
  }

  float mineX()
  {
    return xLoc;
  }

  float mineY()
  {
    return yLoc;
  }

  void explode()           // Called when the mine explodes
  {
    if (mineSt == 0)       // Can only blow up if Mine still active
    {
      mineSt = 1;          // Mine is now exploding
      aud.triggerWhere(aud.bangSnd, xLoc);
    }
  }

  void disarm()            // Called when the mine has been disarmed
  {
    if (mineSt == 0)       // Can only disarm if Mine still active
    {
      mineSt = 2;          // Make Mine disarmed
      inactiveTime = INACTIVE_MAX;
      fadeTime = FADE_MAX;  // Start fading away
      aud.triggerWhere(aud.disarmSnd, xLoc);
      sc.disarmed();
    }
  }

  // Primary move method - Different moves for different states
  void move()
  {
    if (mineSt == 0)         // Mine still active
    {
      if (frameCount % gr.nMineFrms == 0 && random(0, 10) < 5)
        mineFrmN = (mineFrmN + 1) % gr.nMineFrms;
    }
    else if (mineSt == 1)    // Mine is exploding
    {
      if (expFrmN < gr.nExpFrms)
        expFrmN++;
      else
      {
        mineSt = 3;          // Explosion done, make Mine inactive
        inactiveTime = INACTIVE_MAX;
      }
    }
    else if (mineSt == 2)    // Mine is disarmed, fading away
    {
      inactiveTime--;
      fadeTime--;
      if (fadeTime <= 0)     // Done fading, make it inactive
      {
        fadeTime = 0;
        mineSt = 3;
      }
    }
    else if (mineSt == 3)    // Is inactive, waiting to be reset
    {
      if (nReset > 0)
      {
        inactiveTime--;
        if (inactiveTime <= 0) // Time to reactivate it
        {
          mineSt = 0;
          nReset--;
          reset();
        }
      }
      else
        mineSt = 4;
    }
    // else (mineSt == 4) No more resets, mine ignored
  }

  void display()
  {
    if (mineSt == 0)         // Mine still active
    {
      image(gr.mineFrm[mineFrmN], xLoc, yLoc);
    }
    else if (mineSt == 1)    // Mine is exploding
    {
      if (expFrmN < gr.nExpFrms)
      {
        image (gr.expFrm[expFrmN], xLoc, yLoc, 
        gr.expFrm[expFrmN].width * 2, gr.expFrm[expFrmN].height * 2);
      }
    }
    else if (mineSt == 2)    // Mine is fading away after being disarmed
    {
      tint(255, fadeTime);
      image(gr.mineFrm[mineFrmN], xLoc, yLoc);
      noTint();
    }
    // else mineSt == 3 or 4, can't see it
  }
}

