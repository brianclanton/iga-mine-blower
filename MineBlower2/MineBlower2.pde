/* MineBlower Version 2.0 - by Al Biles
 This game was developed for IGME 571, Interactive and Game Audio
 The purpose is to provide a simple 2D game that requires a lot
 of audio assets that can be developed in the class.
 The types of assets are the usual suspects: Foley and ambient
 sounds, background music, dialog, and interface sounds.
 The version distributed to the class has placeholder sounds that
 should be sufficiently annoying to motivate their replacement
 with student-generated audio.  All the default sounds can be replaced
 by simply changing the files in the Audio folder, but there are
 opportunities to add additional audio triggered by events that
 are not linked to audio yet.  The ambient sounds and dialog assets
 are in this category, as there are no placeholder sounds for them.
 */
import ddf.minim.spi.*;        // Set up the audio library
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;

// Audio assets object contains all audio assets & specialized methods 
Audio aud = new Audio();

// Graphics assets object contains all the animations and still frames
Graphics gr = new Graphics();

Sub sub;

int nEels = 9;
Eel [] eels = new Eel [nEels];

int nMines = 6;
Mine [] mines = new Mine [nMines];
final int MAX_RESET = 2;        // Max number of times a mine can be reset

Torpedo t1;                     // Torpedo object
int nTorpedos = 6;              // Can use the torpedo this many times max

Bubbles b1;                     // Does the bubbles

Score sc;                       // Handles score and health

boolean downPressed = false;    // True when DOWN arrow is pressed
boolean leftPressed = false;    // Ditto LEFT arrow
boolean rightPressed = false;   // Ditto RIGHT arrow
boolean showInstruct = false;

int gameState = 0;              // 0 intro, 1 play, 2 sinking, 3 sank, 4 won
int winWait = 100;              // Give animations time to finish if won

float backOff = 0.0;            // Background hue offset for Perlin noise
int pingCount = 0;              // Counter to keep random pings at bay

void setup()
{
  smooth();
  //size(displayWidth-10, displayHeight-50);  // Nearly full screen
  size(1400, 1000);
  imageMode(CENTER);
  colorMode(HSB);
  background(129, 60, 220);
  frameRate(30);                // Slow it down a bit

  gr.loadGraphics();            // Load up the graphics assets
  minim = new Minim(this);      // Set up the audio interface
  aud.loadAudio();              // Load up the audio assets

  sub = new Sub();

  for (int i = 0; i < nEels; i++)   // Create all the eels
    eels[i] = new Eel();
  for (int i = 0; i < nMines; i++)  // Create all the mines
    mines[i] = new Mine();
  t1 = new Torpedo(nTorpedos);  // Use same torpedo multiple times
  b1 = new Bubbles();

  sc = new Score();

  aud.backSnd.loop();           // Fire up background music
}

void draw()
{
  aud.backSync.Update();
  
  if (gameState == 0)           // Show instructions
  {
    if (showInstruct)
      sc.instructions();
    else
      sc.splashScreen();
  }
  else if (gameState == 3)      // Game over, sub sunk
  {
    sc.youSankScreen();
  }
  else if (gameState == 4 && winWait <= 0)  // Game over, player won!
  {
    sc.youWonScreen();
  }
  else // gameState 1: still in the game, or gameState 4: waiting to win
  {
    if (gameState == 4)        // Counting down to win
    {
      winWait--;
      if (winWait == 0)
        aud.safePlay(aud.winSnd);  // Trigger wind sound only once
    }

    // Update /////////////////////////////////////////
    aud.backSync.intro = false;
    
    b1.move();                        // Animate the bubbles
    // Ambient sonar ping
    maybePing();

    for (int i = 0; i < nEels; i++)   // Animate all the eels
      eels[i].move();

    for (int i = 0; i < nMines; i++)  // Animate all the mines
      mines[i].move();

    t1.move();                        // Move the torpedo

    sub.move();                       // Move the sub

    if (t1.running())                 // See if the torpedo hit anything
        checkTorpedo();

    if (! sub.sunk())                 // Check mines for sub touches
      checkMines();

    for (int i = 0; i < nEels; i++)   // Check eels for sub touches
      if (sub.eelTouch(eels[i]))
      {
        sub.zap();                    // If touching, zap 'em both
        eels[i].zap();
      }

    // Display ////////////////////////////////////////
    backOff += 0.02;                  // Subtle changes in background hue
    float hue = noise(backOff) * 20 + 122;  // using Perlin noise
    background(hue, 60, 220);

    sc.display();                     // Display the score

    b1.display();                     // Display the bubbles

    for (int i = 0; i < nMines; i++)  // Display all the fading mines
      if (mines[i].inactive())
        mines[i].display();

    for (int i = 0; i < nEels; i++)   // Display all the grounded eels
      if (eels[i].grounded())
        eels[i].display();

    t1.display();                     // Display the torpedo
    sub.display();                    // Display the sub

    for (int i = 0; i < nMines; i++)  // Display all the active mines
      if (! mines[i].inactive())
        mines[i].display();

    for (int i = 0; i < nEels; i++)   // Display all the active eels
      if (! eels[i].grounded())
        eels[i].display();
  }
}

