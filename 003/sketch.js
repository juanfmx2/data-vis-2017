var sketch = function(p) {
    var theta = 0;
    var xRect = 300, yRect = 300, sizeRect= 30;
    var xCirc = 100, yCirc = 100, sizeCirc= 60;

    isInsideRect = function(){
        return p.mouseX > xRect-sizeRect/2 && p.mouseX < xRect+sizeRect/2 &&
               p.mouseY > yRect-sizeRect/2 && p.mouseY < yRect+sizeRect/2
    };

    isInsideCirc = function(){
        return p.dist(p.mouseX,p.mouseY,xCirc-sizeCirc/2,yCirc-sizeCirc/2) < sizeCirc/2
    };

    p.setup = function() {
        var width = 500;
        var height = 500;
        var canvas = p.createCanvas(width, height);
        console.log(canvas);
        canvas.position(10,10);
        p.stroke(255, 100, 100)
    };

    p.draw = function() {
        p.background(0, 0, 0);
        var x = p.mouseX;
        var y = p.mouseY;
        var r = 30;
        p.noFill();
        p.rect(xRect-sizeRect/2, yRect-sizeRect/2, sizeRect, sizeRect);
        p.ellipse(xCirc-sizeCirc/2, yCirc-sizeCirc/2, sizeCirc, sizeCirc);
        p.ellipse(x, y, r * 2, r * 2);
        p.fill(0, 200, 0);
        if (isInsideRect()) {
            p.ellipse(x + r * Math.cos(-theta * (Math.PI / 180)),
                y + r * Math.sin(-theta * (Math.PI / 180)), 20, 20)
        }
        else if(isInsideCirc()){
            p.rect(x + r * Math.cos(theta * (Math.PI / 180)) - 10,
                y + r * Math.sin(theta * (Math.PI / 180)) - 10, 20, 20)
        }
        theta++;
        theta %= 360
    }
};
sketchInstance = new p5(sketch);