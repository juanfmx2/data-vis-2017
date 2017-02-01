
var sketch = function(p) {
    var data = {};
    var chromosomes = [];
    var chromosomes_by_key = {};

    Band = function (name, start, end){
        this.name = name;
        this.start = start;
        this.end = end;
        this.band_color = Band.getNextColor();
    };

    Band.getNextColor= function(){
        var nextColor = Band._COLORS_PALETTE[Band._CUR_COLOR];
        Band._CUR_COLOR++;
        Band._CUR_COLOR%=Band._COLORS_PALETTE.length;
        return nextColor;
    };

    Band._CUR_COLOR = 0

    Band._COLORS_PALETTE = [
        '#8dd3c7',
        '#ffffb3',
        '#bebada',
        '#fb8072',
        '#80b1d3',
        '#fdb462',
        '#b3de69',
        '#fccde5',
        '#d9d9d9',
        '#bc80bd'
    ];

    Band.prototype.draw = function(y,min_start,max_end){
        p.stroke(p.color(this.band_color));
        var xStart = p.map(this.start,min_start,max_end,0,p.width);
        var xEnd = p.map(this.end,min_start,max_end,0,p.width);
        p.line(xStart+1,y,xEnd-1,y)
    };

    Chromosome = function(name, start, end, index){
        this.name = name;
        this.start = start;
        this.end = end;
        this.index = index;
        if(this.start < Chromosome.MIN_START)
            Chromosome.MIN_START = this.start;
        if(this.end > Chromosome.MAX_END)
            Chromosome.MAX_END = this.end;
        this.bands = []
    };

    Chromosome.MIN_START = Number.POSITIVE_INFINITY;
    Chromosome.MAX_END = Number.NEGATIVE_INFINITY;

    Chromosome.HEIGHT = 30;
    Chromosome.H_GAP = 5;

    Chromosome.adjustBoundary = function(){
        var delta = Chromosome.MAX_END-Chromosome.MIN_START;
        Chromosome.MIN_START-= 0.1*delta;
        Chromosome.MAX_END+= 0.1*delta;
    };

    Chromosome.prototype.draw = function(){
        var y =  (Chromosome.HEIGHT+Chromosome.H_GAP)*(this.index+1);
        var xStart = p.map(this.start,Chromosome.MIN_START,Chromosome.MAX_END,0,p.width);
        var xEnd = p.map(this.end,Chromosome.MIN_START,Chromosome.MAX_END,0,p.width);
        p.strokeWeight(Chromosome.HEIGHT);
        p.stroke(50);
        p.strokeCap(p.ROUND);
        p.line(xStart,y,xEnd,y);
        // Draw bands
        p.strokeCap(p.SQUARE);
        for(var index in this.bands)
            this.bands[index].draw(y,Chromosome.MIN_START,Chromosome.MAX_END);
        // Draw the text
        p.fill(0);
        p.noStroke()
        p.textStyle(p.BOLD);
        p.textAlign(p.LEFT,p.CENTER);
        p.textSize(Chromosome.HEIGHT);
        p.text(this.name,xStart,y);
    };

    parseData = function(rowsData) {
        var chr_count = 0;
        for(var index in rowsData) {
            var line_i = rowsData[index].trim();
            var parts_i = line_i.split(" ");
            if(parts_i[0] === 'chr') {
                var chr = new Chromosome(parts_i[6],
                    p.int(parts_i[4]),
                    p.int(parts_i[5]),
                    chr_count
                );
                chr_count++;
                chromosomes.push(chr);
                chromosomes_by_key[parts_i[2]] = chr;
            }
            else if(parts_i[0] === 'band') {
                var chrForBand = chromosomes_by_key[parts_i[1]];
                chrForBand.bands.push(new Band(
                    parts_i[6],
                    p.int(parts_i[4]),
                    p.int(parts_i[5]))
                );
            }
        }
        Chromosome.adjustBoundary()
    };

    p.preload = function() {
        data = { };
        p.loadStrings("/data/karyotype.human.hg19.txt", parseData)
    };

    p.setup = function() {
        p.createCanvas(1000,(chromosomes.length+1)*(Chromosome.HEIGHT+Chromosome.H_GAP));
        p.noLoop();
        p.colorMode(p.RGB)
    };

    p.draw = function() {
        p.background(255);
        for(var index in chromosomes) {
            var chr_i = chromosomes[index]
            chr_i.draw()
        }
    };
};
sketchInstance = new p5(sketch);