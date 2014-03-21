/* Audio class - by Al Biles
 Declares and loads all audio assets.
 Should be called in setup().
 Also provides methods that make life easier for playing or triggering
 sounds from the other classes.
 safePlay() plays a sound only if the sound isn't already playing.
 safePlay() has an overload that plays the sound at a given pan loc.
 triggerWhere() triggers an AudioSample at a given pan location.
 panPlay() is a specialized method for playing the torpedo track sound
 by panning it with the torpedo from the sub's location on launch
 to the right edge of the window and then fading it out from there. 
 This tab also contains the PingTone class, which uses Minim UGens
 to synthesize sonar ping tones as an example of using synthesis
 techniques for sound effects.
 */
class Audio
{
  AudioPlayer forwardSnd;
  AudioPlayer reverseSnd;
  AudioPlayer diveSnd;
  AudioSample bangSnd;
  AudioSample disarmSnd;
  AudioSample zapSnd1;
  AudioSample zapSnd2;
  AudioSample groundSnd;
  AudioPlayer noMoreSnd;
  AudioPlayer fireSnd;
  AudioPlayer backSnd;
  AudioPlayer tooLeftSnd;
  AudioPlayer tooRightSnd;
  AudioPlayer tooUpSnd;
  AudioPlayer tooDownSnd;
  AudioPlayer sinkingSnd;
  AudioPlayer startSnd;
  AudioPlayer sunkSnd;
  AudioPlayer winSnd;
  AudioPlayer bubbleSnd;
  AudioPlayer torpRunSnd;
  AudioPlayer pingSnd;

  AudioOutput out;    // Used for PingTone
  
  Synchronizer backSync;

  void loadAudio()    // Called in setup()
  {
    forwardSnd = minim.loadFile("Audio/Forward.mp3", 512);
    forwardSnd.setGain(-8.0);     // Turn it down
    reverseSnd = minim.loadFile("Audio/Reverse.mp3", 512);
    reverseSnd.setGain(-8.0);
    diveSnd = minim.loadFile("NewAudio/Dive.mp3", 512);
    diveSnd.setGain(-8.0);
    bangSnd = minim.loadSample("NewAudio/Bang.mp3", 512);
    bangSnd.setGain(8.0);
    disarmSnd = minim.loadSample("NewAudio/Disarm.mp3", 512);
    disarmSnd.setGain(4.0);
    zapSnd1 = minim.loadSample("NewAudio/Zap1.mp3", 512);
    zapSnd1.setGain(-4.0);
    zapSnd2 = minim.loadSample("NewAudio/Zap2.mp3", 512);
    zapSnd2.setGain(-4.0);
    groundSnd = minim.loadSample("NewAudio/Grounded.mp3", 512);
    groundSnd.setGain(-4.0);
    noMoreSnd = minim.loadFile("NewAudio/NoMore.mp3", 512);
    fireSnd = minim.loadFile("Audio/Fire.mp3", 512);
    backSnd = minim.loadFile("NewAudio/Ocean.mp3", 512);
    backSnd.setGain(-10.0);
    tooLeftSnd = minim.loadFile("NewAudio/TooLeft.mp3", 512);
    tooRightSnd = minim.loadFile("NewAudio/TooRight.mp3", 512);
    tooUpSnd = minim.loadFile("NewAudio/TooUp.mp3", 512);
    tooDownSnd = minim.loadFile("NewAudio/TooDown.mp3", 512);
    sinkingSnd = minim.loadFile("NewAudio/Sinking.mp3", 512);
    startSnd = minim.loadFile("NewAudio/GameStart.mp3", 512);
    sunkSnd = minim.loadFile("NewAudio/Sunk.mp3", 512);
    winSnd = minim.loadFile("NewAudio/Win.mp3", 512);
    bubbleSnd = minim.loadFile("NewAudio/Bubbles.mp3", 512);
    //bubbleSnd.setGain(-12.0);
    torpRunSnd = minim.loadFile("Audio/TorpedoRun.mp3", 512);
    //torpRun.setGain(-12.0);
    pingSnd = minim.loadFile("NewAudio/Ping.mp3", 512);    

    out = minim.getLineOut();    // Used for PingTone
    
    backSync = new Synchronizer();
  }

