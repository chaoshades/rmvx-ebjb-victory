#==============================================================================
# ** Font
#------------------------------------------------------------------------------
#  Contains the different fonts
#==============================================================================

class Font
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Victory New Skill Font
  #--------------------------------------------------------------------------
  def self.victory_new_skill_font
    f = Font.new()
    f.color = Color.new_skill_color
    f.italic = true
    f.bold = true
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Victory Level Up Font
  #--------------------------------------------------------------------------
  def self.victory_level_up_font
    f = Font.new()
    f.color = Color.level_up_color
    f.bold = true
    return f
  end
  
end