// Maybe generate an ambient ping - Creates new PingTone object each time
// it decides to start a ping echo chain so that more than one can play
// at the same time.  
void maybePing()
{
  if (pingCount > 0)                  // Too soon since previous ping
    pingCount--;
  else if (random (0, 100) < 1.0)
  {
    pingCount = 50;                   // Wait at least 50 frames
    //PingTone pt = new PingTone();     // PingTone class in Audio tab
    //pt.noteOn();
    aud.safePlay(aud.pingSnd);
  }
}

void checkTorpedo()
{
  for (int i = 0; i < nEels; i++)   // Check all eels for torpedo touches
  {
    if (eels[i].touch(t1.xNose(), t1.yNose()))
    {
      eels[i].ground();
    }
  }

  boolean hitMine = false;          // Check mines for torpedo touches
  int k = 0;                        // Until one is hit or missed them all
  while (! hitMine && k < nMines)
  {
    if (mines[k].touch(t1.xNose(), t1.yNose()))
    {
      mines[k].explode();
      t1.explode();
      sub.blast(mines[k].mineX(), mines[k].mineY());
      sc.detonatePoints();          // Score points for hitting a mine
      hitMine = true;
    }
    else
      k++;            // Haven't hit one yet, so check next one
  }
}

void checkMines()
{
  boolean touchMine = false;         // Check mines for sub touches
  int i = 0;                         // Until one is hit or missed them all
  while (! touchMine && i < nMines)
  {
    if (mines[i].touch(sub.arm.xGrab(), sub.arm.yGrab()))
    {
      if (sub.careful())             // If arm touch careful enough...
      {
        mines[i].disarm();           // Disarm it and score points
        touchMine = true;
      }
      else
      {
        mines[i].explode();          // Too hard, blow it up
        sub.blast(mines[i].mineX(), mines[i].mineY());
        sc.blastPoints();
        touchMine = true;
      }
    }
    else if (sub.mineTouch(mines[i])) // Any sub touch blows it up
    {
      mines[i].explode();
      sub.blast(mines[i].mineX(), mines[i].mineY());
      sc.blastPoints();
      touchMine = true;
    }
    else
      i++;
  }
}

void keyPressed()         // Handle key presses
{
  if (keyCode == DOWN)
    downPressed = true;
  if (keyCode == LEFT)
    leftPressed = true;
  if (keyCode == RIGHT)
    rightPressed = true;
  if (key == 'f')
    sub.fireTorp(t1);
  if (key == '?' && gameState == 0)
    showInstruct = true;
  if (key == 's' && gameState < 2)
    gameState = 1;
  if (key == 'q')
  {
    aud.pauseAll();       // Pause or stop all the sounds
    exit();
  }
}

void keyReleased()        // Detect key releases and reset booleans
{
  if (keyCode == DOWN)
  {
    downPressed = false;
    aud.diveSnd.pause();  // Pause the sound immediately
  }
  if (keyCode == LEFT)
  {
    leftPressed = false;
    aud.reverseSnd.pause();
  }
  if (keyCode == RIGHT)
  {
    rightPressed = false;
    aud.forwardSnd.pause();
  }
  if (key == '?')
    showInstruct = false;
}

void stop()      // Override the default stop() method to clean up audio
{
  aud.closeAll();      // Close up all the sounds
  minim.stop();        // Close up minim itself
  super.stop();        // Close up rest of program
}

