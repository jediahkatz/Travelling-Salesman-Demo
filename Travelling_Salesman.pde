void setup() {
  size(500, 500);
  textFont(createFont("Helvetica", 12));
  fill(0);
  strokeWeight(10);
  textAlign(CENTER);
  noLoop();
  ArrayList<Point> points = new ArrayList<Point>();
  boolean addingPoints = true;
  char nextPoint = 'A'-1;
  Route dRoute;
  Route bRoute;
  Slider slider = new Slider(440, 34);
  boolean dragging = false;
  String permutations = "";
  String time = "";
}

//starts from first Point in array
Route findBestRoute(Point[] p) {
  Point[] points = new Point[p.length-1];
  for (int i=0; i<points.length; i++) {
    points[i] = p[i+1];
  }

  Route best = null;                 
  while (true) {
    Point[] route = nextPermutation(points);
    if (route == null) break; //no more permutations
    Route r = new Route(route);
    r.addFirstAndLast(p[0]);
    dRoute = r;
    redraw();
    int millis = millis();
    while (millis > millis() - slider.getDelay()) {
    }
    if (best == null || r.compareTo(best) < 0) {
      best = bRoute = r;
    }
  }
  return best;
}

void draw() {
  background(0, 200, 120);
  pushStyle();
  fill(255);
  noStroke();
  rect(0, 50, 500, 450);
  rect(10, 10, 90, 30);
  fill(0, 200, 120);
  textSize(18);
  text("Calculate", 55, 32);
  textSize(16);
  fill(255);
  text("Delay: " + slider.getDelay() + " ms", 440, 22);
  popStyle();
  slider.display();
  if (bRoute != null) {
    dRoute.display(bRoute.dist);
  } else {
    pushStyle();
    textSize(14);
    fill(255);
    textAlign(LEFT);
    text("Distance: ", 110, 21);
    text("Minumum: ", 110, 38);
    popStyle();
  }
  pushStyle();
  textSize(14);
  fill(255);
  textAlign(LEFT);
  text("Permutations: " + permutations, 220, 21);
  text("Time Estimate: " + time, 220, 38);
  popStyle();
  for (Point p : points) {
    p.display();
    text(p.toString(), p.x, p.y-10);
  }
}

void mousePressed() {
  if (addingPoints && mouseY > 72 && points.size() < 27) {
    if (nextPoint > '@') {
      points.add(new Point(mouseX, mouseY, str(nextPoint++)));
      float f = factorial(points.size()-1) - 1;
      if (f > 1000000) {
        permutations = round4(f);
      } else {
        String fstr = str(f);
        permutations = fstr.substring(0, fstr.length()-2);
      }
      time = convertTime(f/300000);
    } else {
      points.add(new Point(mouseX, mouseY, "START"));
      nextPoint++;
    }
    redraw();
  } else if (points.size() > 3 && mouseX>10 && mouseX<110 && mouseY>10 && mouseY<40) {
    addingPoints=false;
    thread("TSP");
  } else if (dist(mouseX, mouseY, slider.sx, 34) <= 6.5) {
    dragging=true;
  }
}

void mouseDragged() {
  if (dragging) {
    slider.setPos(constrain(round(map(mouseX-(slider.x-50), 0, 100, 0, 31)), 0, 31));
    if (permutations != "") {
      time = convertTime(Double.valueOf(permutations)/300000);
    }
  }
}

void mouseReleased() {
  if (dragging) {
    dragging=false;
  }
}

void TSP() {
  Route best = findBestRoute(points.toArray(new Point[0]));
  println(best);
  dRoute = best;
  redraw();
}

Point[] nextPermutation(Point[] c) {
  int first = getFirst(c);
  if (first == -1) return null;

  int toSwap = c.length-1;
  while ( c[first].compareTo (c[toSwap]) >= 0) {
    toSwap--;
  }
  swap(c, first++, toSwap);
  toSwap = c.length-1;
  while (first < toSwap) {
    swap(c, first++, toSwap--);
  }
  return c;
}

//finds the largest k such that c[k] < c[k+1]
//if there is not a greater permutation return -1
int getFirst(Point[] c) {
  for (int i=c.length-2; i>=0; i--) {
    if (c[i].compareTo(c[i+1]) < 0) {
      return i;
    }
  }
  return -1;
}

//Swap i and j of type Point in an array using polymorphism
void swap(Point[] c, int i, int j) {
  Point temp = c[i];
  c[i] = c[j];
  c[j] = temp;
}

