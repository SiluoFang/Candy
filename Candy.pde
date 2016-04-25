class Candy {

  int direction = 0;
  float x, y;
  float Width, Height;
  float speedX, speedY;
  PImage img;
  boolean dying;
  int dyingEffect = 255;


  Candy(float tX, float tY, PImage tImg) {

    x = tX;
    y = tY;
    img = tImg;
  }

  void draw() {

    if (!dying) {

      x += speedX;
      y += speedY;

      speedY +=gravity;

      if (y > height + 200) {
        reset();
      }

      if (direction == 0) {
        pushMatrix();
        scale(-1, 1);
        image(img, -img.width - x, y);
        popMatrix();
      } 
      else {
        image(img, x, y);
      }
    } 
    else {
      dyingEffect -= 3;
      
      noStroke();
      fill(255,68,0,dyingEffect);
      ellipse(x,y,255 - dyingEffect,255 - dyingEffect);
      
      if(dyingEffect <= 0){
        reset();
      }
    }
  }

  void reset() {

    int randomEvents = int(random(0, 2));

    if (randomEvents == 0) {

      // appear from left

      x = random(- 200, - 100);
      y = random(height / 2, height);
      speedX = random(5, 8);
      speedY = random(-4, -9);
      direction = 0;
      dying = false;
    } 
    else {
      x = random( width + 200, width + 100);
      y = random(height / 2, height);
      speedX = random(-8, -5);
      speedY = random(-9, -4);
      direction = 1;
      dying = false;
    }

    img = loadImage("candy" + int(random(1, 6)) + ".png");
    dyingEffect = 255;
  }
}
