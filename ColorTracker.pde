// edited from pong-color-tracking-example - ColorTracker

class ColorTracker {

  color trackingColor;  // color to track
  int tolerance; // color tolerance 

  ArrayList<Pixel> closeColorsArray = new ArrayList<Pixel>(); // array of pixels that are close to the tracking color
  int closeColorsArrayLastLocation=0; // the last index location of the current set of close colors

  Pixel avgPixel; // average Pixel in the close colors array
 
  Capture video; 
  int divisor;

  int videoArea;

  int crossHairSize=20;

  boolean mirrored;

  ColorTracker(color paramColor, int paramTolerance, Capture paramVideoCapture, int paramDivisor, boolean paramMirrored) {

    video=paramVideoCapture;
    videoArea=width*height;
    divisor=paramDivisor;

    mirrored=paramMirrored;

    trackingColor=paramColor;
    tolerance=paramTolerance;

    // initialize Array with zeroes to avoid errors when Video image is not available
    for (int i = 0; i < (videoArea); i ++ ) {
      closeColorsArray.add(new Pixel(0, 0));
    }
    avgPixel=new Pixel(0, 0);
    
    
  }


  void update() {

    int index=0;
    int totalX=0;
    int totalY=0;

    video.loadPixels();

    // Begin loop to walk through every pixel
    for (int x = 0; x < video.width; x ++ ) {
      for (int y = 0; y < video.height; y ++ ) {
        int loc = x + y*video.width;
        // What is current color
        color currentColor = video.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);

        float r2 = red(trackingColor);
        float g2 = green(trackingColor);
        float b2 = blue(trackingColor);

        // Using euclidean distance to compare colors
        // We are using the dist( ) function to compare the current color with the color we are tracking.
        float d = dist(r1, g1, b1, r2, g2, b2); 

        // add to totals and increment index 
        if (d < tolerance) {
          closeColorsArray.set(index,new Pixel(x*divisor, y*divisor));
          totalX+=x*divisor;
          totalY+=y*divisor;
          index++;
        }
      }
    }


    if (index>0) {
      //println(totalX);
      avgPixel.x=totalX/index;
      avgPixel.y=totalY/index;
    }

    closeColorsArrayLastLocation=index;

    video.updatePixels();
  }

  void increaseTolerance(int amount) {
    tolerance+=amount;
    tolerance=constrain(tolerance, 2, 200);
  }

  void decreaseTolerance(int amount) {
    tolerance-=amount;
    tolerance=constrain(tolerance, 2, 200);
  }
  void setTrackingColor(int loc) {
    trackingColor=video.pixels[loc];
    println(red(trackingColor)+"-"+green(trackingColor)+"-"+blue(trackingColor));
  }

  color getTrackingColor() {
    return trackingColor;
  }

  void display() {
    if (debug) {
      displayTrackedPixels();
    }
    displayCrossHairs();
  }

  void displayCrossHairs() {
    noSmooth();
    stroke(0);
    strokeWeight(1);
    rectMode(CENTER);
    if (mirrored) {
      line(width-avgPixel.x, avgPixel.y-crossHairSize, width-avgPixel.x, avgPixel.y+crossHairSize);
      line(width-avgPixel.x-crossHairSize, avgPixel.y, width-avgPixel.x+crossHairSize, avgPixel.y);
      fill(trackingColor);
      rect(width-avgPixel.x, avgPixel.y, crossHairSize, crossHairSize);
    }
    else {
      line(avgPixel.x, avgPixel.y-crossHairSize, avgPixel.x, avgPixel.y+crossHairSize);
      line(avgPixel.x-crossHairSize, avgPixel.y, avgPixel.x+crossHairSize, avgPixel.y);
      fill(trackingColor);
      rect(avgPixel.x, avgPixel.y, crossHairSize, crossHairSize);
    }
    smooth();
  }


  void displayTrackedPixels() {
    noSmooth();
    strokeWeight(divisor);
    //stroke(trackingColor);
    stroke(random(255), random(255), random(255));

    for (int i = 0;i < closeColorsArrayLastLocation; i ++ ) {
      if (mirrored) {
        point(width-closeColorsArray.get(i).x, closeColorsArray.get(i).y);
      }
      else {
        point(closeColorsArray.get(i).x, closeColorsArray.get(i).y);
      }
    }
    smooth();
  }
}
