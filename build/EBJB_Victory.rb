################################################################################
#                 EBJB Custom Victory Aftermath - EBJB_Victory        #   VX   #
#                          Last Update: 2012/03/17                    ##########
#                         Creation Date: 2012/02/18                            #
#                          Author : ChaosHades                                 #
#     Source :                                                                 #
#     http://www.google.com                                                    #
#------------------------------------------------------------------------------#
#  Description of the script                                                   #
#==============================================================================#
#                         ** Instructions For Usage **                         #
#  There are settings that can be configured in the Victory_Config class.      #
#  For more info on what and how to adjust these settings, see the             #
#  documentation  in the class.                                                #
#==============================================================================#
#                                ** Examples **                                #
#  See the documentation in each classes.                                      #
#==============================================================================#
#                           ** Installation Notes **                           #
#  Copy this script in the Materials section                                   #
#==============================================================================#
#                             ** Compatibility **                              #
#  Works With: Script Names, ...                                               #
#  Alias: Class - method, ...                                                  #
#  Overwrites: Class - method, ...                                             #
################################################################################

$imported = {} if $imported == nil
$imported["EBJB_Victory"] = true

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

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////

  #--------------------------------------------------------------------------
  # Get Now Exp - The experience gained for the current level.
  #--------------------------------------------------------------------------
  # GET
  def now_exp
    return @exp - @exp_list[@level]
  end
  
  #--------------------------------------------------------------------------
  # Get Next Exp - The experience needed for the next level.
  #--------------------------------------------------------------------------
  # GET
  def next_exp
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] - @exp_list[@level] : 0
  end
  
  #--------------------------------------------------------------------------
  # Get Needed Exp - The experience needed for the current level.
  #--------------------------------------------------------------------------
  # GET
  def needed_exp
    return next_exp - now_exp
  end
    
end

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

#==============================================================================
# ** Color
#------------------------------------------------------------------------------
#  Contains the different colors
#==============================================================================

class Color
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get HP Gauge Color 1
  #--------------------------------------------------------------------------
  def self.hp_gauge_color1
    return text_color(20)
  end
  
  #--------------------------------------------------------------------------
  # * Get HP Gauge Color 2
  #--------------------------------------------------------------------------
  def self.hp_gauge_color2
    return text_color(21)
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Gauge Color 1
  #--------------------------------------------------------------------------
  def self.mp_gauge_color1
    return text_color(22)
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Gauge Color 2
  #--------------------------------------------------------------------------
  def self.mp_gauge_color2
    return text_color(23)
  end
  
  #--------------------------------------------------------------------------
  # * Get Exp Gauge Color 1
  #--------------------------------------------------------------------------
  def self.exp_gauge_color1
    return text_color(14)
  end
  
  #--------------------------------------------------------------------------
  # * Get Exp Gauge Color 2
  #--------------------------------------------------------------------------
  def self.exp_gauge_color2
    return text_color(17)
  end
  
  #--------------------------------------------------------------------------
  # * Get New Skill Color
  #--------------------------------------------------------------------------
  def self.new_skill_color
    return text_color(14)
  end
  
  #--------------------------------------------------------------------------
  # * Get Level Up Color
  #--------------------------------------------------------------------------
  def self.level_up_color
    return text_color(2)
  end
  
end

#==============================================================================
# ** Sound
#------------------------------------------------------------------------------
#  This module plays sound effects. It obtains sound effects specified in the
# database from $data_system, and plays them.
#==============================================================================

module Sound
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Play level up sound effect
  #--------------------------------------------------------------------------
  def self.play_level_up_se
    RPG::SE.new(VICTORY_CONFIG::LEVEL_UP_SE, 100, 100).play
  end
  
  #--------------------------------------------------------------------------
  # * Play new skill sound effect
  #--------------------------------------------------------------------------
  def self.play_new_skill_se
    RPG::SE.new(VICTORY_CONFIG::NEW_SKILL_SE, 100, 100).play
  end
  
end

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
#  This module defines terms and messages. It defines some data as constant
# variables. Terms in the database are obtained from $data_system.
#==============================================================================

module Vocab

  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #//////////////////////////////////////////////////////////////////////////
  # * Stats Parameters related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get HP Label
  #--------------------------------------------------------------------------
  def self.hp_label
    return self.hp
  end
  
  #--------------------------------------------------------------------------
  # * Get MP Label
  #--------------------------------------------------------------------------
  def self.mp_label
    return self.mp
  end
  
  #--------------------------------------------------------------------------
  # * Get EXP Label
  #--------------------------------------------------------------------------
  def self.exp_label
    return "EXP"
  end
  
  #--------------------------------------------------------------------------
  # * Get Level Label
  #--------------------------------------------------------------------------
  def self.lvl_label
    return self.level
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # Scene Victory related
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Help text in battle for the Victory Aftermath
  #--------------------------------------------------------------------------
  def self.victory_help_text
    return "Battle results"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label to show Total Exp.
  #--------------------------------------------------------------------------
  def self.victory_total_exp_label
    return "TOTAL"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label when there are no drops
  #--------------------------------------------------------------------------
  def self.victory_no_drops_label
    return "None"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label when a new skill is learned on level up
  #--------------------------------------------------------------------------
  def self.victory_new_skill_label
    return "New skill !!!"
  end
    
  #--------------------------------------------------------------------------
  # * Get Label when gaining a level
  #--------------------------------------------------------------------------
  def self.victory_level_up_label
    return "Level Up !!!"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label for earned exp
  #--------------------------------------------------------------------------
  def self.victory_earned_exp_label
    return "Earned EXP"
  end
  
  #--------------------------------------------------------------------------
  # * Get Label for gold received
  #--------------------------------------------------------------------------
  def self.victory_received_gold_label
    return "Received Gold"
  end

