#===============================================================================
# ** Window_Victory_Level_Up
#------------------------------------------------------------------------------
#  This window displays that an actor gained a level
#===============================================================================

class Window_Victory_Level_Up < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Label for the "Level up"
  attr_reader :cLevelUpLabel

  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)

    @cLevelUpLabel = CLabel.new(self, Rect.new(0,0,88,WLH), Vocab::victory_level_up_label)
    @cLevelUpLabel.font = Font.victory_level_up_font
    
    refresh()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @cLevelUpLabel.draw()
  end
  
end
