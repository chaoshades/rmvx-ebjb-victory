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
