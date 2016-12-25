// captures live video using the camera and Processing's Video library
// threshold and nthreshold determine exactness of rectangle
// CLICK ON A PIXEL, AND SEE A QUANDRANGLE FORMED BY PIXELS OF SIMILAR COLOR
import processing.video.*;

Capture video;

color track;
float threshold = 20;
int nthreshold = 10;
int w = 640;
int h = 480;
float[][] dist;

void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
}

void mousePressed() {
  int loc = mouseX + mouseY*video.width;
  track = video.pixels[loc];
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  video.loadPixels();
  image(video, 0, 0);
  dist = new float[w][h];
  int lowXx = w + 50;
  int lowXy = -50;

  int lowYx = -50;
  int lowYy = h + 50;

  int highXx = -50;
  int highXy = -50;

  int highYx = -50;
  int highYy = -50;

  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      color current = video.pixels[x + y*video.width];
      float r = red(current);
      float g = green(current);
      float b = blue(current);
      dist[x][y] = distSq(r, g, b, red(track), green(track), blue(track));
    }
  }
  for (int x = 2; x < w-2; x++) {
    for (int y = 2; y < h-2; y++) {
      if (dist[x][y]<threshold * threshold) {
        if (x<lowXx & sameNeighbors(x, y)>nthreshold) {
          lowXx = x;
          lowXy = y;
        } else if (y<lowYy & sameNeighbors(x, y)>nthreshold) {
          lowYx = x;
          lowYy = y;
        } else if (x>highXx & sameNeighbors(x, y)>nthreshold) {
          highXx = x;
          highXy = y;
        } else if (y>highYy & sameNeighbors(x, y)>nthreshold) {
          highYx = x;
          highYy = y;
        }
      }
    }
  }
  stroke(255);
  strokeWeight(1);
  fill(255);
  strokeWeight(4.0);
  stroke(0);
  ellipse (highXx, highXy, 24, 24);
  ellipse (lowXx, lowXy, 24, 24);
  ellipse (highYx, highYy, 24, 24);
  ellipse (lowYx, lowYy, 24, 24);
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