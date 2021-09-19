#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Display Gained Experience and Gold
  #--------------------------------------------------------------------------
  def display_exp_and_gold
    # Does nothing, will be managed in Scene_Victory
  end
  
  #--------------------------------------------------------------------------
  # * Display Gained Drop Items
  #--------------------------------------------------------------------------
  def display_drop_items
    # Does nothing, will be managed in Scene_Victory
  end
  
  #--------------------------------------------------------------------------
  # * Display Level Up
  #--------------------------------------------------------------------------
  def display_level_up
    # Does nothing, will be managed in Scene_Victory
  end
  
  #--------------------------------------------------------------------------
  # * End Battle
  #     result : Results (0: win, 1: escape, 2:lose)
  #--------------------------------------------------------------------------
  def battle_end(result)
    if result == 2 and not $game_troop.can_lose
      call_gameover
    else
      Graphics.fadeout(30)

      if result == 1 && !VICTORY_CONFIG::LOOT_ON_RUN
        $scene = Scene_Victory.new(nil)
      else
        $scene = Scene_Victory.new($game_troop)
      end
      $game_party.clear_actions
      $game_party.remove_states_battle
      $game_troop.clear
      if $game_temp.battle_proc != nil
        $game_temp.battle_proc.call(result)
        $game_temp.battle_proc = nil
      end
    end
    $game_temp.in_battle = false
  end
  
end
