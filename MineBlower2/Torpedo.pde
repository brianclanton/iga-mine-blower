/* Torpedo class - by Al Biles
 Handles Torpedo stuff
 */
class Torpedo
{
  float xLoc;        // Location of torpedo center
  float yLoc;
  float tx1 = 50;    // 3 points for detonator triangle at front
  float ty1 = -7;
  float tx2 = 50;
  float ty2 = 5;
  float tx3 = 60;    // 3rd point is tip of detonator (nose cone)
  float ty3 = -1;
  int tState = 0;    // 0 prelaunch, 1 launched, 2 spent, 3 all gone
  float buoyancy = -0.03;  // Wants to float
  float drag = 0.020;      // Water exerts drag
  float launchV = 13;      // Launch speed
  float dx = 0;      // deltas per frame
  float dy = 0;
  int nTorps;        // Number of torpedos remaining (set in constructor)
  int waitSome = 0;

  Torpedo(int n)     // Pass in number of torpedos
  {
    nTorps = n;
  }

  void reset()
  {
    dx = 0;          // Start it over not moving
    dy = 0;
  }

  void fire(float x, float y) // Called when 'f' hit by user
  {
    if (tState == 0)          // Can only fire from state 0
    {
      xLoc = x+60;            // Offset starting location within sub
      yLoc = y+30;
      dx = launchV;           // launch speed
      dy = sub.dy*0.5;        // Use half of Sub's vertical speed
      tState = 1;
      aud.panPlay(aud.torpRunSnd, x, launchV);
    }
    else if (tState == 3)     // No more torpedos, state is a sink
      aud.safePlay (aud.noMoreSnd, x);
  }

  boolean running()
  {
    return tState == 1;
  }

  void explode()          // Called when torpedo hits a mine
  {
    if (tState == 1)      // Can only explode if currently running
    {
      tState = 2;         // Torpedo is gone
      waitSome = 30;      // Give animations a chance to finish
      aud.torpRunSnd.pause();
    }
  }

  // Primary move method
  void move()
  {
    if (tState == 0)          // Prelaunch state
    {
      if (nTorps <= 0)        // Out of torpedos
        tState = 3;           // Go to no more torpedos state
    }
    else if (tState == 1)     // Launched and running
    {
      if (xLoc > width + 100) // Torpedo beyond window, so give up...
      {
        tState = 2;           // ...and retire the torpedo
        waitSome = 30;        // Give animations a chance to finish
        aud.fadeOut(aud.torpRunSnd);
      }
      else                    // Torpedo still running, so stay in this state
      {
        dx -= drag;           // Always moves to right so drag always to left
        xLoc = xLoc + dx;
        dy += buoyancy;       // Always edges up
        yLoc = yLoc + dy;
      }
    }
    else if (tState == 2)     // Torpedo's run over, waiting to reset
    {
      waitSome--;
      if (waitSome <= 0)      // Animations should have finished
      {
        nTorps--;             // Count the torpedo
        reset();              // Reinitialize torpedo's attributes
        tState = 0;           // and reset to initial state
      }
    }
    //else tState == 3 => No more torpedos, state is a sink
  }

  float xNose()        // Returns x coordinate of nose cone
  {
    return xLoc + tx3;
  }

  float yNose()        // Returns y coordinate of nose cone
  {
    return yLoc + ty3;
  }

  void display()
  {
    if (tState == 1)   // Only display if torpedo is launched and running
    {
      image(gr.tImage, xLoc, yLoc);  // Torpedo body
      strokeWeight(2);               // Detonator in nose
      stroke(0);
      fill(75, 255, 255);
      triangle (xLoc+tx1, yLoc+ty1, xLoc+tx2, yLoc+ty2, xLoc+tx3, yLoc+ty3);
    }
  }
}

