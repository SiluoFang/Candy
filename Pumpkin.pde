class Pumpkin {

  int direction = 0; // 0 = left, 1 = right
  PImage img;
  float x, y;
  int randomValue = 0;

  Pumpkin(float tX, float tY) {
    x = tX;
    y = tY;
    img = loadImage("pumpkin.png");
  }

  void draw() {
    randomValue ++;
    
    if(randomValue >= 100){
      direction = int(random(0,2));
      randomValue = 0;
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
}
