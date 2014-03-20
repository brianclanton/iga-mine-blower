/* Graphics class - by Al Biles
 Declares and loads all graphics assets.
 The loadGraphics() method should be called in setup().
 */
class Graphics
{
  int nSubFrms = 9;    // Number of frames in Sub animation
  PImage [] subFrm = new PImage [nSubFrms];    // Sub Animation
  PImage [] zapSubFrm = new PImage [nSubFrms]; // Zap animation
  PImage sinkImage;    // Sunk sub image (no animation, just sinks)

  int nMineFrms = 8;   // Number of frames in Mine animation
  PImage [] mineFrm = new PImage [nMineFrms];  // Mine animation
  int nExpFrms = 16;   // Number of frames in explosion animation
  PImage [] expFrm = new PImage [nExpFrms];    // Explosion animation

  int nEelFrms = 22;   // Number of frames in Eel animation
  PImage [] eelFrms = new PImage [nEelFrms];   // Eel animation

  PImage tImage;       // Torpedo image (no animation, just moves)
  
  int nBubFrms = 15;   // Number of frames in bubble animation
  PImage [] bubFrm = new PImage [nBubFrms];    // Bubble animation

  void loadGraphics()  // Called from setup()
  {
    tImage = loadImage("Torpedo.png");  // Torpedo doesn't animate, just moves
    loadSubImages();
    loadMine();
    loadExplosion();
    loadEelImages();
    loadBubbles();
  }

  void loadSubImages()
  {
    for (int i = 0; i < nSubFrms; i++)
    {
      subFrm[i] = loadImage ("SubFrames/Sub" + i + ".png");
      zapSubFrm[i] = loadImage ("SubFrames/Sub" + i + ".png");
      zapSubFrm[i].filter(INVERT);  // Zap frames are color-inverted
      sinkImage = loadImage ("SubFrames/Sub0.png");
      sinkImage.filter(GRAY);       // Image when it's sinking is gray scale
    }
  }

  void loadMine()
  {
    for (int i = 0; i < nMineFrms; i++)
      mineFrm[i] = loadImage("MineFrames/Mine" + i + ".png");
  }

  void loadExplosion()
  {
    for (int i = 0; i < nExpFrms; i++)
      expFrm[i] = loadImage("ExpFrames/Exp" + i + ".png");
  }

  void loadEelImages()
  {
    int groundFrm = nEelFrms - 1;  // Last frame is image when eel is grounded
    for (int i = 0; i < groundFrm; i++)  // groundFrm extra, special
    {
      eelFrms[i] = loadImage ("EelFrames/Eel" + i + ".png");
    }
    eelFrms[groundFrm] = loadImage ("EelFrames/Eel16.png");  // Grounded
  }
  
  void loadBubbles()
  {
    for (int i = 0; i < nBubFrms; i++)
      bubFrm[i] = loadImage("BubFrames/Bubbles" + i + ".png");
  }
}