  void pauseAll()  // Called when user types 'q' to quit
  {    
    forwardSnd.pause();
    reverseSnd.pause();
    diveSnd.pause();
    bangSnd.stop();
    disarmSnd.stop();
    zapSnd1.stop();
    zapSnd2.stop();
    groundSnd.stop();
    noMoreSnd.pause();
    fireSnd.pause();
    backSnd.pause();
    tooLeftSnd.pause();
    tooRightSnd.pause();
    tooUpSnd.pause();
    tooDownSnd.pause();
    sinkingSnd.pause();
    startSnd.pause();
    sunkSnd.pause();
    winSnd.pause();
    bubbleSnd.pause();
    torpRunSnd.pause();
    pingSnd.pause();
    out.mute();
  }

  void closeAll()  // Called from stop() in main
  {
    forwardSnd.close();
    reverseSnd.close();
    diveSnd.close();
    bangSnd.close();
    disarmSnd.close();
    zapSnd1.close();
    zapSnd2.close();
    groundSnd.close();
    noMoreSnd.close();
    fireSnd.close();
    backSnd.close();
    tooLeftSnd.close();
    tooRightSnd.close();
    tooUpSnd.close();
    tooDownSnd.close();
    sinkingSnd.close();
    startSnd.close();
    sunkSnd.close();
    winSnd.close();
    bubbleSnd.close();
    torpRunSnd.close();
    pingSnd.close();
  }

  // Plays snd beginning at pan location x, panning in real time
  // toward right window edge, given initial torpedo speed launchV
  void panPlay(AudioPlayer snd, float x, float launchV)
  {
    if (! snd.isPlaying())
    {
      float panStart = map(x, 0, width, -1.0, 1.0);  // Where to start pan
      int panTime = figurePanTime(x, launchV);  // How long pan will take
      snd.rewind();
      snd.setGain(0.0);
      snd.shiftPan(panStart, 1.0, panTime);     // Start panning the sound
      snd.play();                               // Start playing the sound
    }
  }

  // Figures how many milliseconds it will take for torpedo to move from
  // x location to right window edge, given initial speed initV
  int figurePanTime(float x, float initV)
  {
    float where = x;       // Starting at x, move where
    float velX = initV;    // Initial velocity
    int nPanFrames = 0;    // Count number of frames
    while (where < width)
    {
      where += velX;       // move to next x location
      velX -= t1.drag;     // Apply drag effect
      nPanFrames++;        // Count the frame
    }
    return int (nPanFrames * 1000 / frameRate);  // Convert to milliseconds
  }

  // Fade out snd over the rest of its playing
  void fadeOut(AudioPlayer snd)
  {
    if (snd.isPlaying())
    {
      int fadeTime = snd.length() - snd.position() - 100;  // How much left
      snd.shiftGain(snd.getGain(), -40.0, fadeTime);       // Fade that long
    }
  }

  // Play sound only if it's not already playing
  void safePlay (AudioPlayer snd)
  {
    if (! snd.isPlaying())
    {
      snd.rewind();
      snd.play();
    }
  }

  // Overload to play at loc x mapped to L/R pan
  void safePlay (AudioPlayer snd, float x)
  {
    if (! snd.isPlaying())
    {
      snd.rewind();
      snd.setPan(map(x, 0, width, -1.0, 1.0));
      snd.play();
    }
  }

  // Trigger at pan value mapped from x location
  void triggerWhere(AudioSample snd, float x)
  {
    snd.setPan(map(x, 0, width, -1.0, 1.0));
    snd.trigger();
  }

  void oscOn()
  {
    /*
    println("Entering oscOn");
     wave.reset();
     damp.activate();
     // turn on the ADSR
     adsr.noteOn();
     // patch to the output
     myDelay.patch( out );
     */
  }

  void oscOff()
  {
    // tell the ADSR to unpatch after the release is finished
    //damp.unpatchAfterDamp( out );
    /*
    // call the noteOff 
     adsr.noteOff();
     */
  }

  // Triggered when sub moves too far out of the window
  void tooFarLeft()  // Plays when sub too far left out of the window
  {
    safePlay(tooLeftSnd, 0.0);
  }

  void tooFarRight()
  {
    safePlay(tooRightSnd, width);
  }

  void tooFarUp()
  {
    safePlay(tooUpSnd);
  }

  void tooFarDown()
  {
    safePlay(tooDownSnd);
  }
}

/* PingTone class - by Al Biles
 Uses Minim UGens to implement a synthesis chain that generates
 sonar pings at a random pan location.
 Main creates a PingTone object and calls noteOn() to start pinging
 */
class PingTone
{
  Oscil myWave;      // Sine wave oscillator for the ping sound
  Damp myDamp;       // Damp envelope for decay after quick attack
  Delay myDelay;     // Use Delay effect for echo
  Pan myPan;         // Pan it somewhere in the stereo field

