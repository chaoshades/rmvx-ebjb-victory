#===============================================================================
# ** Window_Victory_New_Skill
#------------------------------------------------------------------------------
#  This window displays the actor's new skill gained on level
#===============================================================================

class Window_Victory_New_Skill < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Label for the "New skill"
  attr_reader :cNewSkillLabel
  # UCLabelIcon for the skill icon and name
  attr_reader :ucSkillInfo

  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width : window width
  #     height : window height
  #     skill : skill object
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, skill)
    super(x, y, width, height)

    @cNewSkillLabel = CLabel.new(self, Rect.new(0,0,80,WLH), Vocab::victory_new_skill_label)
    @cNewSkillLabel.font = Font.victory_new_skill_font
    
    @ucSkillInfo = UCLabelIcon.new(self, Rect.new(112,0,180,WLH), 
                                   Rect.new(80,0,24,WLH), "", 0, 0)
    
    window_update(skill)
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # * Update
  #     skill : skill object
  #--------------------------------------------------------------------------
  def window_update(skill)
    if skill != nil
      @ucSkillInfo.cLabel.text = skill.name
      @ucSkillInfo.ucIcon.iconIndex = skill.icon_index
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @cNewSkillLabel.draw()
    @ucSkillInfo.draw()
  end
  
end
