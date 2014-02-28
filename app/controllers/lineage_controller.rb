class LineageController < ApplicationController

  @lineage = nil

  def index
    # get session lineage
    @lineage = current_lineage

    # general behaviour:
    # 1) collect data
    # 2) convert for SVG rendering

    # Step 1: Collect lineage data, which is nodes and edges
    # Alternative A) poem passed, but no action => initial lineage for that poem
    # Alternative B) poem passed and action => expand/collapse existing lineage
    # Alternative C) no poem passed and empty lineage => initial lineage for root poems

    if params['poem_id']

      poem_id = params['poem_id']
      poem    = Poem.find_by_id(poem_id)

      case params['do']
        when 'collapse'
          @lineage.collapse_poem(poem, params['dir'])
        when 'expand'
          @lineage.expand_poem(poem, params['dir'])
        else
          # --> initial lineage for selected poem
          # 1) reset existing lineage
          @lineage.nodes = Hash.new
          @lineage.edges = []
          # 2) add poem itself
          @lineage.add_poem(poem)
          # 3) add relations
          poem.links_to_predecessors.each do |p|
            @lineage.add_poem(p.from)
            @lineage.add_edge(p)
          end
          poem.links_to_successors.each do |s|
            @lineage.add_poem(s.to)
            @lineage.add_edge(s)
          end
      end

    else
      if @lineage.nodes == {} || params['do'] == 'reset'
        # Alternative C) no poem passed and empty lineage
        @lineage.nodes = Hash.new
        @lineage.edges = []
        Poem.root_poems.each { |poem| @lineage.add_poem(poem) }
      end
    end

    #puts "nodes db #{lineage.nodes}"
    #puts "edges db #{lineage.edges}"

    # Step 2: Convert lineage data to be rendered into SVG graphic

    nodes = []
    edges = []

    @lineage.nodes.each do |poem_id, node|
      svg_node         = Hash.new
      svg_node['poem'] = Poem.find_by_id(poem_id)
      if node['potential_weight_in'] == 0
        svg_node['in'] = 'missing'
      else
        if node['displayed_weight_in'] == 0
          svg_node['in'] = 'closed'
        else
          svg_node['in'] = 'open' if node['potential_weight_in'] == node['displayed_weight_in']
          svg_node['in'] = 'more' if node['potential_weight_in'] >  node['displayed_weight_in']
        end
      end
      if node['potential_weight_out'] == 0
        svg_node['out'] = 'missing'
      else
        if node['displayed_weight_out'] == 0
          svg_node['out'] = 'closed'
        else
          svg_node['out'] = 'open' if node['potential_weight_out'] == node['displayed_weight_out']
          svg_node['out'] = 'more' if node['potential_weight_out'] >  node['displayed_weight_out']
        end
      end
      nodes << svg_node
    end

    @lineage.edges.each do |edge|
      svg_edge = Relation.find_by_id(edge)
      edges << svg_edge
    end

    #puts "nodes svg #{nodes}"
    #puts "edges svg #{edges}"

    @result          = Hash.new
    @result['nodes'] = nodes
    @result['edges'] = edges
  end

end
