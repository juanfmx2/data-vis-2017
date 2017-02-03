elastic_json_data = null
elastic_query_size = 100

last_compound_id = null
last_target_id = null

loadCompoundCard = (chembl_id)->
  if last_compound_id != chembl_id
    html_card = '<div style="display: inline-block"><object id="compound_card" data="https://chembl-glados.herokuapp.com/compound_report_card/'+
      chembl_id+'/embed/name_and_classification/" width="360px" height="600px"></object></div>'
    $('#compound_card').remove()
    $('body').append(html_card)
    last_compound_id = chembl_id

loadTargetCard = (chembl_id)->
  if last_target_id != chembl_id
    html_card = '<div style="display: inline-block"><object id="target_card" data="https://chembl-glados.herokuapp.com/target_report_card/'+
      chembl_id+'/embed/name_and_classification/" width="360px" height="600px"></object></div>'
    $('#target_card ').remove()
    $('body').append(html_card)
    last_target_id = chembl_id

class Target

  #---------------------------------------------------------------------------------------------------------------------
  # Class functions
  #---------------------------------------------------------------------------------------------------------------------

  @geMoleculeCount: ->
    return _.keys(Target.MOLECULE_KNOWN_IDS).length

  @MOLECULE_KNOWN_IDS: {}

  @MAX_COUNT: Number.NEGATIVE_INFINITY

  @reduceData: (targets)->
    reduced_targets = []
    for molecule_id in _.keys(Target.MOLECULE_KNOWN_IDS)
      if Target.MOLECULE_KNOWN_IDS[molecule_id] <= elastic_query_size/10
        delete Target.MOLECULE_KNOWN_IDS[molecule_id]
        for target_i in targets
          delete target_i.molecule_counts[molecule_id]
    for target_i in targets
      for molecule_id_i in _.keys(target_i.molecule_counts)
        if target_i.molecule_counts[molecule_id_i] == 0
          delete target_i.molecule_counts[molecule_id_i]
      if  _.keys(target_i.molecule_counts).length > elastic_query_size/10
        reduced_targets.push(target_i)
    return reduced_targets

  @parseElasticJSON: (elasticJson)->
    targets = []
    for bucket_i in elasticJson.aggregations.group_by_target.buckets
      target_id_i = bucket_i.key
      target_i = new Target(target_id_i)
      targets.push(target_i)
      for bucket_j in bucket_i.group_by_compound.buckets
        target_i.addCompoundCount(bucket_j.key,bucket_j.doc_count)
    targets = Target.reduceData(targets)
    return targets

  @HSB_HUE: 160

  @CELL_SIZE: 10

  #---------------------------------------------------------------------------------------------------------------------
  # Instance functions
  #---------------------------------------------------------------------------------------------------------------------

  constructor: (target_id)->
    @target_id = target_id
    @molecule_counts = {}

  addCompoundCount: (molecule_id, doc_count)->
    @molecule_counts[molecule_id] = doc_count
    if not _.has(Target.MOLECULE_KNOWN_IDS,molecule_id)
      Target.MOLECULE_KNOWN_IDS[molecule_id] = 0
    Target.MOLECULE_KNOWN_IDS[molecule_id] += 1
    if doc_count > Target.MAX_COUNT
      Target.MAX_COUNT = doc_count

  getTargetMoleculeAndCount: (p,heatmapX, heatmapWidth, target_array_pos)->
    molecules = _.keys(Target.MOLECULE_KNOWN_IDS)
    arrayPos = p.floor(p.map(heatmapX,0,heatmapWidth,0,molecules.length))
    if arrayPos < 0 or arrayPos > molecules.length-1
      return null
    molecule_id = molecules[arrayPos]
    doc_count = if _.has(@molecule_counts,molecule_id) then @molecule_counts[molecule_id] else 0
    return {
      x_array_pos: arrayPos
      y_array_pos: target_array_pos
      target_chembl_id: @target_id
      molecule_chembl_id: molecule_id
      count: doc_count
    }

  draw:(p, yPos)->
    molecules = _.keys(Target.MOLECULE_KNOWN_IDS)
    for molecule_id, index in molecules
      cellX = p.map(index,0,molecules.length,0,molecules.length*Target.CELL_SIZE)
      doc_count = if _.has(@molecule_counts,molecule_id) then @molecule_counts[molecule_id] else 0
      if doc_count != 0
        sat = p.floor(p.map(doc_count,0,15,5,100))%100
        val = 90
        p.fill(p.color(Target.HSB_HUE,sat,val))
        p.rect(cellX+1,yPos+1,Target.CELL_SIZE-2,Target.CELL_SIZE-2)



#-----------------------------------------------------------------------------------------------------------------------
# Sketcher
#-----------------------------------------------------------------------------------------------------------------------

