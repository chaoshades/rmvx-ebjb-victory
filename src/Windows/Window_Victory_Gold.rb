#===============================================================================
# ** Window_Victory_Gold
#------------------------------------------------------------------------------
#  This window displays the total gold won after battle
#===============================================================================

class Window_Victory_Gold < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCLabelIcon for the 
  attr_reader :ucGold
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width : window width
  #     height : window height
  #     gold : gold value
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, gold)
    super(x, y, width, height)                 
    
    @ucGold = UCLabelValue.new(self, Rect.new(0,0,100,WLH), 
                                     Rect.new(100,0,150,WLH), 
                                     Vocab::victory_received_gold_label, "")
    @ucGold.cValue.align = 2
    
    window_update(gold)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Update
  #     gold : gold value
  #--------------------------------------------------------------------------
  def window_update(gold)
    if gold != nil
      @ucGold.cValue.text = gold
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucGold.draw()
  end
  
end
