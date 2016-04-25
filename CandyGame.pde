// Candy Game by Sil Fang & Ginger Guo



import processing.video.*;
import ddf.minim.*;

// declear var

Capture cam;
int Scene = 0; 
// Scene 0 = Setting Screen,1 = Start screen, 2 = Game Sscreen, 3 = Game Over
ColorTracker colorTracker;
ColorTracker activeTracker;

Minim minim = new Minim(this);
;
AudioPlayer bgm;

boolean camMirrored = false;
boolean setupComplete = false;
boolean debug = true;

String cameraDesc;
PImage background;

Pumpkin pumpkin;
ArrayList<Candy> Candies = new ArrayList<Candy>();

float gravity = 0.1;

int score = 0;
AudioSnippet[] soundsArray;

int lastTime = 0;
int timeLimit = 60;

void setup() {
  // init 
  
  
  size(640, 480);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    println("Selected camera:");
    int i = 0;
    for ( i = 0; i < cameras.length; i++) {
      if (int(cameras[i].split(",")[2].split("=")[1]) >= 15) {
        cameraDesc = cameras[i];
        break;
      }
    }

    println(cameras[i]);

    cam = new Capture(this, cameras[i]);
    cam.start();

    colorTracker=new ColorTracker(color(150, 0, 0), 10, cam, 1, camMirrored);

    activeTracker=colorTracker;

    setupComplete = true;

    background = loadImage("background.jpg");
    bgm = minim.loadFile("theme.mp3");

    String[] soundFileNameArray= {
      "kick.wav", "stomp.wav", "cheer.wav"
    };

    soundsArray = new AudioSnippet[soundFileNameArray.length];

    for (i = 0; i<soundFileNameArray.length;i++) {
      println("loading sound file->"+soundFileNameArray[i]);
      soundsArray[i] = minim.loadSnippet(soundFileNameArray[i]);
    }

    for (i = 0; i < 10; i++) {
      Candies.add(new Candy(0, 0, loadImage("candy" + int(random(1, 6)) + ".png")));
      Candies.get(Candies.size() - 1).reset();
    }
  }
}

void captureEvent(Capture c) {

  if (setupComplete) {

    colorTracker.update();
  }
}


void draw() {

  switch(Scene) {
  case 0:
  
  // Setting screen

    // Start / Setting Screen

    if (cam.available() == true) {
      cam.read();
    }
    image(cam, 0, 0);

    colorTracker.display();

    fill(255, 0, 0);
    textSize(15);
    text("Camera: "+ cameraDesc, width / 2 - 200, 50);
    text("1 = mirrored camera, 2 = not mirrored", width / 2 - 200, 100);
    text("click on the screen to start tracking color", width / 2 - 200, 150);
    text("spacebar to continue", width / 2 - 200, 200);
    break;
  case 1:
  
  // Start
  
    image(background, 0, 0);

    break;
  case 2:
  
  // Game Screen
  
    if (cam.available() == true) {
      cam.read();
    }
    image(cam, 0, 0);

    colorTracker.display();

    pumpkin.draw();

    for (int i = 0; i < Candies.size();i++) {
      // draw candies and detect hitbox
      
      
      Candies.get(i).draw();

      if (activeTracker.mirrored) {
        if (abs(Candies.get(i).x - (width-activeTracker.avgPixel.x)) < Candies.get(i).img.width / 2 + activeTracker.crossHairSize / 2
          && abs(Candies.get(i).y - activeTracker.avgPixel.y) < Candies.get(i).img.height / 2 + activeTracker.crossHairSize / 2 && !Candies.get(i).dying) {
          scored(i);
        }
      } 
      else {
        if (abs(Candies.get(i).x - (activeTracker.avgPixel.x)) < Candies.get(i).img.width / 2 + activeTracker.crossHairSize / 2
          && abs(Candies.get(i).y - activeTracker.avgPixel.y) < Candies.get(i).img.height / 2 + activeTracker.crossHairSize / 2 && !Candies.get(i).dying) {
          scored(i);
        }
      }
    }

    fill(0, 0, 255);
    textSize(20);
    text("Score:" + score, width / 2 - 30, 20);
    fill(255, 0, 0);
    text(timeLimit, width / 2 - 10, 50);


    if (millis() - lastTime >= 1000) {
      timeLimit -= 1;
      lastTime = millis();

      if (timeLimit <= 0) {
        Scene ++;
      }
    }
    break;

  case 3:
  
  // Game over screen
  
    background(0);
    fill(255);
    textSize(30);
    text("Game Over!", width / 2 - 80, 180);
    text("Score:" + score, width / 2 - 80, 210);
    text("Press R to restart", width / 2 - 120, 240);

    break;
  }
}

void mousePressed() {
  // Save color where the mouse is clicked
  switch(Scene) {
  case 0:

    if (setupComplete) {
      int loc=0;
      if (activeTracker.mirrored==true) {
        loc = (width-mouseX)/activeTracker.divisor + mouseY/activeTracker.divisor*activeTracker.video.width;
      }
      else {
        loc = mouseX/activeTracker.divisor + mouseY/activeTracker.divisor*activeTracker.video.width;
      }
      activeTracker.setTrackingColor(loc);
    }
    break;
  case 1:
    Scene ++;
    pumpkin = new Pumpkin(width / 2, 400);


    break;
  }
}

void keyPressed() {

  switch(Scene) {
  case 0:
    println(keyCode); // 49 = 1,50 = 2, 32 = space

      if (keyCode == 49) {
      activeTracker.mirrored = true;
    }

    if (keyCode == 50) {
      activeTracker.mirrored = false;
    }

    if (keyCode == 32) {
      Scene ++;
      debug = false;
      bgm.loop();
    }
    break;

  case 3:
    reset();
    break;
  }
}

void reset() {
  // reset all stuff
  
  
  timeLimit = 60;
  score = 0;

  for (int i = 0; i < Candies.size(); i++) {
    Candies.get(Candies.size() - 1).reset();
  }

  Scene = 2;
}

void scored(int i) {
  // add score
  
  score += 10;
  Candies.get(i).dying = true;
  int soundIndex=int(random(0, soundsArray.length));
  soundsArray[soundIndex].play(0);
}

