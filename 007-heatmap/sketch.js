var data;
var heatmap, heatmap_width, heatmap_height;
var left_margin, top_margin, tile_size;
//61 colours
var col_array = ["#67001F", "#730421", "#800823", "#8C0C25", "#991027", "#A51329",
    "#B2182B", "#B82430", "#BE2F36", "#C33B3C", "#CA4741", "#D05347",
    "#D6604D", "#DB6B55", "#E0765E", "#E58267", "#EA8D70", "#EF9979",
    "#F3A481", "#F5AD8D", "#F7B698", "#F8BFA4", "#FAC8AF", "#FBD1BB",
    "#FDDBC7", "#FCDFCF", "#FBE4D7", "#FAE9DF", "#F9EDE7", "#F8F2EF",
    "#F7F7F7", "#F0F4F5", "#EAF1F4", "#E3EEF3", "#DDEBF2", "#D7E8F1",
    "#D1E5F0", "#C6DFED", "#BCDAEA", "#B1D5E7", "#A7CFE4", "#9CCAE1",
    "#92C5DE", "#84BCD9", "#77B4D5", "#6AACD0", "#5DA3CC", "#509BC7",
    "#4393C3", "#3D8BBF", "#3783BB", "#327CB7", "#2C75B3", "#266DAF",
    "#2166AC", "#1C5D9F", "#175493", "#134B86", "#0E427A", "#09396D",
    "#053061"
];
function preload() {
    data = loadTable("../data/sorted_sample_matrix.csv", "csv", "header");
}
function setup() {
    var row_count = data.rows.length;
    var col_count = data.columns.length;
    console.log("row:" + row_count + " col:" + col_count);
    tile_size = 5;
    heatmap_width = (col_count - 1) * tile_size;
    heatmap_height = row_count * tile_size;
    top_margin = 20;
    left_margin = 20;
    var canvas = createCanvas(heatmap_width + left_margin, heatmap_height + top_margin);
    // console.log(data.columns);
    console.log(heatmap_width + " " + heatmap_height);
    heatmap = createGraphics(heatmap_width, heatmap_height);
    // heatmap = createCanvas(heatmap_width + left_margin, heatmap_height + top_margin);
    heatmap.background(120);
    // heatmap.background(255, 0, 0);
    //draw heatmap
    var i, j;
    for (i = 0; i < row_count; i++) {
        for (j = 1; j < col_count; j++) {
            var value = data.getNum(i, j);
            var mapped_col_index = floor(map(value, -4.5, 4.5, 0, 60));
            var mapped_col = col_array[mapped_col_index];
            var dx = (j - 1) * tile_size;
            var dy = i * tile_size;
            heatmap.noStroke();
            heatmap.fill(mapped_col);
            heatmap.rect(dx, dy, tile_size, tile_size);
        }
    }
    // console.log(width, height);
    noLoop();
    // background(255);
    // image(heatmap, left_margin, top_margin);
}
function draw() {
    image(heatmap, left_margin, top_margin);
    // image(heatmap, 0, 0);
}
function mouseMoved() {
    //mouse position
    var x_index = floor(map(mouseX, left_margin, left_margin + heatmap_width, 0, (data.columns.length - 2)));
    var y_index = floor(map(mouseY, top_margin, top_margin + heatmap_height, 0, (data.rows.length - 1)));
    //constrain
    x_index = constrain(x_index, 0, (data.columns.length - 2));
    y_index = constrain(y_index, 0, (data.rows.length - 1));
    //position
    var dx = tile_size * x_index + left_margin;
    var dy = tile_size * y_index + top_margin;
    // console.log(x_index + ", " + y_index);
    image(heatmap, left_margin, top_margin);
    // image(heatmap, 0, 0);
    // draw text informaion
    var row_name = data.getString(y_index, 0);
    var col_name = data.columns[(x_index + 1)];
    var value = data.getNum(y_index, (x_index + 1));
    var display_text = row_name + "\n" + col_name + "\n" + value;
    //draw text background
    fill(255, 200);
    noStroke();
    rect(dx + tile_size, dy, 200, 60);
    textAlign(LEFT, TOP);
    noStroke();
    fill(0);
    text(display_text, dx + tile_size * 2, dy);
    // console.log(row_name + " " + col_name);
    //draw outline
    noFill();
    stroke(0);
    rect(dx, dy, tile_size, tile_size);
    rect(left_margin, dy, dx-left_margin, tile_size)
    rect(dx, top_margin, tile_size, dy-top_margin)
    if ((mouseX > left_margin) && (mouseX < left_margin + heatmap_width) &&
        (mouseY > top_margin) && (mouseY < top_margin + heatmap_height)) {
        noCursor();
    } else {
        cursor(ARROW);
    }
}