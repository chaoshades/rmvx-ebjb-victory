module EBJB_Victory
  # Build filename
  FINAL   = "build/EBJB_Victory.rb"
  # Source files
  TARGETS = [
	"src/Script_Header.rb",
    "src/Victory_Config.rb",
    "src/Game Objects/Game_Actor.rb",
    "src/Scenes/Scene_Battle.rb",
    "src/Scenes/Scene_Victory.rb",
    "src/User Interface/Font.rb",
    "src/User Interface/Color.rb",
    "src/User Interface/Sound.rb",
    "src/User Interface/Vocab.rb",
    "src/Windows/Window_Victory_Char_Info.rb",
    "src/Windows/Window_Victory_New_Skill.rb",
    "src/Windows/Window_Victory_Level_Up.rb",
    "src/Windows/Window_Victory_Item.rb",
    "src/Windows/Window_Victory_Exp.rb",
    "src/Windows/Window_Victory_Gold.rb",
    "src/User Controls/UCVictoryItem.rb",
    "src/Misc Objects/VictoryItem.rb",
    "src/Misc Objects/ActorExp.rb",
  ]
end

def ebjb_build
  final = File.new(EBJB_Victory::FINAL, "w+")
  EBJB_Victory::TARGETS.each { |file|
    src = File.open(file, "r+")
    final.write(src.read + "\n")
    src.close
  }
  final.close
end

ebjb_build()
