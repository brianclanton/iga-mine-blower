/* Arm class - by Al Biles
 This class implements the arm sticking out of the top right of the sub,
 which is used to disarm mines.
 */
class Arm
{
  float xLoc;        // Arm location is where main boom connects to sub
  float yLoc;
  float xDev = 67;   // Arm location deviation from sub center
  float yDev = -15;
  float xGrab = 109; // Grab point deviation from arm location
  float yGrab = -37;
  float dx = 0;      // Used only when sub sinking and arm moves itself
  float dy = 0;
  float drag = 0.01;      // Water exerts drag

  Arm(float x, float y)   // Start arm connected to Sub
  {
    xLoc = x + xDev;
    yLoc = y + yDev;
  }

  float xGrab()      // Returns x coordinate of grab point
  {
    return xLoc + xGrab;
  }

  float yGrab()      // Returns y coordinate of grab point
  {
    return yLoc + yGrab;
  }

  void sinking(float x, float y, float sdx, float sdy)
  {
    xLoc = x + xDev;
    yLoc = y + yDev;
    dx = sdx + 3.0;
    dy = sdy - 1.0;
  }

  void move (float x, float y)  // Move the arm with the Sub
  {
    xLoc = x + xDev;
    yLoc = y + yDev;
  }

  void sinkingMove ()           // Move the arm on its own
  {
    dy += 0.05;
    yLoc = yLoc + dy;

    dx = dx + (dx > 0 ? -drag : (dx < 0 ? drag : 0));
    xLoc = xLoc + dx;
  }

  void display(int electroN)    // electroN: Number of frames left to zap
  {    
    if (electroN > 0)           // Arm flashes if sub zapping
      stroke(random(0, 255), 255, 255);  // Random Hue
    else
      stroke(100);              // Not zapping => gray
    strokeWeight(5);
    line (xLoc, yLoc, xLoc+70, yLoc-30);        // Main boom
    line (xLoc+70, yLoc-30, xLoc+100, yLoc-55); // Upper claw segment
    line (xLoc+70, yLoc-30, xLoc+100, yLoc-20); // Lower claw segment
    //point (xLoc+xGrab, yLoc+yGrab);   // Grab point for disarming
  }
}

