
var sketch = function(p) {
    var table;
    var minLong, maxLong;
    var minLat, maxLat;

    p.preload = function() {
        table = p.loadTable("../data/uk24727_latlong.csv","csv","header")
    };

    p.setup = function() {
        p.createCanvas(600,700);
        p.noLoop();
        var rows = table.getRows();
        minLong=Number.POSITIVE_INFINITY;
        maxLong=Number.NEGATIVE_INFINITY;
        minLat=Number.POSITIVE_INFINITY;
        maxLat=Number.NEGATIVE_INFINITY;
        for (var r = 0; r < rows.length; r++) {
            var curLong = rows[r].getNum(1);
            var curLat = rows[r].getNum(0);
            if(curLong > maxLong)
                maxLong = curLong;
            if(curLong < minLong)
                minLong = curLong;
            if(curLat > maxLat)
                maxLat = curLat;
            if(curLat < minLat)
                minLat = curLat;
        }
        minLong-=1;
        maxLong+=1;
        minLat-=1;
        maxLat+=1;
        console.log("Longitude range: "+minLong+"<->"+maxLong);
        console.log("Latitude range: "+minLat+"<->"+maxLat);
    };

    p.draw = function() {
        p.background(0,0,0);
        p.noStroke();
        p.fill(0,255,0,100);
        var rows = table.getRows();
        for (var r = 0; r < rows.length; r++) {
            var from_long = rows[r].getNum(1);
            var from_lat = rows[r].getNum(0);
            var x = p.map(from_long,minLong,maxLong,0,p.width);
            var y = p.map(from_lat,minLat,maxLat,p.height,0);
            p.ellipse(x,y,3,3);
        }
    };
};
sketchInstance = new p5(sketch);