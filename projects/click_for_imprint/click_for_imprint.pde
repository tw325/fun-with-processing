//Uses opencv and video libraries, imports Rectangle from java
//scans camera video for contours within certain sizes
//click to increase contour threshold
//press SPACE while hovering inside contour to imprint contour


import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

OpenCV opencv;
Capture video;
//PImage prev;
ArrayList<Contour> contours;
ArrayList<Contour> feasiblecontours;
ArrayList<PVector> handpoints;
color handcolor;
int handcolor_r;
int handcolor_g;
int handcolor_b;
Contour selected;
int big;
Rectangle box;
int cthreshold;

void setup() {
  size (640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
  cthreshold = 70;
  feasiblecontours = new ArrayList<Contour>();
}

void draw() {
  video.loadPixels();
  image(video, 0, 0);

  opencv = new OpenCV(this, video);
  opencv.threshold(cthreshold);
  contours = opencv.findContours();

  noFill();
  //rect(50, 100, 200, 300);
  stroke(0, 255, 0);
  strokeWeight(3);
  big = 0;
  if (selected == null) {
    for (Contour contour : contours) {
      stroke(0, 255, 0);

      if (contour.area()> 500 & contour.area() < 300*500) {
        big++;
        feasiblecontours.add(contour);
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
  cthreshold +=2;
  /*for (Contour contour : contours) {
   if (contour.containsPoint(mouseX, mouseY)) {
   selected = contour;
   //
   handcolor_r = 0;
   handcolor_g = 0;
   handcolor_b = 0;
   handpoints = selected.getPoints();
   for (PVector p : handpoints){
   color c = get((int)p.x, (int)p.y);
   handcolor_r+=red(c);
   handcolor_g+=green(c);
   handcolor_b+=blue(c);
   }
   handcolor_r = handcolor_r/handpoints.size();
   handcolor_g = handcolor_g/handpoints.size();
   handcolor_b = handcolor_b/handpoints.size();
   handcolor = color(handcolor_r, handcolor_g, handcolor_b);
   print (handcolor_r, handcolor_g, handcolor_b);
   }
   }*/
}

void keyPressed() {
  if (key == ' ') {
    for (Contour contour : feasiblecontours) {
      if (contour.containsPoint(mouseX, mouseY)) {
        selected = contour;
        /*
      handcolor_r = 0;
         handcolor_g = 0;
         handcolor_b = 0;
         handpoints = selected.getPoints();
         for (PVector p : handpoints){
         color c = get((int)p.x, (int)p.y);
         handcolor_r+=red(c);
         handcolor_g+=green(c);
         handcolor_b+=blue(c);
         }
         handcolor_r = handcolor_r/handpoints.size();
         handcolor_g = handcolor_g/handpoints.size();
         handcolor_b = handcolor_b/handpoints.size();
         handcolor = color(handcolor_r, handcolor_g, handcolor_b);
         print (handcolor_r, handcolor_g, handcolor_b);*/
      }
    }
  }
}

void captureEvent(Capture video) {
  video.read();
}