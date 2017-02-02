var datapoints = [];
var pressingMouse = false;
var startSelectX, startSelectY, stopSelectX, stopSelectY;
var canvasSize = 500;

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
    // We draw each datapoint twice: once on the left (max x = width/2),
    // and once on the right (x + width/2)
    ellipse(x,y,5,5);
    ellipse(x+width/2, y, 5, 5);
  };
};

function setup() {
    createCanvas(canvasSize*2, canvasSize);
    for ( var i = 0; i < canvasSize; i++ ) {
      datapoints.push(new DataPoint(random(canvasSize), random(canvasSize)));
    }
    noStroke();
    noLoop();
}

function draw() {
    background(255);
    stroke(0);
    line(width/2, 0, width/2, height);
    noStroke();
    datapoints.forEach(function(d) {
      d.draw();
    });
}

function selectDataPointsRect(startX, startY, stopX, stopY, selectOut) {
  if(startX > canvasSize){
      startX -= canvasSize;
      stopX -= canvasSize;
  }
  var x1 = min(startX, stopX);
  var x2 = max(startX, stopX);
  var y1 = min(startY, stopY);
  var y2 = max(startY, stopY);
  datapoints.forEach(function(d) {
    var isIn = d.x >= x1 && d.x <= x2 && d.y >= y1 && d.y <= y2
    if ( (selectOut && !isIn) || (!selectOut && isIn)) {
      d.active = true;
    } else {
      d.active = false;
    }
  });
}

function selectDataPointsCirc(startX, startY, radius, selectOut) {
  if(startX > canvasSize){
      startX -= canvasSize;
  }
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

  radius = dist(startSelectX,startSelectY,stopSelectX,stopSelectY)
  if(keyIsDown(ALT))
    selectDataPointsCirc(startSelectX, startSelectY, radius, keyIsDown(SHIFT));
  else
    selectDataPointsRect(startSelectX, startSelectY, stopSelectX, stopSelectY, keyIsDown(SHIFT));
  redraw();
}