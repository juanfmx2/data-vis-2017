elastic_json_data = null
col_array = [
    "#F7F7F7", "#EAF1F4", "#DDEBF2",
    "#D1E5F0", "#BCDAEA", "#A7CFE4",
    "#92C5DE", "#77B4D5", "#5DA3CC",
    "#4393C3", "#3783BB", "#2C75B3",
    "#2166AC", "#175493", "#0E427A",
    "#053061"
];
class Target

  @MOLECULE_KNOWN_IDS = {}

  @MAX_COUNT: Number.NEGATIVE_INFINITY

  @reduceKnownMolecules: ->
    for molecule_id in _.keys(Target.MOLECULE_KNOWN_IDS)
      if Target.MOLECULE_KNOWN_IDS[molecule_id] <= 100/10
        delete Target.MOLECULE_KNOWN_IDS[molecule_id]


  @parseElasticJSON: (elasticJson)->
    targets = []
    for bucket_i in elasticJson.aggregations.group_by_target.buckets
      target_id_i = bucket_i.key
      target_i = new Target(target_id_i)
      targets.push(target_i)
      for bucket_j in bucket_i.group_by_compound.buckets
        target_i.addCompoundCount(bucket_j.key,bucket_j.doc_count)
    Target.reduceKnownMolecules()
    return targets

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

  draw:(p, yPos, cellHeight, xStart, xEnd)->
    molecules = _.keys(Target.MOLECULE_KNOWN_IDS)
    cellWidht = p.map(1,0, molecules.length-1, xStart, xEnd)
    for molecule_id, index in molecules
      cellX = p.map(index,0, molecules.length-1, xStart, xEnd)
      doc_count = if _.has(@molecule_counts,molecule_id) then @molecule_counts[molecule_id] else 0
      col_index = p.floor(p.map(doc_count,0,15,0,15))%15
      p.fill(col_array[col_index])
      p.rect(cellX+1,yPos+1,cellWidht-2,cellHeight-2)


ChEMBLSketch = (p)->
  console.log(elastic_json_data)
  plotSize = 700
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
    cellHeight = p.map(1,0, targets.length-1, yPlotStart, yPlotEnd)
    for target_i, index in targets
      yPos = p.map(index,0, targets.length-1, yPlotEnd, yPlotStart)
      target_i.draw(p, yPos, cellHeight, xPlotStart, xPlotEnd)


startSketch = (elastic_data) ->
  elastic_json_data = elastic_data
  sketch = new p5(ChEMBLSketch)


elastic_query_url = "https://wwwdev.ebi.ac.uk/chembl/glados-es/chembl_activity/_search"
elastic_query_data = {
  aggs:
      group_by_target:
          terms:
              field: "target_chembl_id"
              size: 100
          aggs:
              group_by_compound:
                  terms:
                      field: "molecule_chembl_id"
                      size: 100
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

loadElasticJSON(elastic_query_url, elastic_query_data, startSketch)
