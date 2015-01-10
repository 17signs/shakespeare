# app/helpers/finder_helper.rb
module FinderHelper
  def finder

# r = return string containing html representation of repository
# a = array holding all coverred poems

    r = ""
    a = []

    r = r + "<section id='poem-workspace' class='finder'>"
    Poem.root_poems.each do |p|
      sub, suba = add_poem(p, a)
      r = r + sub
      a.concat(suba)
    end
    r = r + "</section>"

    r = r + "<section id='meta-poem-workspace' class='finder'>"
    r = r + "<div><h3>" + I18n.t('.meta_poem_workspace') + "</h3></div>"
    Poem.root_meta_poems.each do |p|
      sub, suba = add_poem(p, a)
      r = r + sub
      a.concat(suba)
    end
    r = r + "</section>"

    r.html_safe
  end

  def add_poem(poem=nil, hist)
    r = ""
    if poem
      r = r + "<div>"
      hist << poem.id

      sub_r    = ""
      poem.links_to_successors.each do |l|
        if l.relation_type == "1"
          if hist.include?(l.to_id)
            sub_r = sub_r + "loop at: " + get_anchor(poem)
          else
            ap_r, ap_hist = add_poem(l.to, hist)
            sub_r = sub_r + ap_r
            hist.concat(ap_hist)
          end
        end
      end

      # in case of relevant successor links sub_r contains those html rendering
      # if there are no such links the poem itself is displayed as simple link
      if sub_r.length > 0
        r = r + "<input id='" + poem.id + "' type='checkbox' />"
        r = r + "<label for='" + poem.id + "'><em>" + poem.to_s + "/</em></label>"
        r = r + "<article>"
        r = r + sub_r
        r = r + "</article>"
      else
        r = r + get_anchor(poem)
      end

      r = r + "</div>"
    end
    return r, hist
  end

  def get_anchor(poem=nil)
    r = ""
    if poem
      r = r + "<a href='" + url_for(poem) + "' class='link'>" + poem.to_s + "</a>"
    end
    r
  end
end
