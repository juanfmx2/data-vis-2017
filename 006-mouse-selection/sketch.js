var datapoints = [];
var pressingMouse = false;
var startSelectX, startSelectY, stopSelectX, stopSelectY;

var DataPoint = function(x,y) {
  this.x = x;
  this.y = y;
  this.active = false;
  this.draw = function() {
    if (this.active) {
      fill(255,0,0);
    } else {
      fill(0,0,255);
    }
    ellipse(x,y,5,5);
  };
};

function setup() {
    createCanvas(500, 500);
    for ( var i = 0; i < 500; i++ ) {
      datapoints.push(new DataPoint(random(width), random(height)));
    }
    noStroke();
    noLoop();
}

function draw() {
    background(255);
    datapoints.forEach(function(d) {
      d.draw();
    });
}

function selectDataPointsRect(startX, startY, stopX, stopY, selectOut) {
  datapoints.forEach(function(d) {
    var isIn = d.x >= startX && d.x <= stopX && d.y >= startY && d.y <= stopY
    if ( (selectOut && !isIn) || (!selectOut && isIn)) {
      d.active = true;
    } else {
      d.active = false;
    }
  });
}

function selectDataPointsCirc(startX, startY, radius, selectOut) {
  datapoints.forEach(function(d) {
    var isIn = dist(startX,startY,d.x,d.y) <= radius;
    if ( (selectOut && !isIn) || (!selectOut && isIn)) {
      d.active = true;
    } else {
      d.active = false;
    }
  });
}


function mousePressed() {
  startSelectX = mouseX;
  startSelectY = mouseY;
}

function mouseDragged() {
  redraw();
  fill(0,0,0,50);
  if(keyIsDown(ALT)) {
    radius = dist(startSelectX,startSelectY,mouseX,mouseY)
    ellipse(startSelectX, startSelectY,radius*2,radius*2)
  }
  else
    rect(startSelectX, startSelectY, mouseX-startSelectX, mouseY-startSelectY);
}

function mouseReleased() {
  stopSelectX = mouseX;
  stopSelectY = mouseY;

  startX = min(startSelectX, stopSelectX);
  stopX = max(startSelectX, stopSelectX);
  startY = min(startSelectY, stopSelectY);
  stopY = max(startSelectY, stopSelectY);

  radius = dist(startX,startY,stopX,stopY)
  if(keyIsDown(ALT))
    selectDataPointsCirc(startX, startY, radius, keyIsDown(SHIFT));
  else
    selectDataPointsRect(startX, startY, stopX, stopY, keyIsDown(SHIFT));
  redraw();
}