class Route {
  Point[] order;
  int dist;
  String name;

  Route(Point[] order) {
    this.order = order;
    calcDist();
    calcName();
  }

  String toString() {
    return name;
  }

  //Draw a line between the points
  void display(int best) {
    pushStyle();
    textSize(14);
    strokeWeight(2);
    stroke(0, 200, 120);
    for (int i=1; i<order.length-1; i++) {
      Point p1 = order[i];
      Point p2 = order[i-1];
      line(p1.x, p1.y, p2.x, p2.y);
    }
    fill(255);
    textAlign(LEFT);
    text("Distance: " + dist, 110, 21);
    text("Minumum: " + best, 110, 38);
    popStyle();
  }

  //appends Point p to front and end of array
  void addFirstAndLast(Point p) {
    Point[] newOrder = new Point[order.length+2];
    newOrder[0] = p;
    newOrder[newOrder.length-1] = p;
    for (int i=1; i<newOrder.length-1; i++) {
      newOrder[i] = order[i-1];
    }
    order = newOrder;
    calcDist();
    calcName();
  }

  void calcDist() {
    dist = 0;
    for (int i=1; i<order.length; i++) {
      dist += dist(order[i-1].x, order[i-1].y, order[i].x, order[i].y);
    }
  }

  void calcName() {
    name = "";
    for (int i=0; i<order.length; i++) {
      name += order[i].toString();
      if (i != order.length-1) {
        name += " ";
      }
    }
  }

  //compares distances
  int compareTo(Route r) {
    if (dist == r.dist) return 0;
    else if (dist > r.dist) return 1;
    return -1;
  }
}

class Point {
  int x, y;
  String name;

  Point(int x, int y, String name) {
    this.x=x;
    this.y=y;
    this.name = name;
  }

  void display() {
    point(x, y);
  }

  String toString() {
    return name;
  }

  boolean equals(Point p) {
    if (this.x == p.x && this.y == p.y && this.name.equals(p.name)) return true;
    return false;
  }

  int compareTo(Point p) { //compares names by alphabetical order
    return name.compareTo(p.name);
  }
}

class Slider {
  int x, y, pos;
  float sx;

  Slider(int x, int y) {
    this.x = x; 
    this.y = y;
    pos = 11;
  }

  void setPos(int pos) {
    this.pos=pos;
    redraw();
  }

  int getDelay() {
    if (pos > 0 && pos <= 11) return 50*(pos-1);
    else if (pos > 10 && pos <= 31) return 100*(pos-6);
    return 0;
  }

  void display() {
    pushStyle();
    strokeWeight(3);
    stroke(255);
    line(x-50, y, x+50, y);
    fill(0, 200, 120);
    sx = lerp(x-50, x+50, pos/31.0);
    ellipse(sx, y, 10, 10);
    popStyle();
  }
}

float factorial(int n) {
  if (n<=1) return 1;
  return n*factorial(n-1);
}

import java.math.BigDecimal;
import java.text.DecimalFormat;

String round4(double value) {
  BigDecimal bd = new BigDecimal(value);
  DecimalFormat format = new DecimalFormat("0.##E0");
  return format.format(bd);
}

String convertTime(double sec) {
  //MIS_PER_MS = 1000;
  //MS_PER_SEC = 1000;
  //SEC_PER_MIN = 60;
  //MIN_PER_HR = 60;
  //HR_PER_DAY = 24;
  //DAY_PER_YR = 365;

  sec += (Double.valueOf(permutations) * slider.getDelay())/1000;

  if (sec < 1/1000.0) {
    return Math.round(sec*1000000) + "\u03BC" + "s"; //microsec
  } else if (sec >= 1/1000.0 && sec < 1) {
    return Math.round(sec*1000) + "ms"; //millisec
  } else if (sec >= 1 && sec < 120) {
    return Math.round(sec) + "s"; //sec
  } else if (sec >= 120 && sec < 7200) {
    return Math.round(sec/60) + "min"; //min
  } else if (sec >= 7200 && sec < 172800) {
    return Math.round(sec/3600) + "hr"; //hours
  } else if (sec >= 172800 && sec < 31536000) {
    return Math.round(sec/86400) + "d"; //days
  }

  //years
  double yr = sec/31536000;
  if (yr > 1000000) {
    return round4(yr) + "yr";
  }
  return Math.round(yr) + "yr";
}