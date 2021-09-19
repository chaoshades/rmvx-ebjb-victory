#==============================================================================
# ** ActorExp
#------------------------------------------------------------------------------
#  Custom object used for exp gain after battle
#==============================================================================

class ActorExp
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Total remaining exp
  attr_accessor :remaining_exp
  # Tick of the exp gain (used for the progress bar)
  attr_accessor :tick_exp
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     remaining_exp : total remaining exp
  #     tick_exp : tick of the exp gain
  #--------------------------------------------------------------------------
  def initialize(remaining_exp, tick_exp)
    @remaining_exp = remaining_exp
    @tick_exp = tick_exp
  end
  
end
