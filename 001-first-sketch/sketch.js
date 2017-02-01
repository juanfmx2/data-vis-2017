var r=50, tetha=0
function setup() {
    createCanvas(500,500)
    background(0)
    colorMode(HSB);
}

function draw() {
    background(0)
    tetha++
    colorMode(HSB);
    fill(100,50,50)
    ellipse(250+r*Math.cos(tetha*(Math.PI / 180)),250+r*Math.sin(tetha*(Math.PI / 180)),15,15)
    ellipse(250+r*Math.cos(-tetha*(Math.PI / 180)),250+r*Math.sin(-tetha*(Math.PI / 180)),15,15)
    tetha%=360
}