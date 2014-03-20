/* Bubbles class - by Al Biles
 Does bubbles animation at random places
 */

class Bubbles
{
  float xLoc;
  float yLoc;
  int bubFrmN = 0;

  Bubbles()
  {
    xLoc = random (200, width-200);
    yLoc = random (200, height-100);
  }

  // Resets the bubbles to happen at a randomish location away
  // from where it was last time
  void reset()
  {
    float newXLoc = random (200, width-200);
    float newYLoc = random (200, height-100);
    while (dist (xLoc, yLoc, newXLoc, newYLoc) < width / 3.0)
    {
      newXLoc = random (200, width-200);
      newYLoc = random (200, height-100);
    }
    xLoc = newXLoc;
    yLoc = newYLoc;
    aud.safePlay(aud.bubbleSnd, xLoc);
  }

  void move()
  {
    if (frameCount % 6 == 0)  // Advance animation every 6th draw() frame
    {
      bubFrmN = (bubFrmN + 1);
      if (bubFrmN >= gr.nBubFrms)
      {
        bubFrmN = 0;          // If it's over, start it elsewhere
        reset();
      }
    }
  }

  void display()
  {
    image (gr.bubFrm[bubFrmN], xLoc, yLoc);
  }
}

