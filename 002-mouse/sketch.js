var r=50, tetha=0
function setup() {
    createCanvas(500,500)
    background(0)
    colorMode(HSB);
    stroke(255,100,100)
}

function draw() {
    background(0)
    fill(0)
    ellipse(mouseX,mouseY,r*2,r*2)
    if(mouseIsPressed) {
        fill(100, 50, 50)
        tetha += 2
    }
    else{
        fill(200,50,50)
        tetha++
    }
    rect(mouseX+r*Math.cos(tetha*(Math.PI / 180))-10,mouseY+r*Math.sin(tetha*(Math.PI / 180))-10,20,20)
    ellipse(mouseX+r*Math.cos(-tetha*(Math.PI / 180)),mouseY+r*Math.sin(-tetha*(Math.PI / 180)),20,20)
    tetha%=360
}