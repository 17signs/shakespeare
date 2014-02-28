# app/helpers/finder_helper.rb
module FinderHelper
  def finder
    r = "<section class='finder'>"
    Poem.root_poems.each do |p|
      r = r + add_poem(p)
    end
    r = r + "</section>"
    raw r
  end

  def add_poem(poem = nil)
    r = ""
    if poem
      r = r + "<div>"
      if poem.has_successors?
        r = r + "<input id='ac-1' name='accordion-1' type='checkbox' />"
        r = r + "<label for='ac-1'>" + get_anchor(poem) + "</label>"
        r = r + "<article>"
        poem.links_to_successors.each do |l|
          r = r + add_poem(l.to)
        end
        r = r + "</article>"
      else
        r = r + "<label>" + get_anchor(poem) + "</label>"
      end
      r = r + "</div>"
    end
    r
  end

  def get_anchor(poem=nil)
    r = ""
    if poem
      r = r + "<a href='" + url_for(poem) + "'>" + poem.to_s + "</a>"
    end
    r
  end
end