end

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

#==============================================================================
# ** Window_Victory_Item
#------------------------------------------------------------------------------
#  This window displays the items won after battle
#==============================================================================

class Window_Victory_Item < Window_Selectable
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Array of UCVictoryItem for every item in the inventory
  attr_reader :ucVictoryItemsList
  # Label for message (no drops or when drops are hidden)
  attr_reader :cMsg
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window x-coordinate
  #     y : window y-coordinate
  #     width : window width
  #     height : window height
  #     items : items list
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, items=nil)
    super(x, y, width, height)
    @cMsg = CLabel.new(self, Rect.new(0,height/2-WLH/2-16,width-32,WLH), Vocab::victory_no_drops_label, 1)

    @ucVictoryItemsList = []
    window_update(items)
    self.index = -1
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Update
  #     items : items list
  #--------------------------------------------------------------------------
  def window_update(items)
    @data = []
    if items != nil
      for item in items
        if item != nil
          @data.push(item)
        end
      end
      @item_max = @data.size
      create_contents()
      @ucVictoryItemsList.clear()
      for i in 0..@item_max-1
        @ucVictoryItemsList.push(create_item(i))
      end
    end

    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    if hasDrops
      @ucVictoryItemsList.each() { |dropData| dropData.draw() }
    else
      @cMsg.draw()
    end
  end
  
  #--------------------------------------------------------------------------
  # * Return true if there are drops in the list else false
  #--------------------------------------------------------------------------
  def hasDrops
    return @ucVictoryItemsList.size > 0
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for ucVictoryItemsList
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
    item = @data[index]
    rect = item_rect(index)
    
    ucItem = UCVictoryItem.new(self, item, rect)
                              
    return ucItem
  end
  private :create_item
  
end

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

#==============================================================================
# ** UCVictoryItem
#------------------------------------------------------------------------------
#  Represents a victory item on a window
#==============================================================================

class UCVictoryItem < UserControl
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCIcon for the item icon
  attr_reader :ucIcon
  # Label for the item name
  attr_reader :cItemName
  # Label for the item quantity
  attr_reader :cItemNumber
  # victory_item object
  attr_reader :victory_item
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set the visible property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def visible=(visible)
    @visible = visible
    @ucIcon.visible = visible
    @cItemName.visible = visible
    @cItemNumber.visible = visible
  end

  #--------------------------------------------------------------------------
  # * Set the active property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def active=(active)
    @active = active
    @ucIcon.active = active
    @cItemName.active = active
    @cItemNumber.active = active
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     window : window in which the control will appear
  #     victory_item : victory_item object
  #     rect : rectangle to position the controls for the item
  #     spacing : spacing between controls
  #     active : control activity
  #     visible : control visibility
  #--------------------------------------------------------------------------
  def initialize(window, victory_item, rect, spacing=8,
                 active=true, visible=true)
    super(active, visible)
    @victory_item = victory_item
    
    # Determine rectangles to position controls
    rects = determine_rects(rect, spacing)
    
    @ucIcon = UCIcon.new(window, rects[0], victory_item.item.icon_index)
    @ucIcon.active = active
    @ucIcon.visible = visible
    
    @cItemName = CLabel.new(window, rects[1], victory_item.item.name)
    @cItemName.active = active
    @cItemName.visible = visible
    @cItemName.cut_overflow = true
    
    @cItemNumber = CLabel.new(window, rects[2], 
                              sprintf(VICTORY_CONFIG::ITEM_NUMBER_PATTERN, 
                                      victory_item.quantity), 2)
    @cItemNumber.active = active
    @cItemNumber.visible = visible
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw the background image on the window
  #--------------------------------------------------------------------------
  def draw()
    @ucIcon.draw()
    @cItemName.draw()
    @cItemNumber.draw()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine rectangles to positions controls in the user control
  #     rect : base rectangle to position the controls
  #     spacing : spacing between controls
  #--------------------------------------------------------------------------
  def determine_rects(rect, spacing)
    rects = []
    
    # Rects Initialization
    rects[0] = Rect.new(rect.x,rect.y,24,rect.height)
    rects[1] = Rect.new(rect.x,rect.y,rect.width,rect.height)
    rects[2] = Rect.new(rect.x,rect.y,32,rect.height)
    
    # Rects Adjustments
    
    # ucIcon
    # Nothing to do
    
    # cItemName
    rects[1].x += rects[0].width
    rects[1].width = rect.width - rects[0].width - rects[2].width - spacing
    
    # cItemNumber
    rects[2].x += rect.width - rects[2].width
    
    return rects
  end
  private :determine_rects
  
end

#==============================================================================
# ** VictoryItem
#------------------------------------------------------------------------------
#  Custom object used to represent an item won after battle
#==============================================================================

class VictoryItem
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Item object
  attr_reader :item
  # Quantity of the item obtained
  attr_accessor :quantity
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     item : item object
  #     quantity : quantity of the item obtained
  #--------------------------------------------------------------------------
  def initialize(item, quantity)
    @item = item
    @quantity = quantity
  end
  
end

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

