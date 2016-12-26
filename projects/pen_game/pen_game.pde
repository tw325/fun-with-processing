// captures live video using the camera and Processing's Video library
// USE A UNIFORM BACKGROUND IF POSSIBLE
// GET A STICK/PEN/PENCIL WHOSE COLOR IS NOT IN THE BACKGROUND
// PUT PEN IN FRAME AND CLICK ON PEN TO TAG PEN
// SMOOTHLY MOVE THE OBJECT AND SEE IT TRACED!
// tip: make sure pen is never at less than 0 or greater than 180 degrees.

import processing.video.*;
import java.io.*;
import java.util.*;
import gab.opencv.*;
import java.awt.Rectangle;

//program time
int m = millis();

//menu
boolean menu = true;

//picture
boolean picture = false;

// apple game
int numApples = 20;
Apple[] Apples = new Apple[numApples];
boolean apple = false;

//drawing game
boolean draw = false;

boolean game = false;
Capture video;
PImage prev;
PImage vidMirror;
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
ArrayList<PVector> points;

//face detection
OpenCV opencv;
Rectangle[] faces;

void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
  prev = createImage(640, 480, RGB);
  vidMirror = new PImage(video.width, video.height);
  points = new ArrayList<PVector>();
  for (int i=0; i<Apples.length; i++) {
    Apples[i] = new Apple(40+random(0, 60));
  }
}

void mousePressed() {
  /*int loc = mouseX + mouseY*video.width;
   track = video.pixels[loc];
   oldx = mouseX;
   oldy = mouseY;*/
  if (menu && mouseX< 420 && mouseX > 220 && mouseY < 450 && mouseY > 370) {
    menu = false;
    picture = true;
    return;
  }
  if (apple){
    for (int i=0; i<Apples.length; i++) {
      Apples[i] = new Apple(40+random(0, 60));
    }
  }
  points = new ArrayList<PVector>();
  track = 0;
  oldx = w/2;
  oldy = h/2;
}

void keyPressed() {
  if (key != ' ') return;
  if (game) {
    int c_r=0;
    int c_g=0;
    int c_b=0;
    int count = 0;
    for (int i = -6; i < 7; i++) {
      for (int j = -6; j < 7; j++) {
        count++;
        c_r+=red(vidMirror.pixels[w/2+i+(h/2+j)*vidMirror.width]);
        c_g+=green(vidMirror.pixels[w/2+i+(h/2+j)*vidMirror.width]);
        c_b+=blue(vidMirror.pixels[w/2+i+(h/2+j)*vidMirror.width]);
      }
    }
    track = color(c_r/count, c_g/count, c_b/count);
    oldx = w/2;
    oldy = h/2;
  }
  if (picture) {
    save(year()+"-"+month()+"-"+day()+"_"+hour()+"h"+minute()+"m"+second()+"s.jpg");
    picture = false;
    game = true;
    apple = true;
    m = millis();
    while (millis()<m+1000) {
      stroke(0);
      fill(0);
      ellipse(w/2, h/2, millis()-m, millis()-m);
    }
  }
}

void captureEvent(Capture video) {
  prev.copy(vidMirror, 0, 0, vidMirror.width, vidMirror.height, 0, 0, prev.width, prev.height);
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
    textSize(20);
    text("by Tyler Wang", 250, 140);
    textAlign(LEFT);
    button("Start", 220, 370, 200, 80, 30);
    return;
  }
  video.loadPixels();
  for (int x = 0; x < video.width; x++) {
    for (int y = 0; y < video.height; y++) {
      vidMirror.pixels[x+y*video.width] = video.pixels[(video.width-(x+1))+y*video.width];
    }
  }
  vidMirror.updatePixels();
  
  //takes photo
  if (picture) {
    /*opencv = new OpenCV(this, vidMirror);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
    faces = opencv.detect();
    image(opencv.getInput(), 0, 0);

    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    for (int i = 0; i < faces.length; i++) {
      rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    }*/
    image(vidMirror, 0, 0);
    return;
  }
  
  //game mode on
  if (game) {
    prev.loadPixels();
    image(vidMirror, 0, 0);
    dist = new float[w][h];
    if (track != 0) {
      
      //tracks motion within square box
      for (int y = oldy+r; y > oldy-r; y-- ) {
        for (int x = oldx-r; x < oldx+r; x++ ) {
          if (x>2 & y>2 & x<w-2 & y<h-2) {
            color current = vidMirror.pixels[x + y*vidMirror.width];
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
      
      //apple game
      if (apple){
        int collectedapples=0;
        for (int i=0; i<Apples.length; i++) {
          Apple a = Apples[i];
          if (a.disp == false){
            collectedapples++;
          } else{
            a.descend();
            //apple touches ground
            if (a.y>h-a.size/2){
              apple = false;
              draw = true;
              points = new ArrayList<PVector>();
            }
            if (distSq(oldx, oldy, 0, a.x, a.y, 0)<a.size*a.size/4){
              println ("false");
              a.disp = false;
            }
            a.display();
          }
        }
        if (collectedapples >=15) {
          apple = false;
          draw = true;
          points = new ArrayList<PVector>();
        }
      }
      
      points.add(new PVector(oldx, oldy));
      fill(track);
    } 
    
    else {
      noFill();
      rect(oldx-r, oldy-r, 2*r, 2*r);
      fill(random(255), random(255), random(255));
      textSize(18); 
      text("PLACE YOUR\nCOLOR WAND\n\n\nON THE ORB\nPRESS SPACE", 320, 180);
      textAlign(CENTER);
    }
    
    stroke(255);
    strokeWeight(2);
    ellipse (oldx, oldy, 10, 10);
    if (draw & !picture & !apple){
      noFill();
      rect(oldx-r, oldy-r, 2*r, 2*r);
      for (PVector p : points) {
        fill(0);
        ellipse (p.x, p.y, 10, 10);
      }
    }
  }
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