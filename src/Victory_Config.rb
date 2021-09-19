#==============================================================================
# ** VICTORY_CONFIG
#------------------------------------------------------------------------------
#  Contains the Victory_Config configuration
#==============================================================================

module EBJB
  module VICTORY_CONFIG
    
    # Background image filename, it must be in folder Pictures
    IMAGE_BG = ""
    # Opacity for background image
    IMAGE_BG_OPACITY = 255
    # All windows opacity
    WINDOW_OPACITY = 255
    WINDOW_BACK_OPACITY = 200
    
    #------------------------------------------------------------------------
    # Generic patterns
    #------------------------------------------------------------------------
    
    # Gauge pattern
    GAUGE_PATTERN = "%d/%d"
    # Max EXP gauge value
    MAX_EXP_GAUGE_VALUE = "-------/-------"  
    # Pattern used to show the item quantity in the inventory
    ITEM_NUMBER_PATTERN = ":%2d"
    
    #------------------------------------------------------------------------
    # Scene Victory related
    #------------------------------------------------------------------------
    
    # Icon for EXP
    ICON_EXP  = 102
    # Icon for Level
    ICON_LVL  = 132
    # Icon for TOTAL EXP
    ICON_TOTAL_EXP  = 62
    
    # Filename of the sound effect to play when an actor gains a level
    LEVEL_UP_SE = "Flash1"
    
    # Filename of the sound effect to play when an actor gains a new skill
    NEW_SKILL_SE = "Flash2"
    
    # Number of tick to fill the exp gauge
    FILL_EXP_GAUGE_TICK = 10
    
    # Allows to gain exp even when actor is dead
    #True = Gains exp   False = reverse
    EXP_ON_DEATH = false
    
    # Allows to gain loot when running
    #True = Gains loot (exp, gold, items)   False = reverse
    LOOT_ON_RUN = false
    
    # Divide total exp between party members
    #True = Divides exp   False = reverse
    DIVIDE_EXP = false
    
  end
end