ChEMBLSketch = (p)->
  console.log(elastic_json_data)
  targets = null
  canvas = null
  heatmap = null
  heatmap_x_pos = 10
  heatmap_y_pos = 10
  current_hoover = null
  current_select = null

  drawSelectionHoovers = (xArrayPos,yArrayPos)->
    molecules = _.keys(Target.MOLECULE_KNOWN_IDS)
    xStart = p.map(xArrayPos,0,molecules.length,heatmap_x_pos,heatmap_x_pos+heatmap.width)
    yStart = p.map(yArrayPos,0,targets.length,heatmap_y_pos,heatmap_y_pos+heatmap.height)
    p.colorMode(p.RGB)
    p.strokeWeight(2)
    p.stroke(200,0,0)
    p.noFill()
    p.rect(xStart,heatmap_y_pos,Target.CELL_SIZE,heatmap.height)
    p.rect(heatmap_x_pos,yStart,heatmap.width,Target.CELL_SIZE)

  drawCurrentSelection = ()->
    molecules = _.keys(Target.MOLECULE_KNOWN_IDS)
    xStart = p.map(current_select.x_array_pos,0,molecules.length,heatmap_x_pos,heatmap_x_pos+heatmap.width)
    yStart = p.map(current_select.y_array_pos,0,targets.length,heatmap_y_pos,heatmap_y_pos+heatmap.height)
    p.colorMode(p.RGB)
    p.strokeWeight(4)
    p.stroke(100,0,200)
    p.noFill()
    p.rect(xStart,yStart,Target.CELL_SIZE,Target.CELL_SIZE,)

  getTargetCompound = ()->
    heatmapX = p.mouseX-heatmap_x_pos
    heatmapY = p.mouseY-heatmap_y_pos
    arrayPos = p.floor(p.map(heatmapY,0,heatmap.height,0,targets.length))
    if arrayPos < 0 or arrayPos > targets.length-1
      return null
    return targets[arrayPos].getTargetMoleculeAndCount(p,heatmapX,heatmap.width, arrayPos)

  drawHeatmap = ->
    heatmap = p.createGraphics(Target.geMoleculeCount()*Target.CELL_SIZE, targets.length*Target.CELL_SIZE);
    heatmap.colorMode(p.RGB)
    heatmap.background(30)
    heatmap.colorMode(p.HSB)
    heatmap.noStroke()
    for target_i, index in targets
      yPos = p.map(index,0,targets.length,0,targets.length*Target.CELL_SIZE)
      target_i.draw(heatmap, yPos)

  p.preload = ->
    targets = Target.parseElasticJSON(elastic_json_data)

  p.setup = ->
    drawHeatmap()
    plotW = heatmap.width+2*heatmap_x_pos
    plotH = heatmap.height+heatmap_y_pos+3*1.5*Target.CELL_SIZE
    canvas = p.createCanvas(plotW+2, plotH+2)
    console.log(targets)
    p.noLoop()

  p.draw = ->
    p.colorMode(p.RGB)
    p.background(255)
    p.image(heatmap,heatmap_x_pos,heatmap_y_pos)
    p.noFill()
    p.stroke(0)
    p.rect(1,1,p.width-2,p.height-2)
    if current_hoover
      drawSelectionHoovers(current_hoover.x_array_pos,current_hoover.y_array_pos)
      p.noStroke()
      p.textStyle(p.BOLD)
      p.textAlign(p.LEFT,p.TOP)
      p.textSize(1.5*Target.CELL_SIZE)
      p.fill(0)
      labels_y_pos = heatmap_y_pos+heatmap.height
      p.text("Target: "+current_hoover.target_chembl_id,heatmap_x_pos,labels_y_pos);
      labels_y_pos += 1.5*Target.CELL_SIZE
      p.text("Compound: "+current_hoover.molecule_chembl_id,heatmap_x_pos,labels_y_pos);
      labels_y_pos += 1.5*Target.CELL_SIZE
      p.text("Count: "+current_hoover.count,heatmap_x_pos,labels_y_pos);
    if current_select
      loadCompoundCard(current_select.molecule_chembl_id)
      loadTargetCard(current_select.target_chembl_id)
      drawCurrentSelection()
      p.noStroke()
      p.textStyle(p.BOLD)
      p.textAlign(p.RIGHT,p.TOP)
      p.textSize(1.5*Target.CELL_SIZE)
      p.fill(0)
      labels_y_pos = heatmap_y_pos+heatmap.height
      p.text("Selected Target: "+current_select.target_chembl_id,heatmap_x_pos+heatmap.width,labels_y_pos);
      labels_y_pos += 1.5*Target.CELL_SIZE
      p.text("Selected Compound: "+current_select.molecule_chembl_id,heatmap_x_pos+heatmap.width,labels_y_pos);
      labels_y_pos += 1.5*Target.CELL_SIZE
      p.text("Count: "+current_select.count,heatmap_x_pos+heatmap.width,labels_y_pos);

  p.mouseMoved = ->
    current_hoover = getTargetCompound()
    p.draw()

  p.mouseClicked = ->
    if p.mouseButton == p.LEFT
      current_select = current_hoover
      p.draw()




startSketch = (elastic_data) ->
  elastic_json_data = elastic_data
  sketch = new p5(ChEMBLSketch)

#-----------------------------------------------------------------------------------------------------------------------
# Elastic Search ajax loading
#-----------------------------------------------------------------------------------------------------------------------

elastic_query_url = "https://wwwdev.ebi.ac.uk/chembl/glados-es/chembl_activity/_search"
elastic_query_data = {
  aggs:
      group_by_target:
          terms:
              field: "target_chembl_id"
              size: elastic_query_size
          aggs:
              group_by_compound:
                  terms:
                      field: "molecule_chembl_id"
                      size: elastic_query_size
                  aggs:
                      activity_count:
                          value_count:
                              field: "activity_id"
}

loadElasticJSON = (url, data, success_callback)->
  $.ajax(
    elastic_query_url,
    {
      data: JSON.stringify(elastic_query_data)
      method: 'POST'
      success: success_callback
      error: (jqXHR, textStatus, errorThrown)->
        console.log(textStatus)
        console.log(errorThrown)
        alert("Error retrieving data!")
    }
  )
$(document).ready ->
  $(document).ajaxStart ->
    $('body').append("<div id='ajax_loading'>Loading data . . .</div>")
  $(document).ajaxStop ->
    $('#ajax_loading').remove()
  loadElasticJSON(elastic_query_url, elastic_query_data, startSketch)
