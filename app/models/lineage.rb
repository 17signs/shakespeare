class Lineage
  include MongoMapper::Document

  key :nodes
  key :edges
  timestamps!

  def add_edge(edge = nil)
    if edge
      unless edges.include?(edge.id)
        edges << edge.id
        nodes["#{edge.from_id}"]['displayed_weight_out'] = nodes["#{edge.from_id}"]['displayed_weight_out'] + 1 if nodes["#{edge.from_id}"]
        nodes["#{edge.to_id}"]['displayed_weight_in']    = nodes["#{edge.to_id}"]['displayed_weight_in'] + 1 if nodes["#{edge.to_id}"]
        save
      end
    end
  end

  def add_poem(poem = nil)
    if poem
      unless nodes.has_key?("#{poem.id}")
        # build lineage node
        new_node = Hash.new
        new_node['potential_weight_in']  = poem.links_to_predecessors.length
        new_node['potential_weight_out'] = poem.links_to_successors.length
        new_node['displayed_weight_in']  = 0
        new_node['displayed_weight_out'] = 0
        nodes["#{poem.id}"] = new_node
        save
      end
    end
  end

  def collapse_poem(poem=nil, dir=nil)
    if poem && dir
      case dir
        when 'in'
          poem.links_to_predecessors.each { |p| remove_edge(p, poem, 'in') }
        when'out'
          poem.links_to_successors.each { |s| remove_edge(s, poem, 'out') }
      end
    end
  end

  def expand_poem(poem=nil, dir=nil)
    if poem && dir
      case dir
        when 'in'
          poem.links_to_predecessors.each do |p|
            add_poem(p.from)
            add_edge(p)
          end
        when 'out'
          poem.links_to_successors.each do |s|
            add_poem(s.to)
            add_edge(s)
          end
      end
    end
  end

  def remove_edge(edge=nil, keep=nil, force=nil)
    if edge
      if edges.include?(edge.id)
        edges.delete(edge.id)
        nodes["#{edge.from_id}"]['displayed_weight_out'] = nodes["#{edge.from_id}"]['displayed_weight_out'] - 1 if nodes["#{edge.from_id}"]
        nodes["#{edge.to_id}"]['displayed_weight_in']    = nodes["#{edge.to_id}"]['displayed_weight_in'] - 1 if nodes["#{edge.to_id}"]
        save

        from_poem = edge.from
        unless from_poem == keep
          if force == 'in'
            nodes["#{from_poem.id}"]['displayed_weight_out'] = 0 if nodes["#{from_poem.id}"]
            nodes["#{from_poem.id}"]['displayed_weight_in']  = 0 if nodes["#{from_poem.id}"]
            save
          end
          display_weight = 0
          display_weight = nodes["#{from_poem.id}"]['displayed_weight_out'] + nodes["#{from_poem.id}"]['displayed_weight_in'] if nodes["#{from_poem.id}"]
          remove_poem(from_poem, keep) if display_weight == 0
        end
        to_poem   = edge.to
        unless to_poem == keep
          display_weight = 0
          display_weight = nodes["#{to_poem.id}"]['displayed_weight_out'] + nodes["#{to_poem.id}"]['displayed_weight_in'] if nodes["#{to_poem.id}"]
          remove_poem(to_poem, keep) if display_weight == 0
        end
      end
    end
  end

  def remove_poem(poem=nil, keep=nil)
    if poem
      if nodes.has_key?("#{poem.id}")
        unless poem == keep
          nodes.delete("#{poem.id}")
          save

          poem.links_to_predecessors.each { |p| remove_edge(p, keep) }
          poem.links_to_successors.each   { |s| remove_edge(s, keep) }
        end
      end
    end
  end

end