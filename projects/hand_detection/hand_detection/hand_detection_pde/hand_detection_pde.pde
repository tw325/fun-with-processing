import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Capture video;
//PImage block;
ArrayList<Contour> contours;
Contour selected;
int big;

void setup() {
  size (640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
}

void draw() {
  video.loadPixels();
  /*block = createImage(200, 300, RGB);
   block.loadPixels();
   int start = 0;
   for (int i = 50; i < 250; i++){
   for (int j = 100; j < 400; j++){
   block.pixels[start]=video.pixels[i+j*640];
   start++;
   }
   }
   block.updatePixels();*/
  image(video, 0, 0);

  opencv = new OpenCV(this, video);
  opencv.threshold(130);
  contours = opencv.findContours();

  noFill();
  //rect(50, 100, 200, 300);
  stroke(0, 255, 0);
  strokeWeight(3);
  big = 0;
  if (selected == null) {
    for (Contour contour : contours) {
      stroke(0, 255, 0);
      if (contour.area()> 50 * 100) {
        big++;
        contour.draw();
      }
      println(big);
    } 
  } else {
  selected.draw();
}
}

void mousePressed() {
  print(mouseX, mouseY);
  for (Contour contour : contours) {
    if (contour.containsPoint(mouseX, mouseY)) {
      println(contour.getBoundingBox());
      selected = contour;
    }
  }
}


void captureEvent(Capture video) {
  video.read();
}