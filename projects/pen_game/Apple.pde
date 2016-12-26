class Apple {
  float x, y, size, fa, fb, fc;
  boolean disp = true;

  Apple(float sizet) {
    size=sizet;
    x=random(size, width-size);
    y=-1*(random(1, 60)*height/15);
    fa=random(255);
    fb=random(255);
    fc=random(255);
  }


  void descend() {
    x=x+random(-2, 2);
    y=y+random(1, 3);
  }

  void display() {
    if (!disp) return;
    stroke(0);
    strokeWeight(4);
    fill(255,0,0);
    ellipse(x, y, size, size);
    fill(170, 70, 20);
    rect(x-5, y-size/2-10, 10, 20);
    fill(0, 255, 0);
    rect(x, y-size/2-10, 20, 10);
  }
}