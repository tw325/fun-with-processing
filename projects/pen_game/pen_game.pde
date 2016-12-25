// captures live video using the camera and Processing's Video library
// USE A UNIFORM BACKGROUND IF POSSIBLE
// GET A STICK/PEN/PENCIL WHOSE COLOR IS NOT IN THE BACKGROUND
// PUT PEN IN FRAME AND CLICK ON PEN TO TAG PEN
// SMOOTHLY MOVE THE OBJECT AND SEE IT TRACED!
// tip: make sure pen is never at less than 0 or greater than 180 degrees.

import processing.video.*;
import java.io.*;
import java.util.*;

//menu
boolean menu = true;

// camera game
Capture video;
PImage prev;
color track = 0;
float threshold = 40;
int nthreshold = 15;
int ncap = 25;
int w = 640;
int h = 480;
int r = 100;
int oldx = w/2;
int oldy = h/2;
float[][] dist;

void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
  prev = createImage(640, 480, RGB);
}

void mousePressed() {
  /*int loc = mouseX + mouseY*video.width;
   track = video.pixels[loc];
   oldx = mouseX;
   oldy = mouseY;*/
  if (menu && mouseX< 420 && mouseX > 220 && mouseY < 450 && mouseY > 370) {
    menu = false;
  }
  track = 0;
  oldx = w/2;
  oldy = h/2;
}

void keyPressed() {
  print("key pressed");
  if (key == ' ') {
    int c_r=0;
    int c_g=0;
    int c_b=0;
    int count = 0;
    for (int i = -7; i < 8; i++) {
      for (int j = -7; j < 8; j++) {
        count++;
        c_r+=red(video.pixels[w/2+i+(h/2+j)*video.width]);
        c_g+=green(video.pixels[w/2+i+(h/2+j)*video.width]);
        c_b+=blue(video.pixels[w/2+i+(h/2+j)*video.width]);
      }
    }
    track = color(c_r/count, c_g/count, c_b/count);
    oldx = w/2;
    oldy = h/2;
  }
}

void captureEvent(Capture video) {
  prev.copy(video, 0, 0, video.width, video.height, 0, 0, prev.width, prev.height);
  prev.updatePixels();
  video.read();
}

void draw() {
  if (menu) {
    background (0);
    fill(random(255), random(255), random(255));
    stroke(255);
    strokeWeight(2);
    ellipse (oldx, oldy, 10, 10);
    textSize(30); 
    text("FUN WITH CV", 220, 100);
    textAlign(LEFT);
    button("Start", 220, 370, 200, 80, 30);
    return;
  }
    video.loadPixels();
    prev.loadPixels();
    image(video, 0, 0);
    dist = new float[w][h];
    noFill();
    rect(oldx-r, oldy-r, 2*r, 2*r);
    if (track != 0) {
      for (int y = oldy+r; y > oldy-r; y-- ) {
        for (int x = oldx-r; x < oldx+r; x++ ) {
          if (x>2 & y>2 & x<w-2 & y<h-2) {
            color current = video.pixels[x + y*video.width];
            float r = red(current);
            float g = green(current);
            float b = blue(current);
            dist[x][y] = distSq(r, g, b, red(track), green(track), blue(track));
            if (dist[x][y]<threshold * threshold) {
              if (sameNeighbors(x, y)>nthreshold & sameNeighbors(x, y)<ncap) {
                oldx = x;
                oldy = y;
              }
            }
          }
        }
      }
      fill(track);
    } else {
      fill(random(255), random(255), random(255));
    }
    stroke(255);
    strokeWeight(2);
    ellipse (oldx, oldy, 10, 10);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

int sameNeighbors(int x, int y) {
  if (x<2 || x>=w-1 || y<2 || x>= w-1) {
    return 0;
  }
  int count = 0;
  for (int i = -2; i < 3; i++) {
    for (int j = -2; j < 3; j++) {
      if (dist[x+i][y+j]<threshold * threshold) {
        count++;
      }
    }
  }
  return count;
}

void button(String text, int xcor, int ycor, int w, int h, int size) {
  fill(210, 255, 255, 80);
  strokeWeight(4);
  rect(xcor, ycor, w, h, 7);
  textSize(size);
  if (mouseX< xcor+w && mouseX > xcor && mouseY < ycor+h && mouseY > ycor) {
    fill(210, 255, 255);
    stroke(210, 255, 255);
  } else {
    fill(0);
    stroke(0);
  }
  text(text, (w-text.length()*size * .5)/2 + xcor, ((h+size)/2 + ycor));
}