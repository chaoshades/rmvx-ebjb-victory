#===============================================================================
# ** Window_Victory_Exp
#------------------------------------------------------------------------------
#  This window displays the total exp won after battle
#===============================================================================

class Window_Victory_Exp < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCLabelValue for the 
  attr_reader :ucTotalExp
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width : window width
  #     height : window height
  #     exp : exp value
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, exp)
    super(x, y, width, height)                 
    
    @ucTotalExp = UCLabelValue.new(self, Rect.new(0,0,100,WLH), 
                                     Rect.new(100,0,150,WLH), 
                                     Vocab::victory_earned_exp_label, "")
    @ucTotalExp.cValue.align = 2
    
    window_update(exp)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Update
  #     exp : exp value
  #--------------------------------------------------------------------------
  def window_update(exp)
    if exp != nil
      @ucTotalExp.cValue.text = exp
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucTotalExp.draw()
  end
  
end
