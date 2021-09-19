#==============================================================================
# ** ScriptTitle_Text
#------------------------------------------------------------------------------
#  Show the script title (don't copy this)
#==============================================================================

class Scene_Title < Scene_Base
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constants
  #//////////////////////////////////////////////////////////////////////////
  SCRIPT = 'EBJB Custom Victory Aftermath - EBJB_Victory'
  LASTUPDATE = 'Last Update: 2012/03/17'
  AUTHOR = 'Author : ChaosHades'
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def create_script_title
    @text = Sprite.new
    @text.bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @text.bitmap.font.color = Color.new(0,0,0)
    @text.bitmap.draw_text(0,0,Graphics.width,24,SCRIPT,2)
    @text.bitmap.draw_text(0,24,Graphics.width,24,LASTUPDATE,2)
    @text.bitmap.draw_text(0,48,Graphics.width,24,AUTHOR,2)
    @text.z = 10000
  end

  #--------------------------------------------------------------------------
  # * Alias start
  #--------------------------------------------------------------------------
  alias start_ebjb start unless $@
  def start
    start_ebjb
    create_script_title
  end
  
end
