#==============================================================================
# ** Scene_Victory
#------------------------------------------------------------------------------
#   This class performs battle end screen processing.
#==============================================================================

class Scene_Victory < Scene_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #    troop : Game_Troop object
  #--------------------------------------------------------------------------
  def initialize(troop)
    @skipped = false
    @complete = false
    
    @exp = 0
    @gold = 0
    @drop_items = []
    
    if troop != nil
      @exp = troop.exp_total
      
      @gold = troop.gold_total
      $game_party.gain_gold(@gold)

      @drop_items = merge_drops_items(troop.make_drop_items)
      for drop in @drop_items
        $game_party.gain_item(drop.item, drop.quantity)
      end
    end
    
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Start processing
  #--------------------------------------------------------------------------
  def start
    super
    if VICTORY_CONFIG::IMAGE_BG != ""
      @bg = Sprite.new
      @bg.bitmap = Cache.picture(VICTORY_CONFIG::IMAGE_BG)
      @bg.opacity = VICTORY_CONFIG::IMAGE_BG_OPACITY
    end
    
    @help_window = Window_Info_Help.new(0, 0, 640, 56, Vocab::victory_help_text)
    @help_window.cText.align = 1
    @help_window.cText.font.bold = true
    # Refresh for the text alignment
    @help_window.refresh()

    if VICTORY_CONFIG::DIVIDE_EXP
      exp_by_actor = (@exp / $game_party.members.size).to_i
    else
      exp_by_actor = @exp
    end
      
    @actor_remaining_exp = []
    @victory_char_info_windows = []
    @victory_new_skill_windows = []
    @victory_level_up_windows = []
    for i in 0 .. $game_party.members.size-1           
      actor_exp = ActorExp.new(exp_by_actor, determine_tick($game_party.members[i].next_exp, exp_by_actor))
      @actor_remaining_exp.push(actor_exp)
      
      if i%2 == 0 
        x = -320
      else
        x = 640
      end
      victory_char_info_window = Window_Victory_Char_Info.new(x, (i/2).to_i*128+168, 320, 128, $game_party.members[i])
      victory_char_info_window.active = false
      @victory_char_info_windows.push(victory_char_info_window)

      victory_new_skill_window = Window_Victory_New_Skill.new((i%2)*320, (i/2).to_i*128+168+128-56, 320, 56, nil)
      victory_new_skill_window.active = false
      victory_new_skill_window.visible = false
      @victory_new_skill_windows.push(victory_new_skill_window)

      victory_level_up_window = Window_Victory_Level_Up.new((i%2)*320+200, (i/2).to_i*128+168, 120, 56)
      victory_level_up_window.active = false
      victory_level_up_window.visible = false
      victory_level_up_window.opacity = 0
      @victory_level_up_windows.push(victory_level_up_window)
    end

    @victory_item_window = Window_Victory_Item.new(160, 488, 320, 256, @drop_items)
    @victory_item_window.active = false
    @victory_item_window.visible = false

    @exp_window = Window_Victory_Exp.new(20, 83, 300, 56, @exp)
    @gold_window = Window_Victory_Gold.new(320, 83, 300, 56, @gold)

    [@help_window, @victory_item_window, @exp_window, @gold_window]+
     @victory_char_info_windows+@victory_new_skill_windows.each{
      |w| w.opacity = VICTORY_CONFIG::WINDOW_OPACITY;
          w.back_opacity = VICTORY_CONFIG::WINDOW_BACK_OPACITY
    }
    
  end
  
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    unless @bg.nil?
      @bg.bitmap.dispose
      @bg.dispose
    end
    @help_window.dispose if @help_window != nil
    @victory_item_window.dispose if @victory_item_window != nil
    @exp_window.dispose if @exp_window != nil
    @gold_window.dispose if @gold_window != nil
    for w in @victory_char_info_windows
      w.dispose if w != nil
    end
    for w in @victory_new_skill_windows
      w.dispose if w != nil
    end
    for w in @victory_level_up_windows
      w.dispose if w != nil
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Processing
  #--------------------------------------------------------------------------
  def update
    super
    update_basic(true)
    update_exp_gain()
  end
  
  #--------------------------------------------------------------------------
  # * Basic Update Processing
  #     main : Call from main update method
  #--------------------------------------------------------------------------
  def update_basic(main = false)
    Graphics.update unless main     # Update game screen
    Input.update unless main        # Update input information
    $game_system.update             # Update timer
    
    update_window_movement()

    @help_window.update
    @victory_item_window.update
    @exp_window.update
    @gold_window.update
    for w in @victory_char_info_windows
      w.update
    end
    for w in @victory_new_skill_windows
      w.update
    end
    for w in @victory_level_up_windows
      w.update
    end

    if !@victory_item_window.visible
      update_exp_input()
    else
      update_drops_input()
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update window movement
  #--------------------------------------------------------------------------
  def update_window_movement()
    for i in 0 .. @victory_char_info_windows.size-1
      if !@victory_item_window.visible
        @victory_char_info_windows[i].visible = true
        if i%2 == 0 
          if @victory_char_info_windows[i].x < (i%2)*320
            @victory_char_info_windows[i].x += 16
          end
        else
          if @victory_char_info_windows[i].x > (i%2)*320
            @victory_char_info_windows[i].x -= 16
          end
        end
      else
        if i%2 == 0 
          if @victory_char_info_windows[i].x > -320
            @victory_char_info_windows[i].x -= 16
          else
            @victory_char_info_windows[i].visible = false
          end
        else
          if @victory_char_info_windows[i].x < 640
            @victory_char_info_windows[i].x += 16
          else
            @victory_char_info_windows[i].visible = false
          end
        end
      end
    end
    
    if @victory_item_window.visible
      if @victory_item_window.y > 168
        @victory_item_window.y -= 16
      end
    end
    
  end
  
  #--------------------------------------------------------------------------
  # * Update exp gain for every member of the party
  #--------------------------------------------------------------------------
  def update_exp_gain()
    if !@complete
      total_remaining = 0
      
      for i in 0 .. $game_party.members.size-1
        actor = $game_party.members[i]
        actor_exp = @actor_remaining_exp[i]
        
        if actor.dead? && !VICTORY_CONFIG::EXP_ON_DEATH
          actor_exp.remaining_exp = 0
        end
        
        total_remaining += actor_exp.remaining_exp
        
        if actor_exp.remaining_exp > 0
          last_level = actor.level
          last_skills = actor.skills
          
          if !@skipped
              
            if actor_exp.remaining_exp > actor_exp.tick_exp
              
              if actor_exp.tick_exp > actor.needed_exp && actor.needed_exp > 0
              
                exp_to_gain = actor.needed_exp
                
              else
                
                exp_to_gain = actor_exp.tick_exp
                
              end
              
            else
              
              exp_to_gain = actor_exp.remaining_exp
              
            end
          
            actor.gain_exp(exp_to_gain, false)
            actor_exp.remaining_exp -= exp_to_gain
          else
            actor.gain_exp(actor_exp.remaining_exp, false)
            actor_exp.remaining_exp = 0
          end
          
          @victory_char_info_windows[i].window_update(actor)
          
          if actor.level > last_level
            actor_exp.tick_exp = determine_tick(actor.next_exp, actor_exp.remaining_exp)
            
            @victory_level_up_windows[i].visible = true
            Sound.play_level_up_se
            wait(30)
            @victory_level_up_windows[i].visible = false
          end
          new_skills = actor.skills - last_skills
          for skill in new_skills
            @victory_new_skill_windows[i].window_update(skill)
            @victory_new_skill_windows[i].visible = true
            Sound.play_new_skill_se
            wait(30)
            @victory_new_skill_windows[i].visible = false
          end
        end
      end
 
      if total_remaining == 0
        @complete = true
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Wait a set amount of time
  #     duration : Wait time (number of frames)
  #--------------------------------------------------------------------------
  def wait(duration)
    for i in 0...duration
      update_basic
    end
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Return scene
  #--------------------------------------------------------------------------
  def return_scene
    unless $BTEST
      RPG::ME.fade(1000)
      $game_temp.map_bgm.play
      $game_temp.map_bgs.play
    end
    $scene = Scene_Map.new
  end
  private :return_scene
  
  #--------------------------------------------------------------------------
  # * Determine tick (for the exp increase)
  #--------------------------------------------------------------------------
  def determine_tick(next_exp, remaining_exp)
    # When max level is already reached
    if (next_exp == 0)
      tick = (remaining_exp / VICTORY_CONFIG::FILL_EXP_GAUGE_TICK).to_i
    else
      tick = (next_exp / VICTORY_CONFIG::FILL_EXP_GAUGE_TICK).to_i
    end
    return tick
  end
  private :determine_tick
  
  #--------------------------------------------------------------------------
  # * Merge drops items
  #     items : items list
  #--------------------------------------------------------------------------
  def merge_drops_items(items)
    drop_items = []
    for item in items
      if item != nil
        
        victory_item = nil
        drop_items.each() { |vi| victory_item = vi if vi.item.id == item.id }
        
        if victory_item.nil?
          drop_items.push(VictoryItem.new(item, 1))
        else
          victory_item.quantity += 1
        end
      end
    end
    return drop_items
  end
  private :merge_drops_items
  
  #//////////////////////////////////////////////////////////////////////////
  # * Scene input management methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update Exp input
  #--------------------------------------------------------------------------
  def update_exp_input
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      if !@skipped && !@complete
        Sound.play_decision
        skip_exp_command
      elsif @complete
        Sound.play_decision
        drops_command
      end
    end
  end
  private :update_exp_input
  
  #--------------------------------------------------------------------------
  # * Update Drops input
  #--------------------------------------------------------------------------
  def update_drops_input
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      Sound.play_decision
      quit_command
    end
  end
  private :update_drops_input
    
  #//////////////////////////////////////////////////////////////////////////
  # * Scene Commands
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Quit command
  #--------------------------------------------------------------------------
  def quit_command()
    return_scene
  end
  private :quit_command
  
  #--------------------------------------------------------------------------
  # * Skip Exp command
  #--------------------------------------------------------------------------
  def skip_exp_command()
    @skipped = true
  end
  private :skip_exp_command
  
  #--------------------------------------------------------------------------
  # * Drops command
  #--------------------------------------------------------------------------
  def drops_command()
    @victory_item_window.visible = true
  end
  private :drops_command
  
end