  PingTone()         // Constructor creates an object for the pings
  {
    myWave = new Oscil( 1000, 0.4, Waves.SINE ); // 1000 Hz, kinda loud
    myDamp = new Damp( 0.01, 0.15, 0.9 );         // Attack, decay time, amp
    myDelay = new Delay( 0.75, 0.5, true, true ); // Delay with feedback
    myPan = new Pan(random(-1.0, 1.0));          // Random pan location
    myWave.patch(myDamp).patch(myDelay).patch(myPan); // Chain together
  }

  void noteOn()      // Called from main to start pinging
  {
    myDamp.activate();          // Turn on the envelope
    myPan.patch( aud.out );     // Patch end of chain to out to hear it
    myDamp.unpatchAfterDamp( aud.out );
  }

  void noteOff()                // Not needed with the Delay envelope
  {
    myDamp.unpatchAfterDamp( aud.out );
  }
}


class Synchronizer
{
  AudioPlayer introRiff;
  AudioPlayer mainRiff;
  AudioPlayer susRiff;
  AudioPlayer hitRiff;
  AudioPlayer missRiff;
  
  Balance bal;
  
  int lastBeat;
  int beat;
  int lastSync;
  int deltaSync;
  float bpm;
  
  boolean fire = false;
  boolean suspend = false;
  boolean hit = false;
  boolean miss = false;
  boolean intro = true;
  
  Synchronizer()
  {
    introRiff = minim.loadFile("NewAudio/IntroRiff.mp3", 512);
    introRiff.setGain(-6.0);
    mainRiff = minim.loadFile("NewAudio/MainRiff.mp3", 512);
    mainRiff.setGain(-6.0);
    susRiff = minim.loadFile("NewAudio/SuspenseRiff.wav", 512);
    susRiff.setGain(-0.0);
    hitRiff = minim.loadFile("NewAudio/HitRiff.wav", 512);
    hitRiff.setGain(-0.0);
    missRiff = minim.loadFile("NewAudio/MissRiff.wav", 512);
    missRiff.setGain(-0.0);
    
    bpm = 104;
    Start();
  }
  
  void Start()
  {
    lastBeat = 0;
    beat = 0;
    lastSync = millis();
    deltaSync = 0;
    introRiff.loop();
  }
  
  void StopAll()
  {
    introRiff.pause();
    mainRiff.pause();
    susRiff.pause();
    hitRiff.pause();
    missRiff.pause();
  }
  
  void Update()
  {
    deltaSync = millis() - lastSync;
    lastBeat = beat;
    beat += floor(deltaSync * bpm / 60000);
    
    if (suspend)
    {
      if (hit)
      {
        StopAll();
        hit = false;
        miss = false;
        suspend = false;
        fire = false;
        hitRiff.play(0);
        lastSync = millis();
        beat = 2;
      }
      else if (miss)
      {
        StopAll();
        hit = false;
        miss = false;
        suspend = false;
        fire = false;
        missRiff.play(0);
        lastSync = millis();
        beat = 2;
      }
      else
      {
        
      }
    }
    else if (beat != lastBeat)
    {
      lastSync += 60000.0f / bpm;
      
      switch(beat)
      {
        default:
          beat = 0;
        case 0:
          if (fire)
          {
            fire = false;
            if (hit)
            {
              StopAll();
              hit = false;
              miss = false;
              hitRiff.play(0);
            }
            else if (miss)
            {
              StopAll();
              hit = false;
              miss = false;
              missRiff.play(0);
            }
            else
            {
              StopAll();
              suspend = true;
              susRiff.play(0);
            }
          }
          else
          {
            if (!intro)
            {
              if (!mainRiff.isPlaying())
              {
                StopAll();
                mainRiff.loop();
              }
            }
            else
            {
              if (!introRiff.isPlaying())
              {
                StopAll();
                introRiff.loop(); 
              }
            }
          }
        
          break;
        case 1:
          
        
          break;
        case 2:
          if (fire)
          {
            fire = false;
            if (hit)
            {
              StopAll();
              hit = false;
              miss = false;
              hitRiff.play(0);
            }
            else if (miss)
            {
              StopAll();
              hit = false;
              miss = false;
              missRiff.play(0);
            }
            else
            {
              StopAll();
              suspend = true;
              susRiff.play(0);
            }
          }
          else
          {
            
          }
        
          break;
        case 3:
          
        
          break;
      }
    }
    
  }
}


