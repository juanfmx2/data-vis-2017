elastic_json_data = null
elastic_query_size = 100

class Target

  #---------------------------------------------------------------------------------------------------------------------
  # Class functions
  #---------------------------------------------------------------------------------------------------------------------

  @MOLECULE_KNOWN_IDS = {}

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

  @HSB_HUE = 160

  @CELL_SIZE = 5

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

  draw:(p, yPos, cellHeight, xStart)->
    molecules = _.keys(Target.MOLECULE_KNOWN_IDS)
    for molecule_id, index in molecules
      cellX = p.map(index,0,molecules.length-1,0,Target.CELL_SIZE*molecules.length)
      doc_count = if _.has(@molecule_counts,molecule_id) then @molecule_counts[molecule_id] else 0
      if doc_count != 0
        sat = p.floor(p.map(doc_count,0,15,5,100))%100
        val = 90
        p.colorMode(p.HSB)
        p.noStroke()
        p.fill(p.color(Target.HSB_HUE,sat,val))
        p.rect(cellX,yPos,Target.CELL_SIZE-1,Target.CELL_SIZE-1)


#-----------------------------------------------------------------------------------------------------------------------
# Sketcher
#-----------------------------------------------------------------------------------------------------------------------

ChEMBLSketch = (p)->
  console.log(elastic_json_data)
  plotSize = 800
  targets = null
  canvas = null

  p.preload = ->
    targets = Target.parseElasticJSON(elastic_json_data)

  p.setup = ->
    canvas = p.createCanvas(plotSize, plotSize)
    console.log(targets)
    p.noLoop()

  p.draw = ->
    p.background(0)
    p.fill(0,255,0)
    yPlotStart = 0
    yPlotEnd = p.height
    xPlotStart = 0
    xPlotEnd = p.width
    for target_i, index in targets
      yPos = p.map(index,0,targets.length-1,Target.CELL_SIZE*targets.length,yPlotStart)
      target_i.draw(p, yPos, Target.CELL_SIZE, xPlotStart)


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
