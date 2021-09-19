#===============================================================================
# ** Window_Victory_Char_Info
#------------------------------------------------------------------------------
#  This window displays the actor's info about exp and level
#===============================================================================

class Window_Victory_Char_Info < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCCharacterFace for the character's face
  attr_reader :ucCharFace
  # Label for the character name
  attr_reader :cCharName
  # UCLabelIconValue for the character's level
  attr_reader :ucCharLvl
  # UCLabelIconValue for the character's experience
  attr_reader :ucExp
  # UCBar for the EXP gauge of the character
  attr_reader :ucExpGauge
  # UCLabelIconValue for the character's total experience
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
  #     actor : actor object
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor)
    super(x, y, width, height)
    
    @ucCharFace = UCCharacterFace.new(self, Rect.new(0,0,96,96), nil)
    
    @cCharName = CLabel.new(self, Rect.new(100,0,200,WLH), "")
    @cCharName.font = Font.bold_font
    
    @ucCharLvl = UCLabelIconValue.new(self, Rect.new(124,24,50,WLH), 
                                     Rect.new(100,24,24,24), 
                                     Rect.new(150,24,110, WLH), 
                                     Vocab::lvl_label, 
                                     VICTORY_CONFIG::ICON_LVL, "")
    @ucCharLvl.cValue.align = 2
    
    @ucExp = UCLabelIconValue.new(self, Rect.new(124,48,25,WLH), 
                                     Rect.new(100,48,24,24), 
                                     Rect.new(125,48,135, WLH),
                                     Vocab::exp_label, 
                                     VICTORY_CONFIG::ICON_EXP, "")
    @ucExp.cValue.align = 2
    @ucExpGauge = UCBar.new(self, Rect.new(100,48+16,162,WLH-16), 
                              Color.exp_gauge_color1, Color.exp_gauge_color2, Color.gauge_back_color, 
                              0, 0, 1, Color.gauge_border_color)                    
    
    @ucTotalExp = UCLabelIconValue.new(self, Rect.new(124,72,50,WLH), 
                                     Rect.new(100,72,24,24), 
                                     Rect.new(150,72,112,WLH), 
                                     Vocab::victory_total_exp_label, 
                                     VICTORY_CONFIG::ICON_TOTAL_EXP, "")
    @ucTotalExp.cValue.align = 2
    
    if actor.dead?
      self.opacity -= (self.opacity/2).to_i
      self.contents_opacity = (self.contents_opacity/2).to_i
    end
    
    window_update(actor)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Update
  #     actor : actor object
  #--------------------------------------------------------------------------
  def window_update(actor)
    if actor != nil
      @ucCharFace.actor = actor
      @cCharName.text = actor.name
      @ucCharLvl.cValue.text = actor.level
      
      if (actor.next_exp == 0)
        gauge_min = 1
        gauge_max = 1
        exp_value = VICTORY_CONFIG::MAX_EXP_GAUGE_VALUE
      else
        gauge_min = actor.now_exp
        gauge_max = actor.next_exp
        exp_value = sprintf(VICTORY_CONFIG::GAUGE_PATTERN, actor.now_exp, actor.next_exp)
      end
      
      @ucExp.cValue.text = exp_value
      @ucExpGauge.value = gauge_min
      @ucExpGauge.max_value = gauge_max
      
      @ucTotalExp.cValue.text = actor.exp
      
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucCharFace.draw()
    @cCharName.draw()
    @ucCharLvl.draw()
    @ucExpGauge.draw()
    @ucExp.draw()
    @ucTotalExp.draw()
  end
  
end
